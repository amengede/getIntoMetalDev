#include "pipeline_factory.h"

PipelineBuilder::PipelineBuilder(MTL::Device* device):
device(device->retain()) {}

PipelineBuilder::~PipelineBuilder() {
    device->release();
}

void PipelineBuilder::set_filename(const char* filename) {
    this->filename = filename;
}

void PipelineBuilder::set_vertex_entry_point(const char* entryPoint) {
    this->vertexEntryPoint = entryPoint;
}

void PipelineBuilder::set_fragment_entry_point(const char* entryPoint) {
    this->fragmentEntryPoint = entryPoint;
}

void PipelineBuilder::set_vertex_descriptor(MTL::VertexDescriptor* descriptor) {
    if (this->vertexDescriptor) {
        this->vertexDescriptor->release();
    }
    this->vertexDescriptor = descriptor->retain();
}

MTL::RenderPipelineState* PipelineBuilder::build() {
    //Read the source code from the file.
    std::ifstream file;
    file.open(filename);
    std::stringstream reader;
    reader << file.rdbuf();
    std::string raw_string = reader.str();
    NS::String* source_code = NS::String::string(
        raw_string.c_str(), NS::StringEncoding::UTF8StringEncoding);
    
    //A Metal Library constructs functions from source code
    NS::Error* error = nullptr;
    MTL::CompileOptions* options = nullptr;
    MTL::Library* library = device->newLibrary(source_code, options, &error);
    if (!library) {
        std::cout << error->localizedDescription()->utf8String() << std::endl;
    }
    
    NS::String* vertexName = NS::String::string(
        vertexEntryPoint, NS::StringEncoding::UTF8StringEncoding);
    MTL::Function* vertexMain = library->newFunction(vertexName);
    
    NS::String* fragmentName = NS::String::string(
        fragmentEntryPoint, NS::StringEncoding::UTF8StringEncoding);
    MTL::Function* fragmentMain = library->newFunction(fragmentName);
    
    MTL::RenderPipelineDescriptor* pipelineDescriptor = 
        MTL::RenderPipelineDescriptor::alloc()->init();
    pipelineDescriptor->setVertexFunction(vertexMain);
    pipelineDescriptor->setFragmentFunction(fragmentMain);
    pipelineDescriptor->colorAttachments()
                    ->object(0)
                    ->setPixelFormat(MTL::PixelFormat::PixelFormatBGRA8Unorm_sRGB);
    
    pipelineDescriptor->setVertexDescriptor(vertexDescriptor);
    
    MTL::RenderPipelineState* pipeline = device->newRenderPipelineState(pipelineDescriptor, &error);
    if (!pipeline) {
        std::cout << error->localizedDescription()->utf8String() << std::endl;
    }
    
    vertexMain->release();
    fragmentMain->release();
    pipelineDescriptor->release();
    library->release();
    file.close();
    
    return pipeline;
}