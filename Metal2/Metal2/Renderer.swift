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
    let sphereMesh: MDLMesh
    let mesh: MTKMesh
    
    let library: MTLLibrary
    let vertexFunction, fragmentFunction: MTLFunction
    
    let pipelineDescriptor: MTLRenderPipelineDescriptor
    let pipelineState: MTLRenderPipelineState
    
    init(_ parent: MetalView){
        
        self.parent = parent
        
        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Couldn't create device")
        }
        self.metalDevice = metalDevice
        
        guard let metalCommandQueue = metalDevice.makeCommandQueue() else {
            fatalError("Couldn't make command queue")
        }
        self.metalCommandQueue = metalCommandQueue
        
        self.allocator = MTKMeshBufferAllocator(device: metalDevice)
        self.sphereMesh = MDLMesh(sphereWithExtent: [0.5, 0.5, 0.5],
                                  segments: [100, 100],
                                  inwardNormals: false,
                                  geometryType: .triangles,
                                  allocator: self.allocator)
        do {
            mesh = try MTKMesh(mesh: self.sphereMesh, device: self.metalDevice)
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
        self.pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
        
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
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                  fatalError()
              }
        
        renderEncoder.setRenderPipelineState(self.pipelineState)
        
        renderEncoder.setVertexBuffer(self.mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        guard let submesh = self.mesh.submeshes.first else {
            fatalError()
        }
        
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: submesh.indexCount,
                                            indexType: submesh.indexType,
                                            indexBuffer: submesh.indexBuffer.buffer,
                                            indexBufferOffset: 0)
        
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
