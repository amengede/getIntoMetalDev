//
//  view_delegate.h
//  metal_test
//
//  Created by Andrew Mengede on 13/9/2023.
//
#pragma once

#include <memory>

#include "config.h"
#include "../view/renderer.h"

class ViewDelegate : public MTK::ViewDelegate
{
    public:
        explicit ViewDelegate(MTL::Device* device);

        void drawInMTKView(MTK::View* view) override;

    private:
        const std::unique_ptr<Renderer> renderer;
};
