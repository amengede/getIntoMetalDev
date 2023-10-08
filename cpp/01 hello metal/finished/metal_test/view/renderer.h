//
//  renderer.h
//  metal_test
//
//  Created by Andrew Mengede on 13/9/2023.
//

#pragma once
#include "config.h"

class Renderer
{
    public:
        Renderer( MTL::Device* device );
        ~Renderer();
        void draw( MTK::View* view );

    private:
        MTL::Device* device;
        MTL::CommandQueue* commandQueue;
};
