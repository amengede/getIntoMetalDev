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
        Renderer(MTL::Device* device, CA::MetalLayer* metalLayer);
        ~Renderer();
        void update();

    private:
        void buildMeshes();
        void buildShaders();
        MTL::Device* device;
        CA::MetalLayer* metalLayer;
        CA::MetalDrawable* drawableArea;
        MTL::CommandQueue* commandQueue;
        
        MTL::RenderPipelineState* trianglePipeline, *generalPipeline;
        MTL::Buffer* triangleMesh;
        Mesh quadMesh;
    
    float t = 0.0f;
};