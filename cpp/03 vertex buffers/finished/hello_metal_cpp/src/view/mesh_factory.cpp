//
//  mesh_factory.cpp
//  hello_metal_cpp
//
//  Created by Andrew Mengede on 18/12/2023.
//

#include "mesh_factory.h"

MTL::Buffer* MeshFactory::build_triangle(MTL::Device* device) {
    
    //Declare the data to send
    Vertex vertices[3] = {
        {{-0.75, -0.75}, {1.0, 0.0, 0.0}},
        {{ 0.75, -0.75}, {0.0, 1.0, 0.0}},
        {{  0.0,  0.75}, {0.0, 0.0, 1.0}}
    };
    
    //Create a buffer to hold it
    MTL::Buffer* buffer = device->newBuffer(3 * sizeof(Vertex), MTL::ResourceStorageModeShared);
    
    //Upload to buffer
    // contents returns raw pointer to, well, contents
    memcpy(buffer->contents(), vertices, 3 * sizeof(Vertex));
    
    return buffer;
}
