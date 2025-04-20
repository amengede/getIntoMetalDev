//
//  renderer.cpp
//  hello_metal_cpp
//
//  Created by Andrew Mengede on 15/9/2023.
//
#include "renderer.h"

Renderer::Renderer(MTL::Device* device):
device(device->retain()),
commandQueue(device->newCommandQueue())
{}

void Renderer::draw(MTK::View* view)
{
    const release_ptr<NS::AutoreleasePool> pool(NS::AutoreleasePool::alloc()->init());

    MTL::CommandBuffer* commandBuffer = commandQueue->commandBuffer();
    MTL::RenderPassDescriptor* renderPass = view->currentRenderPassDescriptor();
    MTL::RenderCommandEncoder* encoder = commandBuffer->renderCommandEncoder(renderPass);
    encoder->endEncoding();
    commandBuffer->presentDrawable(view->currentDrawable());
    commandBuffer->commit();
}
