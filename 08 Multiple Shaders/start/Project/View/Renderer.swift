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
    
    let meshAllocator: MTKMeshBufferAllocator
    let materialLoader: MTKTextureLoader
    
    let pipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState
    
    var scene: GameScene
    let cubeMesh: ObjMesh
    let groundMesh: ObjMesh
    let mouseMesh: ObjMesh
    
    let artyMaterial: Material
    let woodMaterial: Material
    let mouseMaterial: Material
    
    init(_ parent: ContentView, scene: GameScene) {
        
        self.parent = parent
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        
        self.meshAllocator = MTKMeshBufferAllocator(device: metalDevice)
        self.materialLoader = MTKTextureLoader(device: metalDevice)
        
        cubeMesh = ObjMesh(device: metalDevice, allocator: meshAllocator, filename: "cube")
        groundMesh = ObjMesh(device: metalDevice, allocator: meshAllocator, filename: "ground")
        mouseMesh = ObjMesh(device: metalDevice, allocator: meshAllocator, filename: "mouse")
        
        artyMaterial = Material(device: metalDevice, allocator: materialLoader, filename: "arty")
        woodMaterial = Material(device: metalDevice, allocator: materialLoader, filename: "wood")
        mouseMaterial = Material(device: metalDevice, allocator: materialLoader, filename: "maus")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = metalDevice.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(cubeMesh.metalMesh.vertexDescriptor)
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = metalDevice.makeDepthStencilState(descriptor: depthStencilDescriptor)!
        
        do {
            try pipelineState = metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError()
        }
        
        self.scene = scene
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        //update
        scene.update()
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = metalCommandQueue.makeCommandBuffer()
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1.0)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setDepthStencilState(depthStencilState)
        
        sendCameraData(renderEncoder: renderEncoder)
        
        sendLightData(renderEncoder: renderEncoder)
        
        armForDrawing(renderEncoder: renderEncoder, mesh: cubeMesh, material: artyMaterial)
        for cube in scene.cubes {
            draw(renderEncoder: renderEncoder, mesh: cubeMesh, modelTransform: &(cube.model!))
        }
        
        armForDrawing(renderEncoder: renderEncoder, mesh: groundMesh, material: woodMaterial)
        for ground in scene.groundTiles {
            draw(renderEncoder: renderEncoder, mesh: groundMesh, modelTransform: &(ground.model!))
        }
        
        armForDrawing(renderEncoder: renderEncoder, mesh: mouseMesh, material: mouseMaterial)
        draw(renderEncoder: renderEncoder, mesh: mouseMesh, modelTransform: &(scene.mouse.model))
        
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    func sendCameraData(renderEncoder: MTLRenderCommandEncoder?) {
        
        var cameraData: CameraParameters = CameraParameters()
        cameraData.view = scene.player.view!
        cameraData.projection = Matrix44.create_perspective_projection(
            fovy: 45, aspect: 800/600, near: 0.1, far: 20
        )
        renderEncoder?.setVertexBytes(&cameraData, length: MemoryLayout<CameraParameters>.stride, index: 2)
        
    }
    
    func sendLightData(renderEncoder: MTLRenderCommandEncoder?) {
        
        var sun: DirectionalLight = DirectionalLight()
        sun.forwards = scene.sun.forwards!
        sun.color = scene.sun.color
        renderEncoder?.setFragmentBytes(&sun, length: MemoryLayout<DirectionalLight>.stride, index: 0)
        
        var spotlight: Spotlight = Spotlight()
        spotlight.forwards = scene.spotlight.forwards!
        spotlight.color = scene.spotlight.color
        spotlight.position = scene.spotlight.position!
        renderEncoder?.setFragmentBytes(&spotlight, length: MemoryLayout<Spotlight>.stride, index: 1)
        
        var pointLights: [Pointlight] = []
        for light in scene.pointLights {
            pointLights.append(Pointlight(position: light.position!, color: light.color))
        }
        renderEncoder?.setFragmentBytes(&pointLights, length: MemoryLayout<Pointlight>.stride * scene.pointLights.count, index: 2)
        
        var fragUBO: FragmentData = FragmentData()
        fragUBO.lightCount = UInt32(scene.pointLights.count)
        renderEncoder?.setFragmentBytes(&fragUBO, length: MemoryLayout<FragmentData>.stride, index: 3)
        
    }
    
    func armForDrawing(renderEncoder: MTLRenderCommandEncoder?, mesh: ObjMesh, material: Material) {
        
        renderEncoder?.setVertexBuffer(mesh.metalMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        renderEncoder?.setFragmentTexture(material.texture, index: 0)
        renderEncoder?.setFragmentSamplerState(material.sampler, index: 0)
        
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder?, mesh: ObjMesh, modelTransform: UnsafeMutablePointer<matrix_float4x4>) {
        
        renderEncoder?.setVertexBytes(modelTransform, length: MemoryLayout<matrix_float4x4>.stride, index: 1)
        
        for submesh in mesh.metalMesh.submeshes {
            renderEncoder?.drawIndexedPrimitives(
                type: .triangle, indexCount: submesh.indexCount,
                indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer,
                indexBufferOffset: submesh.indexBuffer.offset
            )
        }
        
    }
    
}
