//
//  VideoPlayerView.swift
//  WatchItTogether
//
//  Created by Reid Ellis on 2025-03-15.
//

import SwiftUI
import RealityKit
import AVKit

// Custom video player view for 3D space
struct VideoPlayerView: View {
    let player: AVPlayer
    
    var body: some View {
        RealityView { content in
            let videoMaterial = VideoMaterial(avPlayer: player)
            let videoPlane = ModelEntity(
                mesh: .generatePlane(width: 16, height: 9),
                materials: [videoMaterial]
            )
            content.add(videoPlane)
        }
    }
}
