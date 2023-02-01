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
    
    init(device: MTLDevice, allocator: MTKTextureLoader, filename: String, filenameExtension: String) {

        
        //Configure texture properties.
        let options: [MTKTextureLoader.Option: Any] = [
            .SRGB: false,
            .generateMipmaps: true
        ]

        guard let materialURL = Bundle.main.url(forResource: filename, withExtension: filenameExtension) else {
            fatalError()
        }
        do {
            texture = try allocator.newTexture(URL: materialURL, options: options)
        } catch {
            fatalError("couldn't load material from \(filename)")
        }
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.maxAnisotropy = 8
        
        sampler = device.makeSamplerState(descriptor: samplerDescriptor)!
    }
}
