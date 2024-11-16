//
//  screenQuad.swift
//  Project
//
//  Created by Andrew Mengede on 14/4/2023.
//

import MetalKit

class ScreenQuad {
    
    var vertexBuffer: MTLBuffer?
    var vertexCount: Int
    
    init(device: MTLDevice) {
        let data: [SimpleVertex] = [
            SimpleVertex(position: [-1.0, -1.0]),
            SimpleVertex(position: [ 1.0, -1.0]),
            SimpleVertex(position: [ 1.0,  1.0]),
            
            SimpleVertex(position: [ 1.0,  1.0]),
            SimpleVertex(position: [-1.0,  1.0]),
            SimpleVertex(position: [-1.0, -1.0])
        ];
        vertexBuffer = device.makeBuffer(bytes: data, length: data.count * MemoryLayout<SimpleVertex>.stride);
        vertexCount = 6;
    }
    
    func getVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor: MTLVertexDescriptor = MTLVertexDescriptor()
        var offset = 0
        
        //position
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].offset = offset
        vertexDescriptor.attributes[0].bufferIndex = 0
        offset += MemoryLayout<SIMD2<Float>>.stride
        
        vertexDescriptor.layouts[0].stride = offset
        
        return vertexDescriptor
    }
}
