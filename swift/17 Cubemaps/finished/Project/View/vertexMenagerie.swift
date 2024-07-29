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
    }
}
