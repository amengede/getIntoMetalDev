//
//  renderer.h
//  hello_metal_cpp
//
//  Created by Andrew Mengede on 15/9/2023.
//
#pragma once

#include "../config.h"
#include "../release.h"

class Renderer
{
    public:
        explicit Renderer(MTL::Device* device);

        void draw(MTK::View* view);

    private:
        const release_ptr<MTL::Device> device;
        const release_ptr<MTL::CommandQueue> commandQueue;
};
