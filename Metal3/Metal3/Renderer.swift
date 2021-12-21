//
//  Renderer.swift
//  Metal1
//
//  Created by Andrew Mengede on 11/12/21.
//

import MetalKit

class Renderer: NSObject, MTKViewDelegate{
    
    var parent: MetalView
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    
    let allocator: MTKMeshBufferAllocator
    let modelIOMesh: MDLMesh
    let metalMesh: MTKMesh
    
    let library: MTLLibrary
    let vertexFunction, fragmentFunction: MTLFunction
    
    let pipelineDescriptor: MTLRenderPipelineDescriptor
    let pipelineState: MTLRenderPipelineState
    
    var t: Float
    
    init(_ parent: MetalView){
        
        self.parent = parent
        
        self.t = 0
        
        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Couldn't create device")
        }
        self.metalDevice = metalDevice
        
        guard let metalCommandQueue = metalDevice.makeCommandQueue() else {
            fatalError("Couldn't make command queue")
        }
        self.metalCommandQueue = metalCommandQueue
        
        self.allocator = MTKMeshBufferAllocator(device: metalDevice)
        
        guard let meshURL = Bundle.main.url(forResource: "frosty", withExtension: "obj") else {
            fatalError("Couldn't find mesh file")
        }
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride
        let meshDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        (meshDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        let asset = MDLAsset(url: meshURL,
                             vertexDescriptor: meshDescriptor,
                             bufferAllocator: self.allocator)
        self.modelIOMesh = asset.childObjects(of: MDLMesh.self).first as! MDLMesh
        do {
            metalMesh = try MTKMesh(mesh: self.modelIOMesh, device: self.metalDevice)
        } catch {
            fatalError("couldn't load mesh")
        }
        
        guard let library = metalDevice.makeDefaultLibrary() else {
            fatalError("couldn't find shader file")
        }
        self.library = library
        
        guard let vertFunc = library.makeFunction(name: "vertex_main") else {
            fatalError("Couldn't make vertex shader")
        }
        self.vertexFunction = vertFunc
        
        guard let fragFunc = library.makeFunction(name: "fragment_main") else {
            fatalError("Couldn't make fragment shader")
        }
        self.fragmentFunction = fragFunc
        
        self.pipelineDescriptor = MTLRenderPipelineDescriptor()
        self.pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        self.pipelineDescriptor.vertexFunction = self.vertexFunction
        self.pipelineDescriptor.fragmentFunction = self.fragmentFunction
        self.pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(metalMesh.vertexDescriptor)
        
        do {
            try pipelineState = metalDevice.makeRenderPipelineState(descriptor: self.pipelineDescriptor)
        } catch {
            fatalError("Couldn't make pipeline state")
        }
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        
        t += 0.1
        if t > 2 * .pi {
            t -= 2 * .pi
        }
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                  fatalError()
              }
        
        renderEncoder.setRenderPipelineState(self.pipelineState)
        
        renderEncoder.setVertexBuffer(self.metalMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        renderEncoder.setVertexBytes(&t, length: MemoryLayout<Float>.stride, index: 1)
        
        for submesh in metalMesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: .line,
                                                indexCount: submesh.indexCount,
                                                indexType: submesh.indexType,
                                                indexBuffer: submesh.indexBuffer.buffer,
                                                indexBufferOffset: submesh.indexBuffer.offset)
        }
        
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
