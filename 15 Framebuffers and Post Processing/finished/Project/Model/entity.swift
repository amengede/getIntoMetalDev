//
//  simpleComponent.swift
//  Transformations
//
//  Created by Andrew Mengede on 2/3/2022.
//

import Foundation

class Entity {
    
    var hasTransformComponent: Bool
    var position: simd_float3?
    var eulers: simd_float3?
    var model: matrix_float4x4?
    
    var hasCameraComponent: Bool
    var forwards: vector_float3?
    var right: vector_float3?
    var up: vector_float3?
    var view: matrix_float4x4?
    
    
    init() {
        
        self.hasTransformComponent = false
        self.hasCameraComponent = false
        
    }
    
    func addTransformComponent(position: simd_float3, eulers: simd_float3) {
        self.hasTransformComponent = true
        self.position = position
        self.eulers = eulers
        update()
    }
    
    func addCameraComponent(position: simd_float3, eulers: simd_float3) {
        self.hasCameraComponent = true
        self.position = position
        self.eulers = eulers
        update()
    }
    
    func strafe(rightAmount: Float, upAmount: Float) {
        position = position! + rightAmount * right! + upAmount * up!
        
        let distance: Float = simd.length(position!)
        
        moveForwards(amount: distance - 10.0)
    }
    
    func moveForwards(amount: Float) {
        position = position! + amount * forwards!
    }
    
    func move(amount: simd_float2) {
        position = position!
            + amount[0] * [
                forwards![0],
                forwards![1],
                0.0
            ]
        
            + amount[1] * [
                right![0],
                right![1],
                0.0
            ]
    }
    
    func update() {
        
        if hasTransformComponent {
            model = Matrix44.create_from_rotation(eulers: eulers!)
            model = Matrix44.create_from_translation(translation: position!) * model!
        }
        
        if hasCameraComponent {
            
            forwards = [
                cos(eulers!.y * .pi / 180.0) * cos(eulers!.z * .pi / 180.0),
                cos(eulers!.y * .pi / 180.0) * sin(eulers!.z * .pi / 180.0),
                sin(eulers!.y * .pi / 180.0)
            ]
            
            let globalUp: vector_float3 = [0.0, 0.0, 1.0]
            
            right = simd.normalize(simd.cross(globalUp, forwards!))
            
            up = simd.normalize(simd.cross(forwards!, right!))
            
            view = Matrix44.create_lookat(
                eye: position!,
                target: position! + forwards!,
                up: up!
            )
            
        }
        
    }
}
