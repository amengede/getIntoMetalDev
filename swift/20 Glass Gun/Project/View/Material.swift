//
//  material.swift
//  Project
//
//  Created by Andrew Mengede on 22/6/2022.
//

import MetalKit

class Material {
    let texture: MTLTexture
    let sampler: MTLSamplerState
    
    init?(device: MTLDevice, allocator: MTKTextureLoader, filename: String, filenameExtension: String) {
        //Configure texture properties.
        let options: [MTKTextureLoader.Option: Any] = [
            .SRGB: false,
            .generateMipmaps: true
        ]

        guard let materialURL = Bundle.main.url(forResource: filename, withExtension: filenameExtension) else {
            print("[Error] Failed to create material URL")
            return nil
        }
        do {
            texture = try allocator.newTexture(URL: materialURL, options: options)
        } catch {
            print("[Error] couldn't load material from \(filename)")
            return nil
        }
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.maxAnisotropy = 8
        
        guard let sampler = device.makeSamplerState(descriptor: samplerDescriptor) else {
            print("[Error] Failed to create sampler")
            return nil
        }
        self.sampler = sampler
    }
}
