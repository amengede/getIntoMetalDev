//
//  Renderer.swift
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
    var parent: ContentView
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipeline: MTLRenderPipelineState
    var triangleMesh: MTLBuffer
    var quadMesh: Mesh
    
    init(_ parent: ContentView) {
        
        self.parent = parent
        if let device = MTLCreateSystemDefaultDevice() {
            self.device = device
        }
        self.commandQueue = device.makeCommandQueue()
        
        pipeline = build_pipeline(device: device)
        
        let meshBuilder = MeshFactory(device: device)
        triangleMesh = meshBuilder.make_triangle()
        quadMesh = meshBuilder.make_quad()
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1.0)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(descriptor: renderPassDescriptor!)!
        
        renderEncoder.setRenderPipelineState(pipeline)
        
        renderEncoder.setVertexBuffer(quadMesh.vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: quadMesh.indexCount, 
                                            indexType: .uint16, indexBuffer: quadMesh.indexBuffer,
                                            indexBufferOffset: 0)
        
        renderEncoder.setVertexBuffer(triangleMesh, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
