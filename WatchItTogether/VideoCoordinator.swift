//
//  VideoCoordinator.swift
//  WatchItTogether
//
//  Created by Reid Ellis on 2025-03-15.
//

import SwiftUI
import AVKit
import GroupActivities
import UniformTypeIdentifiers
import Observation
import CryptoKit

struct VideoFileInfo: Codable {
    let filename: String
    let checksum: String
    let fileSize: Int64
    let duration: Double
}

struct TimeMessage: Codable {
    let seconds: Double
}

@Observable
class VideoCoordinator {
    var player: AVPlayer?
    var selectedVideoURL: URL?
    var isSharing = false
    var isJoined = false
    var errorMessage: String?
    var fileInfo: VideoFileInfo?
    var remoteFileInfo: VideoFileInfo?
    var filesMatch = false
    
    private var groupSession: GroupSession<VideoWatchingActivity>?
    private var messenger: GroupSessionMessenger?
    private var timeObserver: Any?
    
    init() {
        prepareForActivity()
    }
    
    deinit {
        if let timeObserver = timeObserver, let player = player {
            player.removeTimeObserver(timeObserver)
        }
    }
    
    func prepareForActivity() {
        Task {
            for await session in VideoWatchingActivity.sessions() {
                configureGroupSession(session)
                session.join()
                
                await MainActor.run {
                    isJoined = true
                }
            }
        }
    }
    
    private func configureGroupSession(_ session: GroupSession<VideoWatchingActivity>) {
        groupSession = session
        messenger = GroupSessionMessenger(session: session)
        
        listenForTimeUpdates()
        listenForFileSelectionMessages()
        
        session.join()
    }
    
    private func listenForTimeUpdates() {
        Task {
            guard let messenger = messenger else { return }
            
            // Need to use a custom message type for CMTime
            for await (message, _) in messenger.messages(of: Data.self) {
                do {
                    let decoder = JSONDecoder()
                    // Try to decode as TimeMessage
                    if let timeMessage = try? decoder.decode(TimeMessage.self, from: message) {
                        let time = CMTime(seconds: timeMessage.seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                        handleReceivedTime(time)
                    }
                } catch {
                    // Ignore errors - it might be a file info message instead
                }
            }
        }
    }
    
    private func listenForFileSelectionMessages() {
        Task {
            guard let messenger = messenger else { return }
            
            for await (message, _) in messenger.messages(of: Data.self) {
                do {
                    let decoder = JSONDecoder()
                    if let receivedFileInfo = try? decoder.decode(VideoFileInfo.self, from: message) {
                        await MainActor.run {
                            self.remoteFileInfo = receivedFileInfo
                            // Check if we already have a file selected
                            if let localFileInfo = self.fileInfo {
                                compareFileInfo(local: localFileInfo, remote: receivedFileInfo)
                            } else {
                                // Alert user to select corresponding file
                                errorMessage = "Other participant is watching \(receivedFileInfo.filename). Please select this file to watch together."
                            }
                        }
                    }
                } catch {
                    // Ignore errors - it might be a time message instead
                }
            }
        }
    }
    
    private func handleReceivedTime(_ time: CMTime) {
        Task { @MainActor in
            guard let player = self.player else { return }
            
            // Check if the time difference is significant enough to seek
            let currentTime = player.currentTime()
            let difference = CMTimeGetSeconds(time) - CMTimeGetSeconds(currentTime)
            
            if abs(difference) > 2.0 {
                player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
            }
        }
    }
    
    private func compareFileInfo(local: VideoFileInfo, remote: VideoFileInfo) {
        // Compare file checksums to ensure they're the same file
        if local.checksum == remote.checksum {
            filesMatch = true
            errorMessage = nil
        } else {
            filesMatch = false
            // First try to check if it's just a different encode of the same content
            let durationDiff = abs(local.duration - remote.duration)
            if durationDiff < 1.0 { // Within 1 second duration
                errorMessage = "Warning: Files appear similar but not identical. Playback may not match perfectly."
            } else {
                // Files are completely different
                errorMessage = "Files don't match. You're watching '\(local.filename)' but other participant has '\(remote.filename)'. Please select the same file."
            }
        }
    }
    
    private func calculateFileInfo(url: URL) async -> VideoFileInfo? {
        do {
            // Get file attributes
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            
            // Calculate checksum of first 100KB
            let handle = try FileHandle(forReadingFrom: url)
            let headerData = try handle.read(upToCount: 100 * 1024) ?? Data()
            try handle.close()
            
            let checksum = SHA256.hash(data: headerData).compactMap { String(format: "%02x", $0) }.joined()
            
            // Get video duration
            let asset = AVURLAsset(url: url)
            let duration = try await asset.load(.duration).seconds
            
            return VideoFileInfo(
                filename: url.lastPathComponent,
                checksum: checksum,
                fileSize: fileSize,
                duration: duration
            )
        } catch {
            await MainActor.run {
                errorMessage = "Error analyzing file: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    func selectVideo() {
        // Create document picker with the helper extension
        let picker = UIDocumentPickerViewController.createPicker(
            forContentTypes: [UTType.movie, UTType.video]
        ) { [weak self] urls in
            guard let url = urls.first else { return }
            
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                // Calculate file info including checksum
                if let fileInfo = await calculateFileInfo(url: url) {
                    self.fileInfo = fileInfo
                    
                    // Compare with remote file info if available
                    if let remoteFileInfo = self.remoteFileInfo {
                        compareFileInfo(local: fileInfo, remote: remoteFileInfo)
                    }
                    
                    // Setup player
                    setupPlayer(with: url)
                    
                    // Share file info with other participants
                    if let messenger = messenger {
                        do {
                            let encoder = JSONEncoder()
                            let fileInfoData = try encoder.encode(fileInfo)
                            try await messenger.send(fileInfoData)
                        } catch {
                            errorMessage = "Failed to share file info: \(error.localizedDescription)"
                        }
                    }
                }
            }
        }
        
        // Present the document picker
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            root.present(picker, animated: true)
        }
    }
    
    private func setupPlayer(with url: URL) {
        selectedVideoURL = url
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        
        // Setup time observation to sync with remote participants
        setupTimeObservation()
    }
    
    private func setupTimeObservation() {
        // Remove previous observer if it exists
        if let timeObserver = timeObserver, let player = player {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        // Add new observer
        if let player = player {
            let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                guard let self = self, self.isSharing || self.isJoined else { return }
                
                // Only send time updates if playing
                if player.rate > 0 {
                    Task {
                        do {
                            // Convert CMTime to Data using our TimeMessage struct
                            let timeMessage = TimeMessage(seconds: CMTimeGetSeconds(time))
                            let encoder = JSONEncoder()
                            let timeData = try encoder.encode(timeMessage)
                            try await self.messenger?.send(timeData)
                        } catch {
                            print("Error sending time update: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    func startSharing() {
        Task {
            do {
                let activity = VideoWatchingActivity()
                // Prepare for activation and discard the result since we don't need it
                _ = try await activity.prepareForActivation()
                
                // Activate the activity
                try await activity.activate()
                
                // Watch for the session
                for await groupSession in VideoWatchingActivity.sessions() {
                    configureGroupSession(groupSession)
                    
                    await MainActor.run {
                        isSharing = true
                    }
                    break // Just need the first session
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to start sharing: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func togglePlayPause() {
        guard let player = player else { return }
        
        if player.rate > 0 {
            player.pause()
        } else {
            player.play()
        }
    }
}
