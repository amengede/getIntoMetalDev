#pragma once
#include "../config.h"

struct Mesh {
    MTL::Buffer* vertexBuffer, *indexBuffer;
    MTL::VertexDescriptor* vertexDescriptor;
};

namespace MeshFactory {
    MTL::Buffer* buildTriangle(MTL::Device* device);
    Mesh buildQuad(MTL::Device* device);
}
