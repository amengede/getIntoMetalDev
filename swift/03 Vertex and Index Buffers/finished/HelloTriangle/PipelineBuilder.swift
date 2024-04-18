//
//  PipelineBuilder.swift
//  HelloTriangle
//
//  Created by Andrew Mengede on 18/4/2024.
//

import Metal

func build_pipeline(device: MTLDevice) -> MTLRenderPipelineState {
    
    let pipeline: MTLRenderPipelineState
    
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    let library = device.makeDefaultLibrary()!
    pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexMain")
    pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentMain")
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    do {
        try pipeline = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        return pipeline
    } catch {
        print("failed")
        fatalError()
    }
}
