//
//  Scene.swift
//  Transformations
//
//  Created by Andrew Mengede on 2/3/2022.
//

import Foundation

class RenderScene {
    
    var player: Camera
    var triangles: [SimpleComponent]
    
    init() {
        player = Camera(
            position: [-1, 0, 0],
            eulers: [0.0, 90.0, 0.0]
        )
        
        triangles = [
            SimpleComponent(
                position: [3.0, 0.0, 0.0],
                eulers: [0.0, 0.0, 0.0]
            )
        ]
    }
    
    func update() {
        
        player.updateVectors()
        
        for triangle in triangles {
            
            triangle.eulers.z += 1
            if triangle.eulers.z > 360 {
                triangle.eulers.z -= 360
            }
            
        }
        
    }
}
