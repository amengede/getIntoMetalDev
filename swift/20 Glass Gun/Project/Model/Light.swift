//
//  Light.swift
//  Project
//
//  Created by Andrew Mengede on 3/7/2022.
//

import Foundation

class Light {
    
    var type: lightType
    var position: simd_float3?
    var eulers: simd_float3?
    var forwards: vector_float3?
    var color: vector_float3
    var t: Float = 0.0
    var rotationCenter: vector_float3?
    var pathRadius: Float?
    var pathPhi: Float?
    var eulerVelocity: vector_float3?
    var angularVelocity: Float = 0.0
    
    
    init(color: vector_float3) {
        
        self.type = UNDEFINED
        self.color = color
        
    }
    
    func declareDirectional(eulers: simd_float3) {
        self.type = DIRECTIONAL
        self.eulers = eulers
    }
    
    func declareSpotlight(
        position: simd_float3, eulers: simd_float3,
        eulerVelocity: vector_float3
    ) {
        self.type = SPOTLIGHT
        self.position = position
        self.eulers = eulers
        self.t = 0.0
        self.eulerVelocity = eulerVelocity
    }
    
    func declarePointlight(
        rotationCenter: vector_float3, pathRadius: Float,
        pathPhi: Float, angularVelocity: Float
    ) {
        self.type = POINTLIGHT
        self.rotationCenter = rotationCenter
        self.pathRadius = pathRadius
        self.pathPhi = pathPhi
        self.t = 0.0
        self.angularVelocity = angularVelocity
        self.position = rotationCenter
    }
    
    func update() {
            
        if type == DIRECTIONAL {
                
            forwards = [
                cos(eulers![2].degreesToRadians()) * sin(eulers![1].degreesToRadians()),
                sin(eulers![2].degreesToRadians()) * sin(eulers![1].degreesToRadians()),
                cos(eulers![1].degreesToRadians())
            ]
                
        } else if type == SPOTLIGHT {
            
            eulers![1] += 1
            if (eulers![1] > 360) {
                eulers![1] -= 360
            }
            
            forwards = [
                cos(eulers![2].degreesToRadians()) * sin(eulers![1].degreesToRadians()),
                sin(eulers![2].degreesToRadians()) * sin(eulers![1].degreesToRadians()),
                cos(eulers![1].degreesToRadians())
            ]
            
        } else if type == POINTLIGHT {
            position![0] = rotationCenter![0] + pathRadius! * cos(t) * sin(pathPhi!.degreesToRadians())
            position![1] = rotationCenter![1] + pathRadius! * sin(t) * sin(pathPhi!.degreesToRadians())
            position![2] = rotationCenter![2] + pathRadius! * cos(pathPhi!.degreesToRadians())
            
            t += angularVelocity * 0.1
            t = t.truncatingRemainder(dividingBy: 2 * .pi)
        }
        
    }
}
