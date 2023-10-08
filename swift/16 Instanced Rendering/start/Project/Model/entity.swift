//
//  simpleComponent.swift
//  Transformations
//
//  Created by Andrew Mengede on 2/3/2022.
//

import Foundation

class Entity {
    
    var position: simd_float3
    var eulers: simd_float3
    var model: simd_float4x4
    
    
    init(position: simd_float3, eulers: simd_float3) {
        
        self.position = position;
        self.eulers = eulers;
        model = Matrix44.create_identity();
        
    }
    
    func update() {
        
        model = Matrix44.create_from_rotation(eulers: eulers);
        model = Matrix44.create_from_translation(translation: position) * model;
    }
}
