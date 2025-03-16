//
//  EnvironmentViews.swift
//  WatchTogether
//
//  Created by Reid Ellis on 2025-03-15.
//

import SwiftUI
import RealityKit

enum EnvironmentType: String, CaseIterable, Identifiable {
    case theater = "Theater"
    case nature = "Nature Scene"
    case space = "Space"
    
    var id: String { self.rawValue }
}

// Theater environment view
struct TheaterEnvironment: View {
    var body: some View {
        RealityView { content in
            // Theater environment would be created here
            // This would include theater seating, walls, etc.
            let theater = try! ModelEntity.load(named: "TheaterEnvironment")
            content.add(theater)
            
            // Add ambient lighting
            let light = PointLight()
            light.intensity = 500
            light.position = SIMD3(0, 5, 5)
            let lightEntity = ModelEntity()
            lightEntity.components.set(light)
            content.add(lightEntity)
        }
    }
}

// Nature environment view
struct NatureEnvironment: View {
    var body: some View {
        RealityView { content in
            // Nature environment would be created here
            // This would include trees, sky, etc.
            let nature = try! ModelEntity.load(named: "NatureEnvironment")
            content.add(nature)
            
            // Add sunlight
            let sunlight = DirectionalLight()
            sunlight.intensity = 1000
            sunlight.color = .white
            let sunlightEntity = ModelEntity()
            sunlightEntity.components.set(sunlight)
            content.add(sunlightEntity)
        }
    }
}

// Space environment view
struct SpaceEnvironment: View {
    var body: some View {
        RealityView { content in
            // Space environment would be created here
            // This would include stars, planets, etc.
            let space = try! ModelEntity.load(named: "SpaceEnvironment")
            content.add(space)
            
            // Add ambient light (dim for space)
            let ambientLight = PointLight()
            ambientLight.intensity = 200
            ambientLight.color = .blue
            let lightEntity = ModelEntity()
            lightEntity.components.set(ambientLight)
            content.add(lightEntity)
        }
    }
}
