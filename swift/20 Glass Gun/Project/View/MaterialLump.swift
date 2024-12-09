//
//  material_lump.swift
//  Project
//
//  Created by Andrew Mengede on 4/2/2023.
//
import MetalKit

class MaterialLump {
        
    var texture: MTLTexture
    var sampler: MTLSamplerState
    var commandBuffer: MTLCommandBuffer
    var blitCommandEncoder: MTLBlitCommandEncoder
    var tempTextures: [Material] = []
    var device: MTLDevice
    var allocator: MTKTextureLoader
    
    init?(device: MTLDevice, allocator: MTKTextureLoader, layerCount: Int, queue: MTLCommandQueue, format: MTLPixelFormat) {
        self.allocator = allocator
        self.device = device

        let textureDescriptor: MTLTextureDescriptor = MTLTextureDescriptor()
        textureDescriptor.textureType = .type2DArray
        textureDescriptor.pixelFormat = format
        textureDescriptor.width = 1024
        textureDescriptor.height = 1024
        textureDescriptor.depth = 1
        textureDescriptor.mipmapLevelCount = 1
        textureDescriptor.sampleCount = 1
        textureDescriptor.arrayLength = layerCount
        textureDescriptor.allowGPUOptimizedContents = true
        textureDescriptor.usage = .shaderRead
        
        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            print("[Error] failed to create material texture")
            return nil
        }
        self.texture = texture
        
        commandBuffer = queue.makeCommandBuffer()!
        blitCommandEncoder = commandBuffer.makeBlitCommandEncoder()!
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.maxAnisotropy = 8
        
        guard let sampler = device.makeSamplerState(descriptor: samplerDescriptor) else {
            print("[Error] failed to create material lump sampler")
            return nil
        }
        self.sampler = sampler
    }
        
    func consume(filename: String, layer: Int32) {
        guard let newMaterial = Material(
            device: device, allocator: allocator, filename: filename, filenameExtension: "png") else {
            return
        }
        
        blitCommandEncoder.copy(
            from: newMaterial.texture, sourceSlice: 0, sourceLevel: 0,
            to: texture, destinationSlice: Int(layer), destinationLevel: 0,
            sliceCount: 1, levelCount: 1
        )
        
        tempTextures.append(newMaterial)
    }
    
    func finalize() {
        blitCommandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        tempTextures = []
    }

}
