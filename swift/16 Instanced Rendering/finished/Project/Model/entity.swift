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
    let id: Int32
    let color: simd_float3
    
    
    init(position: simd_float3, eulers: simd_float3, id: Int32, color: simd_float3) {
        
        self.position = position;
        self.eulers = eulers;
        self.id = id;
        self.color = color;
    }
    
    func get_model_transform() -> simd_float4x4 {
        
        let model = Matrix44.create_from_rotation(eulers: eulers);
        return Matrix44.create_from_translation(translation: position) * model;
    }
}
