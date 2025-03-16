//
//  ContentView.swift
//  WatchTogether
//
//  Created by Reid Ellis on 2025-03-15.
//

import SwiftUI
import AVKit
import GroupActivities

struct ContentView: View {
    @State private var coordinator = VideoCoordinator()
    @State private var isImmersiveActive = false
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        VStack {
            if let player = coordinator.player {
                VideoPlayer(player: player)
                    .frame(height: 400)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                
                HStack {
                    Button(action: coordinator.togglePlayPause) {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.bordered)
                    .padding()
                    
                    if let url = coordinator.selectedVideoURL {
                        Text(url.lastPathComponent)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
            } else {
                ContentUnavailableView {
                    Label("No Video Selected", systemImage: "film")
                } description: {
                    Text("Select a video file to start watching")
                } actions: {
                    Button("Select Video", action: coordinator.selectVideo)
                        .buttonStyle(.bordered)
                }
                .frame(maxHeight: .infinity)
            }
            
            Spacer()
            
            HStack {
                Button("Select Video", action: coordinator.selectVideo)
                    .buttonStyle(.bordered)
                
                if !coordinator.isSharing && !coordinator.isJoined {
                    Button("Start Sharing", action: coordinator.startSharing)
                        .buttonStyle(.borderedProminent)
                } else {
                    Text(coordinator.isSharing ? "Sharing Active" : "Joined Session")
                        .foregroundColor(.green)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.green, lineWidth: 1)
                        )
                }
                
                if coordinator.filesMatch {
                    Label("Files Match ✓", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if coordinator.remoteFileInfo != nil {
                    Label("Files Don't Match ✗", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button(isImmersiveActive ? "Exit Immersive Mode" : "Enter Immersive Mode") {
                    if isImmersiveActive {
                        Task {
                            await dismissImmersiveSpace()
                            isImmersiveActive = false
                        }
                    } else {
                        Task {
                            await openImmersiveSpace(id: "VideoEnvironment")
                            isImmersiveActive = true
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(coordinator.player == nil)
            }
            .padding()
        }
        .padding()
        .onAppear {
            // Request necessary permissions when the app launches
            Task {
                try? await GroupStateObserver.prepareForSharing()
            }
        }
        .alert(isPresented: Binding<Bool>(
            get: { coordinator.errorMessage != nil },
            set: { if !$0 { coordinator.errorMessage = nil } }
        )) {
            Alert(
                title: Text("Notice"),
                message: Text(coordinator.errorMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
        .environment(\.videoCoordinator, coordinator)
    }
}

// Environment key for passing VideoCoordinator
private struct VideoCoordinatorKey: EnvironmentKey {
    static let defaultValue: VideoCoordinator = VideoCoordinator()
}

extension EnvironmentValues {
    var videoCoordinator: VideoCoordinator {
        get { self[VideoCoordinatorKey.self] }
        set { self[VideoCoordinatorKey.self] = newValue }
    }
}

#Preview {
    ContentView()
}
