//
//  billboard.swift
//  Project
//
//  Created by Andrew Mengede on 28/7/2022.
//

import Foundation

class Billboard {
    
    var position: simd_float3
    var model: matrix_float4x4
    
    
    init(position: simd_float3) {
        
        self.position = position
        self.model = Matrix44.create_identity()
        
    }
    
    func update(viewerPosition: simd_float3) {
        
        let selfToViewer: simd_float3 = viewerPosition - position
        let theta: Float = simd.atan2(selfToViewer[1], selfToViewer[0]) * 180.0 / .pi
        let horizontalDistance: Float = sqrtf(selfToViewer[0] * selfToViewer[0] + selfToViewer[1] * selfToViewer[1])
        let phi: Float = -simd.atan2(selfToViewer[2], horizontalDistance) * 180.0 / .pi
        model = Matrix44.create_from_rotation(eulers: [0, phi, theta])
        model = Matrix44.create_from_translation(translation: position) * model
        
    }
}
