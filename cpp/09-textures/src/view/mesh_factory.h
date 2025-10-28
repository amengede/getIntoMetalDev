#pragma once
#include "../config.h"

/**
 * A Mesh!
 */
struct Mesh {
    MTL::Buffer* vertexBuffer, *indexBuffer;
    MTL::VertexDescriptor* vertexDescriptor;
    MTL::Texture* texture;
    MTL::SamplerState* sampler;
};

/**
 * @brief I wonder what these functions build...
 */
namespace MeshFactory {

    /**
     * @brief build a triangle
     * @param device Metal device
     */
    MTL::Buffer* buildTriangle(MTL::Device* device);

    /**
     * @brief get the vertex descriptor for the triangle mesh
     */
    MTL::VertexDescriptor* getTriangleVertexDescriptor();

    /**
     * @brief Build a quad mesh
     * @param device metal device
     * @param imageFilename filename for the mesh
     */
    Mesh buildQuad(MTL::Device* device, const char* imageFilename);
}
