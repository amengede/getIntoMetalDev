//
//  view_delegate.cpp
//  metal_test
//
//  Created by Andrew Mengede on 13/9/2023.
//

#include "view_delegate.h"

ViewDelegate::ViewDelegate(MTL::Device* device)
: MTK::ViewDelegate()
, renderer(new Renderer(device))
{
}

ViewDelegate::~ViewDelegate()
{
    delete renderer;
}

void ViewDelegate::drawInMTKView(MTK::View* view)
{
    renderer->draw(view);
}
