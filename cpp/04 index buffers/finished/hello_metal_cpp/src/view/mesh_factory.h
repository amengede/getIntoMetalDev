//
//  mesh_factory.hpp
//  hello_metal_cpp
//
//  Created by Andrew Mengede on 18/12/2023.
//

#pragma once
#include "../config.h"

struct Mesh {
    MTL::Buffer* vertexBuffer, *indexBuffer;
};

namespace MeshFactory {
    MTL::Buffer* buildTriangle(MTL::Device* device);
    Mesh buildQuad(MTL::Device* device);
}
