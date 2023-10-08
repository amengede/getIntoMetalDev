//
//  Camera.swift
//  Project
//
//  Created by Andrew Mengede on 3/9/2022.
//

import Foundation

class Camera {
    /*
     Represents a camera in the scene
     */
    
    var position: vector_float3
    var theta: Float
    var phi: Float
    var forwards: vector_float3
    var right: vector_float3
    var up: vector_float3
    
    init(position: vector_float3) {
        
        self.position = position;
        theta = 0
        phi = 0
        forwards = [0.0, 0.0, 0.0];
        right = [0.0, 0.0, 0.0];
        up = [0.0, 0.0, 0.0];
        
        recalculate_vectors()
    }
    
    func recalculate_vectors() {
        
        forwards = [
            cos(theta * 180.0 / .pi) * cos(phi * 180.0 / .pi),
            sin(theta * 180.0 / .pi) * cos(phi * 180.0 / .pi),
            sin(phi * 180.0 / .pi)
        ]
        
        let global_up: vector_float3 = [0.0, 0.0, 1.0];
        
        right = normalize(cross(forwards, global_up))
        
        up = normalize(cross(right, forwards))
    }
}
