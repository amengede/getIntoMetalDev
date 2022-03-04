//
//  LinearAlgebro.swift
//  Transformations
//
//  Created by Andrew Mengede on 20/12/21.
//

import Foundation
import simd

class Matrix44{
    
    static func create_identity() -> float4x4 {
        return float4x4 (
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        )
    }
    
    static func create_from_translation(translation: simd_float3) -> float4x4 {
        return float4x4 (
            [1,                 0,              0,              0],
            [0,                 1,              0,              0],
            [0,                 0,              1,              0],
            [translation[0],    translation[1], translation[2], 1]
        )
    }
    
    static func create_from_rotation(eulers: simd_float3) -> float4x4 {
        let gamma: Float = eulers[0] * .pi / 180.0
        let beta: Float = eulers[1] * .pi / 180.0
        let alpha: Float = eulers[2] * .pi / 180.0
        return create_from_z_rotation(theta: alpha) * create_from_y_rotation(theta: beta) * create_from_x_rotation(theta: gamma)
    }
    
    static func create_lookat(eye: simd_float3, target: simd_float3, up: simd_float3) -> float4x4 {
        let forwards: simd_float3 = simd.normalize(target - eye)
        let right: simd_float3 = simd.normalize(simd.cross(up, forwards))
        let up2: simd_float3 = simd.normalize(simd.cross(forwards, right))
        
        
        return float4x4(
            [            right[0],             up2[0],             forwards[0],       0],
            [            right[1],             up2[1],             forwards[1],       0],
            [            right[2],             up2[2],             forwards[2],       0],
            [-simd.dot(right,eye), -simd.dot(up2,eye), -simd.dot(forwards,eye),       1]
        )
        
    }
    
    static func create_perspective_projection(fovy: Float, aspect: Float, near: Float, far: Float) -> float4x4 {
        
        let A: Float = aspect * 1 / tan(fovy * .pi / 360)
        let B: Float = 1 / tan(fovy * .pi / 360)
        let C: Float = far / (far - near)
        let D: Float = 1
        let E: Float = -near * far / (far - near)
        
        return float4x4(
            [A, 0, 0, 0],
            [0, B, 0, 0],
            [0, 0, C, D],
            [0, 0, E, 0]
        )
    }
    
    static private func create_from_x_rotation(theta: Float) -> float4x4 {
        return float4x4(
            [1,           0,          0, 0],
            [0,  cos(theta), sin(theta), 0],
            [0, -sin(theta), cos(theta), 0],
            [0,           0,          0, 1]
        )
    }
    
    static private func create_from_y_rotation(theta: Float) -> float4x4 {
        return float4x4(
            [cos(theta), 0, -sin(theta), 0],
            [         0, 1,           0, 0],
            [sin(theta), 0,  cos(theta), 0],
            [         0, 0,           0, 1]
        )
    }
    
    static private func create_from_z_rotation(theta: Float) -> float4x4 {
        return float4x4(
            [ cos(theta), sin(theta), 0, 0],
            [-sin(theta), cos(theta), 0, 0],
            [          0,          0, 1, 0],
            [          0,          0, 0, 1]
        )
    }
}
