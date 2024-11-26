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
    var tempTextures: [Material]
    var device: MTLDevice
    var allocator: MTKTextureLoader
    
    init(device: MTLDevice, allocator: MTKTextureLoader, layerCount: Int, queue: MTLCommandQueue, format: MTLPixelFormat) {
        
        let textureDescriptor: MTLTextureDescriptor = MTLTextureDescriptor();
        textureDescriptor.textureType = .type2DArray;
        textureDescriptor.pixelFormat = format;
        textureDescriptor.width = 1024;
        textureDescriptor.height = 1024;
        textureDescriptor.depth = 1;
        textureDescriptor.mipmapLevelCount = 1;
        textureDescriptor.sampleCount = 1;
        textureDescriptor.arrayLength = layerCount;
        textureDescriptor.allowGPUOptimizedContents = true;
        textureDescriptor.usage = .shaderRead;
        
        texture = device.makeTexture(descriptor: textureDescriptor)!;
        
        commandBuffer = queue.makeCommandBuffer()!;
        blitCommandEncoder = commandBuffer.makeBlitCommandEncoder()!;
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.maxAnisotropy = 8
        sampler = device.makeSamplerState(descriptor: samplerDescriptor)!;
        
        tempTextures = []
        
        self.allocator = allocator
        self.device = device
    }
        
    func consume(filename: String, layer: Int32) {
        
        let newMaterial = Material(
            device: device, allocator: allocator, filename: filename, filenameExtension: "png")
        
        blitCommandEncoder.copy(
            from: newMaterial.texture, sourceSlice: 0, sourceLevel: 0,
            to: texture, destinationSlice: Int(layer), destinationLevel: 0,
            sliceCount: 1, levelCount: 1
        );
        
        tempTextures.append(newMaterial)
    }
    
    func finalize() {
        blitCommandEncoder.endEncoding();
        commandBuffer.commit();
        commandBuffer.waitUntilCompleted();
        
        tempTextures = []
    }

}
