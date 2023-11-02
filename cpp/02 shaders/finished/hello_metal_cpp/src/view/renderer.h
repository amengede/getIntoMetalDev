//
//  renderer.h
//  hello_metal_cpp
//
//  Created by Andrew Mengede on 15/9/2023.
//

#pragma once
#include "../config.h"

class Renderer
{
    public:
        Renderer(MTL::Device* device);
        ~Renderer();
        void draw(MTK::View* view);

    private:
        void buildShaders();
        MTL::Device* device;
        MTL::CommandQueue* commandQueue;
        /*
         A render pipeline is in charge of standard graphics operations.
         Compute pipelines can also be made, but not today.
        */
        MTL::RenderPipelineState* trianglePipeline;
};
