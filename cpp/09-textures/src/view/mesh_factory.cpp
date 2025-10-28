#include "mesh_factory.h"
#include <stb_image.h>
#include <iostream>

MTL::Buffer* MeshFactory::buildTriangle(MTL::Device* device) {
    
    //Declare the data to send
    Vertex vertices[3] = {
        {{-0.75, -0.75, 0.0}, {1.0, 1.0, 0.0}},
        {{ 0.75, -0.75, 0.0}, {1.0, 1.0, 0.0}},
        {{  0.0,  0.75, 0.0}, {1.0, 1.0, 0.0}}
    };
    
    //Create a buffer to hold it
    MTL::Buffer* buffer = device->newBuffer(3 * sizeof(Vertex), MTL::ResourceStorageModeShared);
    
    //Upload to buffer
    // contents returns raw pointer to, well, contents
    memcpy(buffer->contents(), vertices, 3 * sizeof(Vertex));
    
    return buffer;
}

MTL::VertexDescriptor* MeshFactory::getTriangleVertexDescriptor() {

    MTL::VertexDescriptor* vertexDescriptor = MTL::VertexDescriptor::alloc()->init();
    auto attributes = vertexDescriptor->attributes();
    NS::UInteger offset = 0;
    //position: vec3
    auto positionDescriptor = attributes->object(0);
    positionDescriptor->setFormat(MTL::VertexFormat::VertexFormatFloat3);
    positionDescriptor->setBufferIndex(0);
    positionDescriptor->setOffset(offset);
    offset += 4 * sizeof(float);
    //color: vec3
    auto colorDescriptor = attributes->object(1);
    colorDescriptor->setFormat(MTL::VertexFormat::VertexFormatFloat3);
    colorDescriptor->setBufferIndex(0);
    colorDescriptor->setOffset(offset);
    offset += 4 * sizeof(float);

    auto layoutDescriptor = vertexDescriptor->layouts()->object(0);
    layoutDescriptor->setStride(offset);
    
    return vertexDescriptor;
}

Mesh MeshFactory::buildQuad(MTL::Device* device, const char* imageFilename) {
    
    Mesh mesh;
    
    //Declare the data to send
    TexturedVertex vertices[4] = {
        {{-0.75, -0.75, 0.0}, {1.0, 0.0, 0.0}, {0.0, 0.0}},
        {{ 0.75, -0.75, 0.0}, {0.0, 1.0, 0.0}, {1.0, 0.0}},
        {{ 0.75,  0.75, 0.0}, {0.0, 0.0, 1.0}, {1.0, 1.0}},
        {{-0.75,  0.75, 0.0}, {0.0, 1.0, 0.0}, {0.0, 1.0}},
    };
    NS::UInteger vertexBufferSize = 4 * sizeof(TexturedVertex);
    
    ushort indices[6] = {0, 1, 2, 2, 3, 0};
    NS::UInteger indexBufferSize = 6 * sizeof(ushort);
    
    //vertex buffer
    mesh.vertexBuffer = device->newBuffer(vertexBufferSize, MTL::ResourceStorageModeShared);
    memcpy(mesh.vertexBuffer->contents(), vertices, vertexBufferSize);
    
    //index buffer
    mesh.indexBuffer = device->newBuffer(indexBufferSize, MTL::ResourceStorageModeShared);
    memcpy(mesh.indexBuffer->contents(), indices, indexBufferSize);

    // Vertex descriptor
    MTL::VertexDescriptor* vertexDescriptor = MTL::VertexDescriptor::alloc()->init();
    auto attributes = vertexDescriptor->attributes();
    NS::UInteger offset = 0;
    //position: vec3
    auto positionDescriptor = attributes->object(0);
    positionDescriptor->setFormat(MTL::VertexFormat::VertexFormatFloat3);
    positionDescriptor->setBufferIndex(0);
    positionDescriptor->setOffset(offset);
    offset += 4 * sizeof(float);
    //color: vec3
    auto colorDescriptor = attributes->object(1);
    colorDescriptor->setFormat(MTL::VertexFormat::VertexFormatFloat3);
    colorDescriptor->setBufferIndex(0);
    colorDescriptor->setOffset(offset);
    offset += 4 * sizeof(float);
    //texCoord: vec2
    auto texCoordDescriptor = attributes->object(2);
    texCoordDescriptor->setFormat(MTL::VertexFormat::VertexFormatFloat2);
    texCoordDescriptor->setBufferIndex(0);
    texCoordDescriptor->setOffset(offset);
    offset += 4 * sizeof(float);

    auto layoutDescriptor = vertexDescriptor->layouts()->object(0);
    layoutDescriptor->setStride(offset);

    mesh.vertexDescriptor = vertexDescriptor;

    // Load image
    int w, h, channels;
    unsigned char* data = stbi_load(imageFilename, &w, &h, &channels, STBI_rgb_alpha);
    
    if (!data) {
        std::cout << "Failed to load \"" <<imageFilename << "\"" << std::endl;
    }

    // make texture and sampler
    MTL::TextureDescriptor* textureDescriptor = MTL::TextureDescriptor::alloc()->init();
    textureDescriptor->setWidth(w);
    textureDescriptor->setHeight(h);
    textureDescriptor->setPixelFormat(MTL::PixelFormat::PixelFormatRGBA8Unorm);
    textureDescriptor->setTextureType(MTL::TextureType2D);
    textureDescriptor->setMipmapLevelCount(1);
    textureDescriptor->setSampleCount(1);
    textureDescriptor->setStorageMode(MTL::StorageModeShared);
    textureDescriptor->setUsage(MTL::TextureUsageShaderRead);
    textureDescriptor->setAllowGPUOptimizedContents(true);
    mesh.texture = device->newTexture(textureDescriptor);
    MTL::Region copyRegion = MTL::Region::Make2D(0, 0, w, h);
    mesh.texture->replaceRegion(copyRegion, 0, data, 4 * w);

    MTL::SamplerDescriptor* samplerDescriptor = MTL::SamplerDescriptor::alloc()->init();
    samplerDescriptor->setMinFilter(MTL::SamplerMinMagFilterLinear);
    samplerDescriptor->setMagFilter(MTL::SamplerMinMagFilterLinear);
    samplerDescriptor->setMipFilter(MTL::SamplerMipFilterNotMipmapped);
    samplerDescriptor->setMaxAnisotropy(1);
    samplerDescriptor->setSAddressMode(MTL::SamplerAddressModeRepeat);
    samplerDescriptor->setTAddressMode(MTL::SamplerAddressModeRepeat);
    samplerDescriptor->setRAddressMode(MTL::SamplerAddressModeRepeat);
    mesh.sampler = device->newSamplerState(samplerDescriptor);

    stbi_image_free(data);
    
    return mesh;
}
