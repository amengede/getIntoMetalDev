//
//  GameScene.swift
//  Project
//
//  Created by Andrew Mengede on 3/9/2022.
//

import Foundation

class GameScene: ObservableObject {
    /*
     Holds references to all objects in the scene
     */
    
    @Published var camera: Camera
    @Published var spheres: [Sphere]
    
    init() {
        
        camera = Camera(position: [-20.0, 0.0, 0.0])
        
        spheres = []
        for _ in 1...32 {
            let tempSphere = Sphere(
                center: [
                    Float.random(in: 3.0...10.0),
                    Float.random(in: -5.0...5.0),
                    Float.random(in: -5.0...5.0)
                ],
                radius: Float.random(in: 0.1...2.0),
                color: [
                    Float.random(in: 0.3...1.0),
                    Float.random(in: 0.3...1.0),
                    Float.random(in: 0.3...1.0)
                ]
            )
            spheres.append(tempSphere)
        }
    }
}
