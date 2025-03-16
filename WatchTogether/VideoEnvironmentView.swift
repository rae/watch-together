//
//  VideoEnvironmentView.swift
//  WatchTogether
//
//  Created by Reid Ellis on 2025-03-15.
//

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
                // Position the video appropriately based on environment
                VideoPlayerView(player: player)
                    .frame(width: 16, height: 9)  // 16:9 aspect ratio
                    .scale3D(environmentType == .theater ? 2 : 1.5)
                    .position(x: 0, y: 1.7, z: -5)
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
