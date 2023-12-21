//
//  renderer.h
//  hello_metal_cpp
//
//  Created by Andrew Mengede on 15/9/2023.
//

#pragma once
#include "../config.h"
#include "mesh_factory.h"

class Renderer
{
    public:
        Renderer(MTL::Device* device);
        ~Renderer();
        void draw(MTK::View* view);

    private:
        void buildMeshes();
        void buildShaders();
        MTL::RenderPipelineState* buildShader(const char* filename, const char* vertName, const char* fragName);
        MTL::Device* device;
        MTL::CommandQueue* commandQueue;
        
        MTL::RenderPipelineState* trianglePipeline, *generalPipeline;
        MTL::Buffer* triangleMesh;
        Mesh quadMesh;
};
