//
//  simpleComponent.swift
//  Transformations
//
//  Created by Andrew Mengede on 2/3/2022.
//

import Foundation

class SimpleComponent {
    
    var position: simd_float3
    var eulers: simd_float3
    
    init(position: simd_float3, eulers: simd_float3) {
        
        self.position = position
        self.eulers = eulers
        
    }
}
