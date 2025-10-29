#include "mesh_factory.h"
#include <stb_image.h>
#include <iostream>
#include "vertex_formats.h"

MTL::Buffer* MeshFactory::buildTriangle(MTL::Device* device) {
    
    //Declare the data to send
    Vertex vertices[3] = {
        {(float[6]){-0.75, -0.75, 0.0, 1.0, 1.0, 0.0}},
        {(float[6]){ 0.75, -0.75, 0.0, 1.0, 1.0, 0.0}},
        {(float[6]){ 0.0,   0.75, 0.0, 1.0, 1.0, 0.0}}
    };
    
    //Create a buffer to hold it
    MTL::Buffer* buffer = device->newBuffer(3 * sizeof(Vertex), MTL::ResourceStorageModeShared);
    
    //Upload to buffer
    // contents returns raw pointer to, well, contents
    memcpy(buffer->contents(), vertices, 3 * sizeof(Vertex));
    
    return buffer;
}

Mesh MeshFactory::buildQuad(MTL::Device* device, const char* imageFilename) {
    
    Mesh mesh;
    
    //Declare the data to send
    TexturedVertex vertices[4] = {
        {(float[8]){-0.75, -0.75, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0}},
        {(float[8]){ 0.75, -0.75, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0}},
        {(float[8]){ 0.75,  0.75, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0}},
        {(float[8]){-0.75,  0.75, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0}},
    };
    NS::UInteger vertexBufferSize = 4 * sizeof(TexturedVertex);
    
    ushort indices[6] = {0, 1, 2, 2, 3, 0};
    NS::UInteger indexBufferSize = 6 * sizeof(ushort);
    
    //vertex buffer
    MTL::Buffer* vertexBuffer = device->newBuffer(vertexBufferSize, MTL::ResourceStorageModeShared);
    memcpy(vertexBuffer->contents(), vertices, vertexBufferSize);
    mesh.setVertexBuffer(vertexBuffer);
    
    //index buffer
    MTL::Buffer* indexBuffer = device->newBuffer(indexBufferSize, MTL::ResourceStorageModeShared);
    memcpy(indexBuffer->contents(), indices, indexBufferSize);
    mesh.setIndexBuffer(indexBuffer);
    mesh.setIndexCount(6);

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
    MTL::Texture* texture = device->newTexture(textureDescriptor);
    MTL::Region copyRegion = MTL::Region::Make2D(0, 0, w, h);
    texture->replaceRegion(copyRegion, 0, data, 4 * w);
    mesh.setTexture(texture);

    MTL::SamplerDescriptor* samplerDescriptor = MTL::SamplerDescriptor::alloc()->init();
    samplerDescriptor->setMinFilter(MTL::SamplerMinMagFilterLinear);
    samplerDescriptor->setMagFilter(MTL::SamplerMinMagFilterLinear);
    samplerDescriptor->setMipFilter(MTL::SamplerMipFilterNotMipmapped);
    samplerDescriptor->setMaxAnisotropy(1);
    samplerDescriptor->setSAddressMode(MTL::SamplerAddressModeRepeat);
    samplerDescriptor->setTAddressMode(MTL::SamplerAddressModeRepeat);
    samplerDescriptor->setRAddressMode(MTL::SamplerAddressModeRepeat);
    mesh.setSampler(device->newSamplerState(samplerDescriptor));

    stbi_image_free(data);
    
    return mesh;
}
