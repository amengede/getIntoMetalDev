//
//  brightBillboard.swift
//  Project
//
//  Created by Andrew Mengede on 4/8/2022.
//

import Foundation

class BrightBillboard: Billboard {
    
    var t: Float
    var rotationCenter: vector_float3
    var pathRadius: Float
    var pathPhi: Float
    var angularVelocity: Float
    
    init(position: simd_float3, color: vector_float3, rotation_center: vector_float3, pathRadius: Float, pathPhi: Float, angularVelocity: Float, id: Int32) {
        
        self.t = 0
        self.rotationCenter = rotation_center
        self.pathRadius = pathRadius
        self.pathPhi = pathPhi
        self.angularVelocity = angularVelocity
        super.init(position: position, id: id, color: color);
        
    }
    
    override func update(viewerPosition: simd_float3) {
        
        position[0] = rotationCenter[0] + pathRadius * cos(t) * sin(pathPhi * .pi / 180.0);
        position[1] = rotationCenter[1] + pathRadius * sin(t) * sin(pathPhi * .pi / 180.0);
        position[2] = rotationCenter[2] + pathRadius * cos(pathPhi * .pi / 180.0);
        
        t += angularVelocity * 0.1;
        if t > (2.0 * .pi) {
            t -= 2.0 * .pi;
        }
        
        super.update(viewerPosition: viewerPosition);
    }
    
}
