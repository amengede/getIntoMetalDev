//
//  vertexMenagerie.swift
//  Project
//
//  Created by Andrew Mengede on 11/10/2022.
//

import MetalKit

class vertexMenagerie {
    
    var offset: Int = 0
    var firstVertices: [Int:Int] = [:]
    var vertexCounts: [Int:Int] = [:]
    var data: [Vertex] = []
    var vertexBuffer: MTLBuffer?
    
    func consume(mesh: ObjMesh, meshType: Int) {
        firstVertices[meshType] = offset
        vertexCounts[meshType] = mesh.buffer.count
        
        data.append(contentsOf: mesh.buffer)
        offset += vertexCounts[meshType]!
    }
    
    func finalize(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: data, length: data.count * MemoryLayout<Vertex>.stride)
    }
}
