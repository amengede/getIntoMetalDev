//
//  renderer.cpp
//  hello_metal_cpp
//
//  Created by Andrew Mengede on 15/9/2023.
//

#include "renderer.h"

Renderer::Renderer(MTL::Device* device):
device(device->retain())
{
    commandQueue = device->newCommandQueue();
    buildShaders();
}

Renderer::~Renderer() {
    commandQueue->release();
    device->release();
}

void Renderer::buildShaders() {
    
    //Read the source code from the file.
    //std::cout << "---- Reading File ----" << std::endl;
    std::ifstream file;
    file.open("shaders/triangle.metal");
    std::stringstream reader;
    reader << file.rdbuf();
    std::string raw_string = reader.str();
    NS::String* source_code = NS::String::string(
        raw_string.c_str(), NS::StringEncoding::UTF8StringEncoding);
    //std::cout << raw_string;
    
    //A Metal Library constructs functions from source code
    NS::Error* error = nullptr;
    MTL::CompileOptions* options = nullptr;
    MTL::Library* library = device->newLibrary(source_code, options, &error);
    if (!library) {
        std::cout << error->localizedDescription()->utf8String() << std::endl;
    }
    
    NS::String* vertexName = NS::String::string(
        "vertexMain", NS::StringEncoding::UTF8StringEncoding);
    MTL::Function* vertexMain = library->newFunction(vertexName);
    
    NS::String* fragmentName = NS::String::string(
        "fragmentMain", NS::StringEncoding::UTF8StringEncoding);
    MTL::Function* fragmentMain = library->newFunction(fragmentName);
    
    /*
        A Pipeline Descriptor describes a pipeline,
        
        The purpose of having descriptor objects is:
            .As much state as necessary is known upfront
            .Desciptors can be reused to quickly create other objects
    */
    MTL::RenderPipelineDescriptor* pipelineDescriptor = 
        MTL::RenderPipelineDescriptor::alloc()->init();
    pipelineDescriptor->setVertexFunction(vertexMain);
    pipelineDescriptor->setFragmentFunction(fragmentMain);
    pipelineDescriptor->colorAttachments()
                    ->object(0)
                    ->setPixelFormat(MTL::PixelFormat::PixelFormatBGRA8Unorm_sRGB);
    
    trianglePipeline = device->newRenderPipelineState(pipelineDescriptor, &error);
    if (!library) {
        std::cout << error->localizedDescription()->utf8String() << std::endl;
    }
    
    //Release un-needed resources
    vertexMain->release();
    fragmentMain->release();
    pipelineDescriptor->release();
    library->release();
}

void Renderer::draw(MTK::View* view) {
    
    NS::AutoreleasePool* pool = NS::AutoreleasePool::alloc()->init();
    
    MTL::CommandBuffer* commandBuffer = commandQueue->commandBuffer();
    MTL::RenderPassDescriptor* renderPass = view->currentRenderPassDescriptor();
    MTL::RenderCommandEncoder* encoder = commandBuffer->renderCommandEncoder(renderPass);
    
    encoder->setRenderPipelineState(trianglePipeline);
    encoder->drawPrimitives(MTL::PrimitiveType::PrimitiveTypeTriangle, NS::UInteger(0), NS::UInteger(3));
    
    encoder->endEncoding();
    commandBuffer->presentDrawable(view->currentDrawable());
    commandBuffer->commit();
    
    pool->release();
}
