//
//  Sphere.swift
//  Project
//
//  Created by Andrew Mengede on 3/9/2022.
//

import Foundation

class Sphere {
    
    var center: vector_float3
    var radius: Float
    var color: vector_float3
    
    init(center: vector_float3, radius: Float, color: vector_float3) {
        
        self.center = center
        self.radius = radius
        self.color = color
        
    }
}
