//
//  EnvironmentViews.swift
//  WatchItTogether
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

// Updated to place floor at standard floor level
let planeHeight: Float = 0
let roomSize: Float = 3
let screenScale: Float = 0.1

// Theater environment view
struct TheaterEnvironment: View {
    var body: some View {
        RealityView { content in
            let screenWidth: Float = Float(16.0*screenScale)
            let screenHeight: Float = Float(9.0*screenScale)
            let screenOffset = roomSize * -4
            // Create a simple theater environment with basic lighting
            // Create a point light
            let lightEntity = ModelEntity()
            lightEntity.name = "Point Light"
            let pointLight = PointLightComponent(color: .white, intensity: 500)
            lightEntity.components.set(pointLight)
            lightEntity.position = simd_float3(0, 2, screenOffset)
            content.add(lightEntity)
            
            // Add a simple floor to represent theater floor
            let floorEntity = ModelEntity(
                mesh: .generatePlane(width: roomSize, depth: roomSize),
                materials: [SimpleMaterial(color: .darkGray, isMetallic: false)]
            )
            floorEntity.name = "Floor"
            floorEntity.position = simd_float3(0, planeHeight, screenOffset)
            content.add(floorEntity)
            
            // Add a wall to represent theater screen
            let screenEntity = ModelEntity(
                mesh: .generatePlane(width: screenWidth, height: screenHeight),
                materials: [SimpleMaterial(color: .white, isMetallic: false)]
            )
            screenEntity.name = "screen"
            screenEntity.position = simd_float3(0, 1, screenOffset)
            content.add(screenEntity)
        }
    }
}

// Nature environment view
struct NatureEnvironment: View {
    var body: some View {
        RealityView { content in
            // Create a simple nature environment
            // Create a directional light to simulate sun
            let sunEntity = ModelEntity()
            sunEntity.name = "Sun"
            let sunLight = DirectionalLightComponent(color: .white, intensity: 1000)
            sunEntity.components.set(sunLight)
            // Position high and angled like the sun
            sunEntity.position = simd_float3(5, roomSize, 5)
            sunEntity.look(at: simd_float3(0, 0, 0), from: sunEntity.position, relativeTo: nil)
            content.add(sunEntity)
            
            // Add a green floor to represent grass
            let groundEntity = ModelEntity(
                mesh: .generatePlane(width: 20, depth: 20),
                materials: [SimpleMaterial(color: .green, isMetallic: false)]
            )
            groundEntity.name = "Ground"
            groundEntity.position = simd_float3(0, planeHeight, 0)
            content.add(groundEntity)
            
            // Add a blue ceiling to represent sky
            let skyEntity = ModelEntity(
                mesh: .generatePlane(width: 30, height: 30),
                materials: [SimpleMaterial(color: .blue, isMetallic: false)]
            )
            skyEntity.name = "Sky"
            skyEntity.position = simd_float3(0, roomSize, 0)
            // Rotate to face downward
            skyEntity.orientation = simd_quatf(angle: .pi, axis: simd_float3(1, 0, 0))
            content.add(skyEntity)
        }
    }
}

// Space environment view
struct SpaceEnvironment: View {
    var body: some View {
        RealityView { content in
            // Create a simple space environment
            // Create a dim point light
            let lightEntity = ModelEntity()
            lightEntity.name = "Light"
            let ambientLight = PointLightComponent(color: .blue, intensity: 200)
            lightEntity.components.set(ambientLight)
            lightEntity.position = simd_float3(0, 2, 2)
            content.add(lightEntity)
            
            // Add a black floor to represent space
            let spaceEntity = ModelEntity(
                mesh: .generatePlane(width: 20, depth: 20),
                materials: [SimpleMaterial(color: .black, isMetallic: true)]
            )
            spaceEntity.name = "Floor"
            spaceEntity.position = simd_float3(0, planeHeight, 0)
            content.add(spaceEntity)
            
            // Add some stars (small white spheres)
            for starIndex in 0..<50 {
                let starSize = Float.random(in: 0.02...0.08)
                let starEntity = ModelEntity(
                    mesh: .generateSphere(radius: starSize),
                    materials: [SimpleMaterial(color: .white, isMetallic: true)]
                )
                // Random positions around the environment
                let x = Float.random(in: -roomSize...roomSize)
                let y = Float.random(in: -1...8)
                let z = Float.random(in: -roomSize...roomSize)
                starEntity.name = "Star \(starIndex) @ [\(x), \(y), \(z)]"
                starEntity.position = simd_float3(x, y, z)
                content.add(starEntity)
            }
        }
    }
}
