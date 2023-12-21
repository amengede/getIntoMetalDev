//
//  mesh_factory.cpp
//  hello_metal_cpp
//
//  Created by Andrew Mengede on 18/12/2023.
//

#include "mesh_factory.h"

MTL::Buffer* MeshFactory::buildTriangle(MTL::Device* device) {
    
    //Declare the data to send
    Vertex vertices[3] = {
        {{-0.75, -0.75}, {1.0, 1.0, 0.0}},
        {{ 0.75, -0.75}, {1.0, 1.0, 0.0}},
        {{  0.0,  0.75}, {1.0, 1.0, 0.0}}
    };
    
    //Create a buffer to hold it
    MTL::Buffer* buffer = device->newBuffer(3 * sizeof(Vertex), MTL::ResourceStorageModeShared);
    
    //Upload to buffer
    // contents returns raw pointer to, well, contents
    memcpy(buffer->contents(), vertices, 3 * sizeof(Vertex));
    
    return buffer;
}

Mesh MeshFactory::buildQuad(MTL::Device* device) {
    
    Mesh mesh;
    
    //Declare the data to send
    Vertex vertices[4] = {
        {{-0.75, -0.75}, {1.0, 0.0, 0.0}},
        {{ 0.75, -0.75}, {0.0, 1.0, 0.0}},
        {{ 0.75,  0.75}, {0.0, 0.0, 1.0}},
        {{-0.75,  0.75}, {0.0, 1.0, 0.0}},
    };
    
    ushort indices[6] = {0, 1, 2, 2, 3, 0};
    
    //vertex buffer
    mesh.vertexBuffer = device->newBuffer(4 * sizeof(Vertex), MTL::ResourceStorageModeShared);
    memcpy(mesh.vertexBuffer->contents(), vertices, 4 * sizeof(Vertex));
    
    //index buffer
    mesh.indexBuffer = device->newBuffer(6 * sizeof(ushort), MTL::ResourceStorageModeShared);
    memcpy(mesh.indexBuffer->contents(), indices, 6 * sizeof(ushort));
    
    return mesh;
}
