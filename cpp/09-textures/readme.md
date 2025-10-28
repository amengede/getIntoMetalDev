# GetIntoMetalDev, C++ edition!
## Part 9: Textures

In this stage we'll add a texture to our quad. This decomposes into 7 stages:
1. Adding a new vertex struct which holds texture coordinates
1. Updating our quad vertex data
1. Adding an attribute descriptor for texture coordinates
1. Loading image data from memory
1. Creating a texture and sampler
1. Adjusting our general shader to use a texture
1. Sending the texture to the shader, drawing

### A new vertex struct
In the config header we can define a new TexturedVertex struct. Note: this is technical debt. It's a good exercise to start refactoring these files, vertex definitions should not need to be visible in a top-level file.
```
struct Vertex {
    simd::float3 pos;   //(x,y)
    simd::float3 color; //(r,g,b)
    simd::float2 texCoord; //(u,v)
};
```

### Quad vertex data
Now in view/mesh_factory.cpp we can use the new TexturedVertex struct.
```
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
```

### New Attribute descriptor appears!
We can then add a new attribute descriptor for the texture coordinate.
```
// Vertex descriptor
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
```

It's a good idea to run a quick test and see that Metal is interpretting the data correctly!
We're now at a point where the triangle and quad have different vertex formats. As a quick fix,
let's define a helper function to get the triangle's format.
```
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
```
It should go without saying that this is massive technical debt and should not be done in a real engine!

Now we can set up the pipelines appropriately.
in view/renderer.cpp:
```
void Renderer::buildShaders() {

    PipelineBuilder* builder = new PipelineBuilder(device);
    
    builder->set_vertex_descriptor(MeshFactory::getTriangleVertexDescriptor());
    builder->set_filename("../src/shaders/triangle.metal");
    builder->set_vertex_entry_point("vertexMain");
    builder->set_fragment_entry_point("fragmentMain");
    trianglePipeline = builder->build();

    builder->set_vertex_descriptor(quadMesh.vertexDescriptor);
    builder->set_filename("../src/shaders/general_shader.metal");
    builder->set_vertex_entry_point("vertexMainGeneral");
    builder->set_fragment_entry_point("fragmentMainGeneral");
    generalPipeline = builder->build();
    
    delete builder;
}
```
Then we'll set up the general shader so it knows about texture coordinates (but ignores them).
in shaders/general_shader.metal:
```
struct VertexInput {
    float3 position [[attribute(0)]];
    float3 color [[attribute(1)]];
    float2 texCoord [[attribute(2)]];
};
```

Good thing we tried that! We learned:
1. Vertex Attribute Descriptors need to have offsets of 4 floats. Why? reasons.
1. The triangle shader is old, let's replace it with the general shader, but untextured.
1. The quad's drawing function is taking 6 as both its index count and instance count, meaning the same quad is drawn 6 times in place!

### Loading image data from memory
Loading images is the same in every C++ program, we'll use stb image. The only thing to remember here is to define a single implementation point.
in view/image.cpp:
```
#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>
```

Now we'll go back and modify our Mesh struct to add a metal texture and sampler.
```
struct Mesh {
    MTL::Buffer* vertexBuffer, *indexBuffer;
    MTL::VertexDescriptor* vertexDescriptor;
    MTL::Texture* texture;
    MTL::SamplerState* sampler;
};
```

Our loader will then take a filename and load the image data!
```
#include "mesh_factory.h"
#include <stb_image.h>
#include <iostream>

// ...

Mesh MeshFactory::buildQuad(MTL::Device* device, const char* imageFilename) {
    
    Mesh mesh;
    
    //Declare the data to send
    // ...

    // Load image
    int w, h, channels;
    unsigned char* data = stbi_load(imageFilename, &w, &h, &channels, STBI_rgb_alpha);
    
    if (!data) {
        std::cout << "Failed to load \"" <<imageFilename << "\"" << std::endl;
    }

    // make texture and sampler

    stbi_image_free(data);
    
    return mesh;
}
```

### Creating a texture and sampler
Mostly this consists of reading and guessing from the source code...
```
Mesh MeshFactory::buildQuad(MTL::Device* device, const char* imageFilename) {
    
    // ...

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
```

### Adjusting our general shader to use a texture
```
#include <metal_stdlib>
using namespace metal;

struct VertexInput {
    float3 position [[attribute(0)]];
    float3 color [[attribute(1)]];
    float2 texCoord [[attribute(2)]];
};

struct VertexOutput {
    float4 position [[position]];
    half3 color;
    float2 texCoord;
};

VertexOutput vertex vertexMainGeneral(
    VertexInput input [[stage_in]],
    constant float4x4& transform [[buffer(1)]],
    constant float4x4& projection [[buffer(2)]],
    constant float4x4& view [[buffer(3)]]) {
    
    VertexOutput payload;
    half3 pos = half3(input.position);
    payload.position = float4(half4x4(projection) * half4x4(view) * half4x4(transform) * half4(pos, 1.0));
    payload.color = half3(input.color);
    payload.texCoord = input.texCoord;
    return payload;
}

half4 fragment fragmentMainGeneral(VertexOutput frag [[stage_in]],
    texture2d<float> material [[texture(0)]],
    sampler samplerObject [[sampler(0)]]) {
    return half4(material.sample(samplerObject, frag.texCoord)) * half4(frag.color, 1.0);
}
```

### Sending the texture to the shader, drawing
```
encoder->setVertexBuffer(quadMesh.vertexBuffer, 0, 0);
encoder->setFragmentTexture(quadMesh.texture, 0);
encoder->setFragmentSamplerState(quadMesh.sampler, 0);
encoder->drawIndexedPrimitives(
    MTL::PrimitiveType::PrimitiveTypeTriangle, NS::UInteger(6), 
    MTL::IndexType::IndexTypeUInt16, quadMesh.indexBuffer, NS::UInteger(0), NS::UInteger(1));
```