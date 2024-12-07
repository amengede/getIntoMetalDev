//
//  material_lump.swift
//  Project
//
//  Created by Andrew Mengede on 4/2/2023.
//
import MetalKit

struct GPUMaterial {
    var albedo: MTLResourceID;
    var sampler: MTLResourceID;
}

class MaterialLump {
    
    var textures: Dictionary<Int, Material>
    var device: MTLDevice
    var allocator: MTKTextureLoader
    var buffer: MTLBuffer?
    
    init(device: MTLDevice, allocator: MTKTextureLoader, layerCount: Int, queue: MTLCommandQueue, format: MTLPixelFormat) {
        
        textures = [:]
        
        self.allocator = allocator
        self.device = device
    }
        
    func consume(filename: String, layer: Int) {
        textures[layer] = (Material(
            device: device, allocator: allocator, filename: filename, filenameExtension: "png"));
    }
    
    func finalize() {
        
        buffer = device.makeBuffer(length: textures.count * MemoryLayout<GPUMaterial>.stride);
        buffer?.label = "arguments";
        let materials = buffer?.contents().assumingMemoryBound(to: GPUMaterial.self)
        
        for i in textures.keys {
            let material: Material = textures[i]!;
            
            materials?[i].albedo = material.texture.gpuResourceID;
            materials?[i].sampler = material.sampler.gpuResourceID;
        }
    }

}
