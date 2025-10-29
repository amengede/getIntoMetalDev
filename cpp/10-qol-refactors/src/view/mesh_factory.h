#pragma once
#include "../config.h"
#include "mesh.h"

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
     * @brief Build a quad mesh
     * @param device metal device
     * @param imageFilename filename for the mesh
     */
    Mesh buildQuad(MTL::Device* device, const char* imageFilename);
}
