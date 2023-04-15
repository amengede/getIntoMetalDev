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
    
    let litPipeline: MTLRenderPipelineState
    let unlitPipeline: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState
    
    var scene: GameScene
    
    let menagerie: vertexMenagerie
    let materialLump: MaterialLump
    
    init(_ parent: ContentView, scene: GameScene) {
        
        self.parent = parent
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        
        self.meshAllocator = MTKMeshBufferAllocator(device: metalDevice)
        self.materialLoader = MTKTextureLoader(device: metalDevice)
        
        menagerie = vertexMenagerie()
        menagerie.consume(mesh: ObjMesh(filename: "cube"), meshType: 0)
        menagerie.consume(mesh: ObjMesh(filename: "ground"), meshType: 1)
        menagerie.consume(mesh: ObjMesh(filename: "mouse"), meshType: 2)
        menagerie.consume(mesh: ObjMesh(filename: "light"), meshType: 3)
        menagerie.finalize(device: metalDevice)
        
        let artyMaterial = Material(
            device: metalDevice, allocator: materialLoader, filename: "arty", filenameExtension: "png")
        let woodMaterial = Material(
            device: metalDevice, allocator: materialLoader, filename: "wood", filenameExtension: "png")
        let mouseMaterial = Material(
            device: metalDevice, allocator: materialLoader, filename: "maus", filenameExtension: "png")
        let lightMaterial = Material(
            device: metalDevice, allocator: materialLoader, filename: "star", filenameExtension: "png")
        
        materialLump = MaterialLump(
            device: metalDevice,
            layerCount: 4,
            queue: metalCommandQueue,
            format: artyMaterial.texture.pixelFormat
        )
        materialLump.consume(material: artyMaterial.texture, layer: 0)
        materialLump.consume(material: woodMaterial.texture, layer: 1)
        materialLump.consume(material: mouseMaterial.texture, layer: 2)
        materialLump.consume(material: lightMaterial.texture, layer: 3)
        materialLump.finalize()
        
        guard let library: MTLLibrary = metalDevice.makeDefaultLibrary() else {
            fatalError()
        }
        
        let vertexDescriptor: MTLVertexDescriptor = MTLVertexDescriptor()
        var offset: Int = 0
        
        //position
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].offset = offset
        vertexDescriptor.attributes[0].bufferIndex = 0
        offset += MemoryLayout<SIMD4<Float>>.stride
        //texCoord
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = offset
        vertexDescriptor.attributes[1].bufferIndex = 0
        offset += MemoryLayout<SIMD2<Float>>.stride
        //normal
        vertexDescriptor.attributes[2].format = .float3
        vertexDescriptor.attributes[2].offset = offset
        vertexDescriptor.attributes[2].bufferIndex = 0
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        vertexDescriptor.layouts[0].stride = offset
        litPipeline = PipelineBuilder.BuildPipeline(metalDevice: metalDevice, library: library, vsEntry: "vertexShader", fsEntry: "fragmentShader", vertexDescriptor: vertexDescriptor)
        unlitPipeline = PipelineBuilder.BuildPipeline(metalDevice: metalDevice, library: library, vsEntry: "vertexShaderUnlit", fsEntry: "fragmentShaderUnlit", vertexDescriptor: vertexDescriptor)
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = metalDevice.makeDepthStencilState(descriptor: depthStencilDescriptor)!
        
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
        
        drawLitObjects(renderEncoder: renderEncoder)
        
        drawUnlitObjects(renderEncoder: renderEncoder)
        
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    func drawLitObjects(renderEncoder: MTLRenderCommandEncoder?) {
        
        renderEncoder?.setRenderPipelineState(litPipeline)
        renderEncoder?.setDepthStencilState(depthStencilState)
        renderEncoder?.setVertexBuffer(menagerie.vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setFragmentTexture(materialLump.texture, index: 0)
        renderEncoder?.setFragmentSamplerState(materialLump.sampler, index: 0)
        
        sendCameraData(renderEncoder: renderEncoder)
        
        sendLightData(renderEncoder: renderEncoder)
        
        for cube in scene.cubes {
            draw(renderEncoder: renderEncoder, modelTransform: &(cube.model!), meshType: 0)
        }
        
        for ground in scene.groundTiles {
            draw(renderEncoder: renderEncoder, modelTransform: &(ground.model!), meshType: 1)
        }
        
        draw(renderEncoder: renderEncoder, modelTransform: &(scene.mouse.model), meshType: 2)
        
    }
    
    func drawUnlitObjects(renderEncoder: MTLRenderCommandEncoder?) {
        
        renderEncoder?.setRenderPipelineState(unlitPipeline)
        renderEncoder?.setDepthStencilState(depthStencilState)
        
        for light in scene.pointLights {
            renderEncoder?.setFragmentBytes(&(light.color), length: MemoryLayout<simd_float3>.stride, index: 0)
            draw(renderEncoder: renderEncoder, modelTransform: &(light.model), meshType: 3)
        }
        
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
            pointLights.append(Pointlight(position: light.position, color: light.color))
        }
        renderEncoder?.setFragmentBytes(&pointLights, length: MemoryLayout<Pointlight>.stride * scene.pointLights.count, index: 2)
        
        var fragUBO: FragmentData = FragmentData()
        fragUBO.lightCount = UInt32(scene.pointLights.count)
        renderEncoder?.setFragmentBytes(&fragUBO, length: MemoryLayout<FragmentData>.stride, index: 3)
        
    }
    
    func draw(
        renderEncoder: MTLRenderCommandEncoder?,
        modelTransform: UnsafeMutablePointer<matrix_float4x4>,
        meshType: Int) {
        
        renderEncoder?.setVertexBytes(modelTransform, length: MemoryLayout<matrix_float4x4>.stride, index: 1);
        var material: Float = Float(meshType);
        renderEncoder?.setFragmentBytes(&material, length: MemoryLayout<Float>.stride, index: 4);
        
        renderEncoder?.drawPrimitives(
            type: .triangle,
            vertexStart: menagerie.firstVertices[meshType]!,
            vertexCount: menagerie.vertexCounts[meshType]!
        )
        
    }
    
}
