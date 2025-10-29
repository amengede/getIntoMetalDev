#pragma once
#include "../config.h"

/**
 * A Mesh!
 */
class Mesh {
public:

    void setVertexBuffer(MTL::Buffer* vertexBuffer);
    void setIndexCount(NS::UInteger indexCount);
    void setIndexBuffer(MTL::Buffer* indexBuffer);
    void setTexture(MTL::Texture* texture);
    void setSampler(MTL::SamplerState* sampler);
    void draw(MTL::RenderCommandEncoder* encoder);
    void release();

private:

    MTL::Buffer* vertexBuffer = nullptr, *indexBuffer = nullptr;
    MTL::Texture* texture = nullptr;
    MTL::SamplerState* sampler = nullptr;
    NS::UInteger indexCount = 0;
};