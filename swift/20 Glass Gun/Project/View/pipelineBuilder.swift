//
//  PipelineBuilder.swift
//  Project
//
//  Created by Andrew Mengede on 4/8/2022.
//

import Foundation
import MetalKit

class PipelineBuilder {
    
    let device: MTLDevice
    let library: MTLLibrary
    var vertexDescriptor: MTLVertexDescriptor
    
    init(device: MTLDevice, library: MTLLibrary) {
        self.device = device
        self.library = library
        self.vertexDescriptor = MTLVertexDescriptor()
    }
    
    func setVertexDescriptor(vertexDescriptor: MTLVertexDescriptor) {
        self.vertexDescriptor = vertexDescriptor
    }
    
    func BuildPipeline(vsEntry: String, fsEntry: String, depthEnabled: Bool = true) -> MTLRenderPipelineState {
        
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
        if depthEnabled {
            pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        }
        
        do {
            return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError()
        }
    }
}
