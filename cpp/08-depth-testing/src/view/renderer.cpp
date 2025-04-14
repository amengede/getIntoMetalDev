#include "renderer.h"
#include "../backend/mtlm.h"
#include "pipeline_factory.h"

Renderer::Renderer(MTL::Device* device, CA::MetalLayer* metalLayer):
device(device->retain()),
metalLayer(metalLayer->retain()),
commandQueue(device->newCommandQueue()->retain()) {
    buildMeshes();
    buildShaders();
    buildDepthStencilState();
}

Renderer::~Renderer() {
    quadMesh.vertexBuffer->release();
    quadMesh.indexBuffer->release();
    triangleMesh->release();
    trianglePipeline->release();
    generalPipeline->release();
    commandQueue->release();
    device->release();
}

void Renderer::buildMeshes() {
    triangleMesh = MeshFactory::buildTriangle(device);
    quadMesh = MeshFactory::buildQuad(device);
}

void Renderer::buildShaders() {

    PipelineBuilder* builder = new PipelineBuilder(device);
    
    builder->set_vertex_descriptor(quadMesh.vertexDescriptor);
    builder->set_filename("../src/shaders/triangle.metal");
    builder->set_vertex_entry_point("vertexMain");
    builder->set_fragment_entry_point("fragmentMain");
    trianglePipeline = builder->build();

    builder->set_filename("../src/shaders/general_shader.metal");
    builder->set_vertex_entry_point("vertexMainGeneral");
    builder->set_fragment_entry_point("fragmentMainGeneral");
    generalPipeline = builder->build();
    
    delete builder;
}

void Renderer::buildDepthStencilState() {

    MTL::DepthStencilDescriptor* depthInfo = MTL::DepthStencilDescriptor::alloc()->init();
    depthInfo->setDepthCompareFunction(MTL::CompareFunction::CompareFunctionLess);
    depthInfo->setDepthWriteEnabled(true);

    depthState = device->newDepthStencilState(depthInfo);
}

void Renderer::update(const simd::float4x4& view) {
    
    t += 1.0f;
    if (t > 360) {
        t -= 360.0f;
    }
    
    NS::AutoreleasePool* pool = NS::AutoreleasePool::alloc()->init();
    
    MTL::CommandBuffer* commandBuffer = commandQueue->commandBuffer();
    MTL::RenderPassDescriptor* renderPass = MTL::RenderPassDescriptor::alloc()->init();

    drawableArea = metalLayer->nextDrawable();
    MTL::RenderPassColorAttachmentDescriptor* colorAttachment = renderPass->colorAttachments()->object(0);
    colorAttachment->setTexture(drawableArea->texture());
    colorAttachment->setLoadAction(MTL::LoadActionClear);
    colorAttachment->setClearColor(MTL::ClearColor(0.75f, 0.25f, 0.125f, 1.0f));
    colorAttachment->setStoreAction(MTL::StoreActionStore);

    MTL::RenderPassDepthAttachmentDescriptor* depthAttachment = renderPass->depthAttachment();
    depthAttachment->setClearDepth(1.0f);

    MTL::RenderCommandEncoder* encoder = commandBuffer->renderCommandEncoder(renderPass);
    
    encoder->setRenderPipelineState(generalPipeline);
    encoder->setDepthStencilState(depthState);

    simd::float4x4 projection = mtlm::perspective_projection(45.0f, 4.0f/3.0f, 0.1f, 100.0f);
    encoder->setVertexBytes(&projection, sizeof(simd::float4x4), 2);

    encoder->setVertexBytes(&view, sizeof(simd::float4x4), 3);

    simd::float4x4 transform = mtlm::translation({0.0f, 0.0f, 3.0f});
    encoder->setVertexBytes(&transform, sizeof(simd::float4x4), 1);

    encoder->setVertexBuffer(quadMesh.vertexBuffer, 0, 0);
    encoder->drawIndexedPrimitives(MTL::PrimitiveType::PrimitiveTypeTriangle, NS::UInteger(6), MTL::IndexType::IndexTypeUInt16, quadMesh.indexBuffer, NS::UInteger(0), NS::UInteger(6));
    
    transform = mtlm::translation({0.5f, 0.5f, 2.0f}) * mtlm::z_rotation(t) * mtlm::scale(0.1f);
    encoder->setVertexBytes(&transform, sizeof(simd::float4x4), 1);

    encoder->setVertexBuffer(triangleMesh, 0, 0);
    encoder->drawPrimitives(MTL::PrimitiveType::PrimitiveTypeTriangle, NS::UInteger(0), NS::UInteger(3));
    
     
    encoder->endEncoding();
    commandBuffer->presentDrawable(drawableArea);
    commandBuffer->commit();
    
    pool->release();
}
