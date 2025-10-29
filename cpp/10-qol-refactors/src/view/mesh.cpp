#include "mesh.h"

void Mesh::setVertexBuffer(MTL::Buffer* vertexBuffer) {
    this->vertexBuffer = vertexBuffer;
}

void Mesh::setIndexCount(NS::UInteger indexCount) {
    this->indexCount = indexCount;
}

void Mesh::setIndexBuffer(MTL::Buffer* indexBuffer) {
    this->indexBuffer = indexBuffer;
}

void Mesh::setTexture(MTL::Texture* texture) {
    this->texture = texture;
}

void Mesh::setSampler(MTL::SamplerState* sampler) {
    this->sampler = sampler;
}

void Mesh::draw(MTL::RenderCommandEncoder* encoder) {
    encoder->setVertexBuffer(vertexBuffer, 0, 0);
    encoder->setFragmentTexture(texture, 0);
    encoder->setFragmentSamplerState(sampler, 0);
    encoder->drawIndexedPrimitives(
        MTL::PrimitiveType::PrimitiveTypeTriangle, indexCount, 
        MTL::IndexType::IndexTypeUInt16, indexBuffer, NS::UInteger(0), NS::UInteger(1));
}

void Mesh::release() {
    vertexBuffer->release();
    indexBuffer->release();
}