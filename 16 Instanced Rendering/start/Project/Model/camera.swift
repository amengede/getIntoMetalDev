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
    
    
    override init(position: simd_float3, eulers: simd_float3) {
        
        forwards = [
            cos(eulers.y * .pi / 180.0) * cos(eulers.z * .pi / 180.0),
            cos(eulers.y * .pi / 180.0) * sin(eulers.z * .pi / 180.0),
            sin(eulers.y * .pi / 180.0)
        ];
        
        let globalUp: vector_float3 = [0.0, 0.0, 1.0];
        
        right = simd.normalize(simd.cross(globalUp, forwards));
        
        up = simd.normalize(simd.cross(forwards, right));
        
        super.init(position: position, eulers: eulers);
        
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
            ];
    }
    
    override func update() {
        
        forwards = [
            cos(eulers.y * .pi / 180.0) * cos(eulers.z * .pi / 180.0),
            cos(eulers.y * .pi / 180.0) * sin(eulers.z * .pi / 180.0),
            sin(eulers.y * .pi / 180.0)
        ];
        
        let globalUp: vector_float3 = [0.0, 0.0, 1.0];
        
        right = simd.normalize(simd.cross(globalUp, forwards));
        
        up = simd.normalize(simd.cross(forwards, right));
        
    }
    
    func get_view_transform() -> simd_float4x4 {
        
        return Matrix44.create_lookat(
            eye: position,
            target: position + forwards,
            up: up
        );
        
    }
}
