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
    var reflectance: Float
    
    init(center: vector_float3, radius: Float, color: vector_float3, reflectance: Float) {
        
        self.center = center
        self.radius = radius
        self.color = color
        self.reflectance = reflectance
    }
}
