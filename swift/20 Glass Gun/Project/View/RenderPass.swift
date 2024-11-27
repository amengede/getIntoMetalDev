//
//  RenderPass.swift
//  Project
//
//  Created by Andrew Mengede on 14/4/2023.
//

import MetalKit

class RenderPass {
    
    let colorBuffer: MTLTexture
    let colorBufferSampler: MTLSamplerState
    
    let depthBuffer: MTLTexture
    let depthStencilState: MTLDepthStencilState
    
    let renderpassDescriptor: MTLRenderPassDescriptor
    
    init?(device: MTLDevice, width: Int, height: Int) {
        //Create the color buffer
        guard let colorBuffer = createColorBuffer(device, width: width, height: height) else {
            print("[Error] Failed to color buffer")
            return nil
        }
        self.colorBuffer = colorBuffer
        
        guard let colorBufferSampler = createColorBufferSampler(device) else {
            print("Failed to create color sample buffer")
            return nil
        }
        self.colorBufferSampler = colorBufferSampler
        
        //Create the depth buffer
        guard let depthBuffer = createDepthBufferDescriptor(device, width: width, height: height) else {
            print("[Error] failed to create depthBufferDescriptor")
            return nil
        }
        self.depthBuffer = depthBuffer
        
        
        guard let depthStencilState = createDepthStencilState(device) else {
            print("[Error] failed to create depthStencilState")
            return nil
        }
        self.depthStencilState = depthStencilState
        
        //Describe the renderpass
        renderpassDescriptor = MTLRenderPassDescriptor()
        renderpassDescriptor.colorAttachments[0].texture = colorBuffer
        renderpassDescriptor.colorAttachments[0].loadAction = .clear
        renderpassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 0.0)
        renderpassDescriptor.colorAttachments[0].storeAction = .store
        
        renderpassDescriptor.depthAttachment.texture = depthBuffer
        renderpassDescriptor.depthAttachment.clearDepth = 1.0
        renderpassDescriptor.depthAttachment.loadAction = .clear
        renderpassDescriptor.depthAttachment.storeAction = .store
    }
}

fileprivate func createColorBuffer(_ device: MTLDevice, width: Int, height: Int) -> MTLTexture? {
    let colorBufferDescriptor = MTLTextureDescriptor()
    colorBufferDescriptor.textureType = .type2D
    colorBufferDescriptor.width = width;
    colorBufferDescriptor.height = height;
    colorBufferDescriptor.pixelFormat = .bgra8Unorm;
    colorBufferDescriptor.usage = [.renderTarget, .shaderRead]
    colorBufferDescriptor.depth = 1
    colorBufferDescriptor.mipmapLevelCount = 1
    colorBufferDescriptor.sampleCount = 1
    colorBufferDescriptor.arrayLength = 1
    return device.makeTexture(descriptor: colorBufferDescriptor)
}

fileprivate func createColorBufferSampler(_ device: MTLDevice) -> MTLSamplerState? {
    let samplerDescriptor = MTLSamplerDescriptor()
    samplerDescriptor.sAddressMode = .repeat
    samplerDescriptor.tAddressMode = .repeat
    samplerDescriptor.magFilter = .linear
    samplerDescriptor.minFilter = .nearest
    samplerDescriptor.mipFilter = .linear
    samplerDescriptor.maxAnisotropy = 1
    return device.makeSamplerState(descriptor: samplerDescriptor)
}

fileprivate func createDepthBufferDescriptor(_ device: MTLDevice, width: Int, height: Int) -> MTLTexture? {
    let depthBufferDescriptor = MTLTextureDescriptor()
    depthBufferDescriptor.storageMode = .private
    depthBufferDescriptor.textureType = .type2D
    depthBufferDescriptor.width = width
    depthBufferDescriptor.height = height
    depthBufferDescriptor.pixelFormat = .depth32Float
    depthBufferDescriptor.usage = [.renderTarget, .shaderRead]
    depthBufferDescriptor.depth = 1
    depthBufferDescriptor.mipmapLevelCount = 1
    depthBufferDescriptor.sampleCount = 1
    depthBufferDescriptor.arrayLength = 1
    return device.makeTexture(descriptor: depthBufferDescriptor)
}

fileprivate func createDepthStencilState(_ device: MTLDevice) -> MTLDepthStencilState? {
    let depthStencilDescriptor = MTLDepthStencilDescriptor()
    depthStencilDescriptor.depthCompareFunction = .lessEqual
    depthStencilDescriptor.isDepthWriteEnabled = true
    return device.makeDepthStencilState(descriptor: depthStencilDescriptor)
}
