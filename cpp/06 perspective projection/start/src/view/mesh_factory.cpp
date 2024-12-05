#include "mesh_factory.h"

MTL::Buffer* MeshFactory::buildTriangle(MTL::Device* device) {
    
    //Declare the data to send
    Vertex vertices[3] = {
        {{-0.75, -0.75}, {1.0, 1.0, 0.0}},
        {{ 0.75, -0.75}, {1.0, 1.0, 0.0}},
        {{  0.0,  0.75}, {1.0, 1.0, 0.0}}
    };
    
    //Create a buffer to hold it
    MTL::Buffer* buffer = device->newBuffer(3 * sizeof(Vertex), MTL::ResourceStorageModeShared);
    
    //Upload to buffer
    // contents returns raw pointer to, well, contents
    memcpy(buffer->contents(), vertices, 3 * sizeof(Vertex));
    
    return buffer;
}

Mesh MeshFactory::buildQuad(MTL::Device* device) {
    
    Mesh mesh;
    
    //Declare the data to send
    Vertex vertices[4] = {
        {{-0.75, -0.75}, {1.0, 0.0, 0.0}},
        {{ 0.75, -0.75}, {0.0, 1.0, 0.0}},
        {{ 0.75,  0.75}, {0.0, 0.0, 1.0}},
        {{-0.75,  0.75}, {0.0, 1.0, 0.0}},
    };
    
    ushort indices[6] = {0, 1, 2, 2, 3, 0};
    
    //vertex buffer
    mesh.vertexBuffer = device->newBuffer(4 * sizeof(Vertex), MTL::ResourceStorageModeShared);
    memcpy(mesh.vertexBuffer->contents(), vertices, 4 * sizeof(Vertex));
    
    //index buffer
    mesh.indexBuffer = device->newBuffer(6 * sizeof(ushort), MTL::ResourceStorageModeShared);
    memcpy(mesh.indexBuffer->contents(), indices, 6 * sizeof(ushort));

    // Vertex descriptor
    MTL::VertexDescriptor* vertexDescriptor = MTL::VertexDescriptor::alloc()->init();
    auto attributes = vertexDescriptor->attributes();
    //position: vec2
    auto positionDescriptor = attributes->object(0);
    positionDescriptor->setFormat(MTL::VertexFormat::VertexFormatFloat2);
    positionDescriptor->setBufferIndex(0);
    positionDescriptor->setOffset(0);
    //color: vec3
    auto colorDescriptor = attributes->object(1);
    colorDescriptor->setFormat(MTL::VertexFormat::VertexFormatFloat3);
    colorDescriptor->setBufferIndex(0);
    colorDescriptor->setOffset(4 * sizeof(float));

    auto layoutDescriptor = vertexDescriptor->layouts()->object(0);
    layoutDescriptor->setStride(8 * sizeof(float));

    mesh.vertexDescriptor = vertexDescriptor;
    
    return mesh;
}
