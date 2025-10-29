#include "vertex_formats.h"

Vertex::Vertex(float data[6]) {
    for (int i = 0; i < 6; ++i) {
        this->data[i] = data[i];
    }
}

MTL::VertexDescriptor* Vertex::getDescriptor() {
    MTL::VertexDescriptor* vertexDescriptor = MTL::VertexDescriptor::alloc()->init();
    auto attributes = vertexDescriptor->attributes();
    NS::UInteger offset = 0;
    //position: vec3
    auto positionDescriptor = attributes->object(0);
    positionDescriptor->setFormat(MTL::VertexFormat::VertexFormatFloat3);
    positionDescriptor->setBufferIndex(0);
    positionDescriptor->setOffset(offset);
    offset += 3 * sizeof(float);
    //color: vec3
    auto colorDescriptor = attributes->object(1);
    colorDescriptor->setFormat(MTL::VertexFormat::VertexFormatFloat3);
    colorDescriptor->setBufferIndex(0);
    colorDescriptor->setOffset(offset);
    offset += 3 * sizeof(float);

    auto layoutDescriptor = vertexDescriptor->layouts()->object(0);
    layoutDescriptor->setStride(offset);
    
    return vertexDescriptor;
}

TexturedVertex::TexturedVertex(float data[8]) {
    for (int i = 0; i < 8; ++i) {
        this->data[i] = data[i];
    }
}

MTL::VertexDescriptor* TexturedVertex::getDescriptor() {
    MTL::VertexDescriptor* vertexDescriptor = MTL::VertexDescriptor::alloc()->init();
    auto attributes = vertexDescriptor->attributes();
    NS::UInteger offset = 0;
    //position: vec3
    auto positionDescriptor = attributes->object(0);
    positionDescriptor->setFormat(MTL::VertexFormat::VertexFormatFloat3);
    positionDescriptor->setBufferIndex(0);
    positionDescriptor->setOffset(offset);
    offset += 3 * sizeof(float);
    //color: vec3
    auto colorDescriptor = attributes->object(1);
    colorDescriptor->setFormat(MTL::VertexFormat::VertexFormatFloat3);
    colorDescriptor->setBufferIndex(0);
    colorDescriptor->setOffset(offset);
    offset += 3 * sizeof(float);
    //texCoord: vec2
    auto texCoordDescriptor = attributes->object(2);
    texCoordDescriptor->setFormat(MTL::VertexFormat::VertexFormatFloat2);
    texCoordDescriptor->setBufferIndex(0);
    texCoordDescriptor->setOffset(offset);
    offset += 2 * sizeof(float);

    auto layoutDescriptor = vertexDescriptor->layouts()->object(0);
    layoutDescriptor->setStride(offset);
    
    return vertexDescriptor;
}