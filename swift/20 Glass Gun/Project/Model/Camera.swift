//
//  camera.swift
//  Project
//
//  Created by Andrew Mengede on 19/6/2023.
//

import Foundation

class Camera: Entity {
    
    var forwards: vector_float3
    var right: vector_float3
    var up: vector_float3
    
    
    init(position: simd_float3, eulers: simd_float3, id: Int32) {
        
        forwards = [
            cos(eulers.y.degreesToRadians()) * cos(eulers.z.degreesToRadians()),
            cos(eulers.y.degreesToRadians()) * sin(eulers.z.degreesToRadians()),
            sin(eulers.y.degreesToRadians())
        ]
        
        let globalUp: vector_float3 = [0.0, 0.0, 1.0]
        
        right = simd.normalize(simd.cross(globalUp, forwards))
        
        up = simd.normalize(simd.cross(forwards, right))
        
        super.init(position: position, eulers: eulers, id: id, color: simd_float3(repeating: 1.0))
        
    }
    
    func move(amount: simd_float2) {
        position = position
            + amount[0] * [
                forwards[0],
                forwards[1],
                0.0
            ]
        
            + amount[1] * [
                right[0],
                right[1],
                0.0
            ]
    }
    
    func update() {
        
        forwards = [
            cos(eulers.y.degreesToRadians()) * cos(eulers.z.degreesToRadians()),
            cos(eulers.y.degreesToRadians()) * sin(eulers.z.degreesToRadians()),
            sin(eulers.y.degreesToRadians())
        ]
        
        let globalUp: vector_float3 = [0.0, 0.0, 1.0]
        
        right = simd.normalize(simd.cross(globalUp, forwards))
        
        up = simd.normalize(simd.cross(forwards, right))
        
    }
    
    func get_view_transform() -> simd_float4x4 {
        Matrix44.lookAt(
            eye: position,
            target: position + forwards,
            up: up
        )
    }
}
