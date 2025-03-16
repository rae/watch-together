//
//  WatchTogetherApp.swift
//  WatchTogether
//
//  Created by Reid Ellis on 2025-03-15.
//

import SwiftUI

@main
struct WatchTogetherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        
        ImmersiveSpace(id: "VideoEnvironment") {
            VideoEnvironmentView()
        }
    }
}
