//
//  Renderer.swift
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
    var parent: ContentView
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    var pipeline: MTLComputePipelineState!
    
    init(_ parent: ContentView) {
        
        self.parent = parent
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        
        do {
            guard let library = metalDevice.makeDefaultLibrary() else {
                fatalError()
            }
            guard let kernel = library.makeFunction(name: "ray_tracing_kernel") else {
                fatalError()
            }
            pipeline = try metalDevice.makeComputePipelineState(function: kernel)
        } catch {
          fatalError()
        }
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = metalCommandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeComputeCommandEncoder()!
        
        renderEncoder.setComputePipelineState(pipeline)
        renderEncoder.setTexture(drawable.texture, index: 0)
        
        /*
         The goal is to execute each pixel in parallel, writing output to the color buffer, which
         is automatically presented in drawable.
         
         Ideally this would be one single call, one thread per pixel, wouldn't that be something!
         
         In reality the best we can do is batch it. The entire job (color buffer) is called the grid.
         We work out how many threads can be executed at once, and how much work they can do in parallel,
         and let that define a tread group (aka "work group" in OpenGL).
         Then, like a tiling process, the GPU splits the entire grid into thread groups, works its magic.
         */
        
        // Number of threads which can be executed in parallel
        let workGroupWidth = pipeline.threadExecutionWidth
        /* Number of steps that each threadgroup executes.
        think of an image, and each row is processed at once.
         So h is the number of rows which need to be processed to execute that batch.
         Given that (w * h) pixels are executed in one work group.
         */
        let workGroupHeight = pipeline.maxTotalThreadsPerThreadgroup / workGroupWidth
        let threadsPerGroup = MTLSizeMake(workGroupWidth, workGroupHeight, 1)
        let threadsPerGrid = MTLSizeMake(Int(view.drawableSize.width),
                                         Int(view.drawableSize.height), 1)
        
        renderEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
}
