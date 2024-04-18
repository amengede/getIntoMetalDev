//
//  MeshFactory.swift
//  HelloTriangle
//
//  Created by Andrew Mengede on 18/4/2024.
//

import Metal

struct Mesh {
    let vertexBuffer: MTLBuffer;
    let indexBuffer: MTLBuffer;
    let indexCount: Int;
};

class MeshFactory {
    
    let device: MTLDevice
    
    init(device: MTLDevice) {
        self.device = device
    }
    
    func make_triangle() -> MTLBuffer {
        
        let vertices : [Vertex] = [
            Vertex(position: [-0.75, -0.75, 0.0, 1.0], color: [1, 0, 0]),
            Vertex(position: [ 0.75, -0.75, 0.0, 1.0], color: [0, 1, 0]),
            Vertex(position: [  0.0,  0.75, 0.0, 1.0], color: [0, 0, 1])
        ]
        
        return device.makeBuffer(bytes: vertices,
                                 length: vertices.count * MemoryLayout<Vertex>.stride,
                                 options: [])!
    }
    
    func make_quad() -> Mesh {
        
        let vertices : [Vertex] = [
            Vertex(position: [-0.75, -0.75, 0.0, 1.0], color: [1, 0, 0]),
            Vertex(position: [ 0.75, -0.75, 0.0, 1.0], color: [0, 1, 0]),
            Vertex(position: [ 0.75,  0.75, 0.0, 1.0], color: [0, 0, 1]),
            Vertex(position: [-0.75,  0.75, 0.0, 1.0], color: [1, 1, 1]),
        ]
        
        let vertexBuffer = device.makeBuffer(bytes: vertices,
                                 length: vertices.count * MemoryLayout<Vertex>.stride,
                                 options: [])!
        
        let indices : [UInt16] = [
            0, 1, 2, 2, 3, 0
        ]
        
        let indexBuffer = device.makeBuffer(bytes: indices,
                                 length: indices.count * MemoryLayout<UInt16>.stride,
                                 options: [])!
        
        return Mesh(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, indexCount: 6)
    }
    
}
