//
//  PipelineBuilder.swift
//  HelloTriangle
//
//  Created by Andrew Mengede on 18/4/2024.
//

import MetalKit

func build_pipeline(device: MTLDevice,
                    vertexEntry: String, fragmentEntry: String) -> MTLRenderPipelineState {
    
    let pipeline: MTLRenderPipelineState
    
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    let library = device.makeDefaultLibrary()!
    pipelineDescriptor.vertexFunction = library.makeFunction(name: vertexEntry)
    pipelineDescriptor.fragmentFunction = library.makeFunction(name: fragmentEntry)
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    do {
        try pipeline = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        return pipeline
    } catch {
        print("failed")
        fatalError()
    }
}
