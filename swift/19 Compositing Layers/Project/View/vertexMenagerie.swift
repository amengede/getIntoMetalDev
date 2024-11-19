//
//  vertexMenagerie.swift
//  Project
//
//  Created by Andrew Mengede on 11/10/2022.
//

import MetalKit

class vertexMenagerie {
    
    var offset: Int32 = 0
    var firstVertices: [Int32:Int32] = [:]
    var vertexCounts: [Int32:Int32] = [:]
    var data: [Vertex] = []
    var vertexBuffer: MTLBuffer?
    
    func consume(mesh: ObjMesh, meshType: Int32) {
        firstVertices[meshType] = offset
        vertexCounts[meshType] = Int32(mesh.buffer.count)
        
        data.append(contentsOf: mesh.buffer)
        offset += vertexCounts[meshType]!
        
        //print(firstVertices)
    }
    
    func finalize(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: data, length: data.count * MemoryLayout<Vertex>.stride)
        data = []
    }
    
    func getVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor: MTLVertexDescriptor = MTLVertexDescriptor()
        var offset: Int = 0
        
        //position
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].offset = offset
        vertexDescriptor.attributes[0].bufferIndex = 0
        offset += MemoryLayout<SIMD4<Float>>.stride
        //texCoord
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = offset
        vertexDescriptor.attributes[1].bufferIndex = 0
        offset += MemoryLayout<SIMD2<Float>>.stride
        //normal
        vertexDescriptor.attributes[2].format = .float3
        vertexDescriptor.attributes[2].offset = offset
        vertexDescriptor.attributes[2].bufferIndex = 0
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        vertexDescriptor.layouts[0].stride = offset
        
        return vertexDescriptor
    }
}
