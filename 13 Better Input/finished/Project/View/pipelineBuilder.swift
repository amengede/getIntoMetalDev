//
//  PipelineBuilder.swift
//  Project
//
//  Created by Andrew Mengede on 4/8/2022.
//

import Foundation
import MetalKit

class PipelineBuilder {
    
    static func BuildPipeline(metalDevice: MTLDevice, library: MTLLibrary, vsEntry: String, fsEntry: String, vertexDescriptor: MTLVertexDescriptor) -> MTLRenderPipelineState {
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: vsEntry)
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: fsEntry)
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        do {
            return try metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError()
        }
    }
}
