//
//  LinearAlgebro.swift
//  Transformations
//
//  Created by Andrew Mengede on 20/12/21.
//

import Foundation
import simd

enum Matrix44 {
    
    static func identity() -> float4x4 {
        return float4x4 (
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        )
    }
    
    static func from(translation: simd_float3) -> float4x4 {
        return float4x4 (
            [1,                 0,              0,              0],
            [0,                 1,              0,              0],
            [0,                 0,              1,              0],
            [translation[0],    translation[1], translation[2], 1]
        )
    }
    
    static func from(rotation eulers: simd_float3) -> float4x4 {
        let gamma = eulers[0].degreesToRadians()
        let beta = eulers[1].degreesToRadians()
        let alpha = eulers[2].degreesToRadians()
        return from(zRotation: alpha) * from(yRotation: beta) * from(xRotation: gamma)
    }
    
    static func lookAt(eye: simd_float3, target: simd_float3, up: simd_float3) -> float4x4 {
        let forwards: simd_float3 = simd.normalize(target - eye)
        let right: simd_float3 = simd.normalize(simd.cross(up, forwards))
        let up2: simd_float3 = simd.normalize(simd.cross(forwards, right))
        
        
        return float4x4(
            [            -right[0],             up2[0],             forwards[0],       0],
            [            -right[1],             up2[1],             forwards[1],       0],
            [            -right[2],             up2[2],             forwards[2],       0],
            [simd.dot(right,eye), -simd.dot(up2,eye), -simd.dot(forwards,eye),       1]
        )
        
    }
    
    static func perspectiveProjection(fovy: Float, aspect: Float, near: Float, far: Float) -> float4x4 {
        
        let A = aspect / tan(fovy * .pi / 360)
        let B = 1.0 / tan(fovy * .pi / 360)
        let C = far / (far - near)
        let D = 1.0 as Float
        let E = -near * far / (far - near)
        
        return float4x4(
            [A, 0, 0, 0],
            [0, B, 0, 0],
            [0, 0, C, D],
            [0, 0, E, 0]
        )
    }
    
    static private func from(xRotation theta: Float) -> float4x4 {
        return float4x4(
            [1,           0,          0, 0],
            [0,  cos(theta), sin(theta), 0],
            [0, -sin(theta), cos(theta), 0],
            [0,           0,          0, 1]
        )
    }
    
    static private func from(yRotation theta: Float) -> float4x4 {
        return float4x4(
            [cos(theta), 0, -sin(theta), 0],
            [         0, 1,           0, 0],
            [sin(theta), 0,  cos(theta), 0],
            [         0, 0,           0, 1]
        )
    }
    
    static private func from(zRotation theta: Float) -> float4x4 {
        return float4x4(
            [ cos(theta), sin(theta), 0, 0],
            [-sin(theta), cos(theta), 0, 0],
            [          0,          0, 1, 0],
            [          0,          0, 0, 1]
        )
    }
}
