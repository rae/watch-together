//
//  VideoEnvironmentView.swift
//  WatchTogether
//
//  Created by Reid Ellis on 2025-03-15.
//

import SwiftUI
import RealityKit
import AVKit

import SwiftUI
import RealityKit
import AVKit

struct VideoEnvironmentView: View {
    @Environment(\.videoCoordinator) private var coordinator
    @State private var environmentType: EnvironmentType = .theater
    
    var body: some View {
        ZStack {
            // Environment background based on selected type
            switch environmentType {
            case .theater:
                TheaterEnvironment()
            case .nature:
                NatureEnvironment()
            case .space:
                SpaceEnvironment()
            }
            
            // Video player positioned in environment
            if let player = coordinator.player {
                RealityView { content in
                    // Create a video material from the AVPlayer
                    let videoMaterial = VideoMaterial(avPlayer: player)
                    
                    // Create a plane with the video material
                    let videoPlane = ModelEntity(
                        mesh: .generatePlane(width: 16, height: 9, cornerRadius: 0.2),
                        materials: [videoMaterial]
                    )
                    
                    // Scale based on environment type
                    let scale: Float = environmentType == .theater ? 2.0 : 1.5
                    videoPlane.scale = simd_float3(repeating: scale)
                    
                    // Position the video plane in the environment
                    videoPlane.position = simd_float3(0, 1.7, -5)
                    
                    // Add the video plane to the scene
                    content.add(videoPlane)
                }
            }
            
            // Environment controls
            VStack {
                Spacer()
                
                HStack {
                    ForEach(EnvironmentType.allCases) { type in
                        Button(type.rawValue) {
                            environmentType = type
                        }
                        .buttonStyle(.bordered)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    VideoEnvironmentView()
        .environment(\.videoCoordinator, VideoCoordinator())
}
