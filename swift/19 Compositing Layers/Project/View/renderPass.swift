//
//  renderPass.swift
//  Project
//
//  Created by Andrew Mengede on 14/4/2023.
//

import MetalKit

class RenderPass {
    
    let colorBuffer: MTLTexture;
    let colorBufferSampler: MTLSamplerState;
    
    let depthBuffer: MTLTexture;
    let depthStencilState: MTLDepthStencilState;
    
    let renderpassDescriptor: MTLRenderPassDescriptor;
    
    init(device: MTLDevice, width: Int, height: Int) {
        
        //Create the color buffer
        let colorBufferDescriptor = MTLTextureDescriptor()
        colorBufferDescriptor.textureType = .type2D;
        colorBufferDescriptor.width = width;
        colorBufferDescriptor.height = height;
        colorBufferDescriptor.pixelFormat = .bgra8Unorm;
        colorBufferDescriptor.usage = MTLTextureUsage([.renderTarget, .shaderRead]);
        colorBufferDescriptor.depth = 1;
        colorBufferDescriptor.mipmapLevelCount = 1;
        colorBufferDescriptor.sampleCount = 1;
        colorBufferDescriptor.arrayLength = 1;
        
        colorBuffer = device.makeTexture(descriptor: colorBufferDescriptor)!;
        
        let samplerDescriptor = MTLSamplerDescriptor();
        samplerDescriptor.sAddressMode = .repeat;
        samplerDescriptor.tAddressMode = .repeat;
        samplerDescriptor.magFilter = .linear;
        samplerDescriptor.minFilter = .nearest;
        samplerDescriptor.mipFilter = .linear;
        samplerDescriptor.maxAnisotropy = 1;
        colorBufferSampler = device.makeSamplerState(descriptor: samplerDescriptor)!;
        
        //Create the depth buffer
        
        let depthBufferDescriptor = MTLTextureDescriptor()
        depthBufferDescriptor.textureType = .type2D;
        depthBufferDescriptor.width = width;
        depthBufferDescriptor.height = height;
        depthBufferDescriptor.pixelFormat = .depth32Float;
        depthBufferDescriptor.usage = MTLTextureUsage([.renderTarget, .shaderRead]);
        depthBufferDescriptor.depth = 1;
        depthBufferDescriptor.mipmapLevelCount = 1;
        depthBufferDescriptor.sampleCount = 1;
        depthBufferDescriptor.arrayLength = 1;
        
        depthBuffer = device.makeTexture(descriptor: depthBufferDescriptor)!;
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
        
        //Describe the renderpass
        renderpassDescriptor = MTLRenderPassDescriptor()
        renderpassDescriptor.colorAttachments[0].texture = colorBuffer;
        renderpassDescriptor.colorAttachments[0].loadAction = .clear;
        renderpassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 0.0)
        renderpassDescriptor.colorAttachments[0].storeAction = .store;
        
        renderpassDescriptor.depthAttachment.texture = depthBuffer;
        renderpassDescriptor.depthAttachment.clearDepth = 1.0;
        renderpassDescriptor.depthAttachment.loadAction = .clear;
        renderpassDescriptor.depthAttachment.storeAction = .store;
    }
}

