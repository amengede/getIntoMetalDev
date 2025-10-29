#pragma once
#include <simd/simd.h>
#include <Metal/Metal.hpp>

class Vertex {
public:
    Vertex(float data[6]);

    static MTL::VertexDescriptor* getDescriptor();
private:
    float data[6];
};

class TexturedVertex {
public:

    TexturedVertex(float data[8]);

    static MTL::VertexDescriptor* getDescriptor();

private:
    float data[8];
};