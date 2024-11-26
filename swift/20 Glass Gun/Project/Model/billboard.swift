//
//  billboard.swift
//  Project
//
//  Created by Andrew Mengede on 28/7/2022.
//

import Foundation

class Billboard: Entity {
    
    init(position: simd_float3, id: Int32, color: simd_float3) {
        
        super.init(position: position, eulers: [0,0,0], id: id, color: color);
    }
    
    func update(viewerPosition: simd_float3) {
        
        let selfToViewer: simd_float3 = viewerPosition - position;
        eulers.z = simd.atan2(selfToViewer[1], selfToViewer[0]) * 180.0 / .pi;
        
        let horizontalDistance: Float = sqrtf(selfToViewer[0] * selfToViewer[0] + selfToViewer[1] * selfToViewer[1]);
        eulers.y = -simd.atan2(selfToViewer[2], horizontalDistance) * 180.0 / .pi;
        
    }
}
