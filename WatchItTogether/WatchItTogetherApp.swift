//
//  WatchItTogether.swift
//  WatchItTogether
//
//  Created by Reid Ellis on 2025-03-15.
//

import SwiftUI
import RealityKit

@main
struct WatchItTogetherApp: App {
    @State private var immersionStyle: ImmersionStyle = .full
    
    var body: some SwiftUI.Scene {
        // Primary window - required for proper scene setup
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        
        // Immersive space for video environment
        ImmersiveSpace(id: "VideoEnvironment") {
            VideoEnvironmentView()
        }
        .immersionStyle(selection: $immersionStyle, in: .full, .mixed)
    }
}
