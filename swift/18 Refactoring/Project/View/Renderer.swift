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
    
    var pipelines: Dictionary<Int32, MTLRenderPipelineState>
    
    var scene: GameScene
    
    let menagerie: vertexMenagerie
    let materialLump: MaterialLump
    let cubemap: CubemapMaterial
    
    let customRenderPass: RenderPass
    let screenQuad: ScreenQuad
    
    init(_ parent: ContentView, scene: GameScene) {
        
        self.parent = parent
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        
        self.meshAllocator = MTKMeshBufferAllocator(device: metalDevice)
        self.materialLoader = MTKTextureLoader(device: metalDevice)
        
        let modelInfo: [Int32: String] = [
            OBJECT_TYPE_CUBE: "cube",
            OBJECT_TYPE_GROUND: "ground",
            OBJECT_TYPE_MOUSE: "mouse",
            OBJECT_TYPE_POINT_LIGHT: "light"]
        menagerie = vertexMenagerie();
        for (objectType, modelName) in modelInfo {
            menagerie.consume(mesh: ObjMesh(filename: modelName), meshType: objectType);
        }
        menagerie.finalize(device: metalDevice);
        
        let materialInfo: [Int32: String] = [
            OBJECT_TYPE_CUBE: "arty",
            OBJECT_TYPE_GROUND: "wood",
            OBJECT_TYPE_MOUSE: "maus",
            OBJECT_TYPE_POINT_LIGHT: "star"]
        materialLump = MaterialLump(device: metalDevice, allocator: materialLoader,
            layerCount: materialInfo.count, queue: metalCommandQueue, format: .rgba8Unorm);
        for (objectType, filename) in materialInfo {
            materialLump.consume(filename: filename, layer: objectType)
        }
        materialLump.finalize()
        
        let skyInfo: [Int32: String] = [
            3: "sky_right",
            2: "sky_left",
            4: "sky_top",
            5: "sky_bottom",
            1: "sky_front",
            0: "sky_back"]
        cubemap = CubemapMaterial(device: metalDevice, allocator: materialLoader,
                                  queue: metalCommandQueue, format: .rgba8Unorm)
        for (layer, filename) in skyInfo {
            cubemap.consume(filename: filename, layer: layer)
        }
        cubemap.finalize()
        
        
        guard let library: MTLLibrary = metalDevice.makeDefaultLibrary() else {
            fatalError()
        }
        pipelines = [:];
        let pipelineBuilder = PipelineBuilder(device: metalDevice, library: library)
        pipelineBuilder.setVertexDescriptor(vertexDescriptor: menagerie.getVertexDescriptor())
        pipelines[PIPELINE_TYPE_LIT] = pipelineBuilder.BuildPipeline(
            vsEntry: "vertexShader", fsEntry: "fragmentShader")
        pipelines[PIPELINE_TYPE_EMISSIVE] = pipelineBuilder.BuildPipeline(
            vsEntry: "vertexShaderUnlit", fsEntry: "fragmentShaderUnlit")
        
        screenQuad = ScreenQuad(device: metalDevice)
        pipelineBuilder.setVertexDescriptor(vertexDescriptor: screenQuad.getVertexDescriptor())
        pipelines[PIPELINE_TYPE_POST] = pipelineBuilder.BuildPipeline(
            vsEntry: "vertexShaderPost", fsEntry: "fragmentShaderPost")
        
        pipelines[PIPELINE_TYPE_SKY] = pipelineBuilder.BuildPipeline(
            vsEntry: "vertexShaderSky", fsEntry: "fragmentShaderSky")
        
        customRenderPass = RenderPass(device: metalDevice,
                                      width: 640, height: 480)
        
        self.scene = scene
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func prepare_scene() -> MTLBuffer {
        
        var payloads: [InstancePayload] = []
        
        for type in [OBJECT_TYPE_CUBE, OBJECT_TYPE_GROUND, OBJECT_TYPE_MOUSE, OBJECT_TYPE_POINT_LIGHT] {
            for instance in scene.renderables[type]! {
                payloads.append(
                    InstancePayload(
                        model: instance.get_model_transform(),
                        color_texID: simd_float4(instance.color, Float(instance.id))))
                
            }
        }
        
        var memory: UnsafeMutableRawPointer? = nil
        
        let memory_size = payloads.count * MemoryLayout<InstancePayload>.stride
        //print(MemoryLayout<InstancePayload>.stride)
        let page_size = 0x1000
        let allocation_size = (memory_size + page_size - 1) & (~(page_size - 1))
        
        posix_memalign(&memory, page_size, allocation_size)
        memcpy(memory, &payloads, allocation_size)
        
        /*
         shared: CPU and GPU,
         private: GPU only
         managed: both CPU and GPU have copies, changes must be explicitly signalled/sychronized
         memoryless: contents exist only temporarily for renderpass
         */
        
        let buffer = metalDevice.makeBuffer(
            bytes: memory!, length: allocation_size, options: .storageModeShared
        )

        free(memory)
        return buffer!
    }
    
    func draw(in view: MTKView) {
        
        //update
        scene.update();
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = metalCommandQueue.makeCommandBuffer()
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(
            descriptor: customRenderPass.renderpassDescriptor)
        
        drawSky(renderEncoder: renderEncoder)
        
        drawLitObjects(renderEncoder: renderEncoder)
        
        drawUnlitObjects(renderEncoder: renderEncoder)
        
        renderEncoder?.endEncoding()
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1.0)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let postRenderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        
        drawScreenPostProcessing(renderEncoder: postRenderEncoder)
        
        postRenderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    func drawLitObjects(renderEncoder: MTLRenderCommandEncoder?) {
        
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_LIT]!)
        renderEncoder?.setDepthStencilState(customRenderPass.depthStencilState)
        renderEncoder?.setVertexBuffer(menagerie.vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setFragmentTexture(materialLump.texture, index: 0)
        renderEncoder?.setFragmentSamplerState(materialLump.sampler, index: 0)
        renderEncoder?.setVertexBuffer(prepare_scene(), offset: 0, index: 1);
        
        sendCameraData(renderEncoder: renderEncoder)
        
        sendLightData(renderEncoder: renderEncoder)
        
        draw(renderEncoder: renderEncoder, meshType: OBJECT_TYPE_CUBE);
        
        draw(renderEncoder: renderEncoder, meshType: OBJECT_TYPE_GROUND);
        
        draw(renderEncoder: renderEncoder, meshType: OBJECT_TYPE_MOUSE);
        
    }
    
    func drawUnlitObjects(renderEncoder: MTLRenderCommandEncoder?) {
        
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_EMISSIVE]!)
        renderEncoder?.setDepthStencilState(customRenderPass.depthStencilState)
        
        draw(renderEncoder: renderEncoder, meshType: OBJECT_TYPE_POINT_LIGHT);
        
    }
    
    func drawSky(renderEncoder: MTLRenderCommandEncoder?) {
        
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_SKY]!)
        renderEncoder?.setDepthStencilState(customRenderPass.depthStencilState)
        renderEncoder?.setVertexBuffer(screenQuad.vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setFragmentTexture(cubemap.texture, index: 0)
        renderEncoder?.setFragmentSamplerState(cubemap.sampler, index: 0)
        
        var cameraFrame: CameraFrame = CameraFrame(
            forwards: scene.player.forwards,
            right: scene.player.right,
            up: scene.player.up, aspect: 640.0 / 480.0)
        renderEncoder?.setVertexBytes(&cameraFrame, length: MemoryLayout<CameraFrame>.stride, index: 1)
        
        renderEncoder?.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: 6
        )
        
    }
    
    func drawScreenPostProcessing(renderEncoder: MTLRenderCommandEncoder?) {
        
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_POST]!)
        renderEncoder?.setFragmentTexture(customRenderPass.colorBuffer, index: 0)
        renderEncoder?.setFragmentSamplerState(customRenderPass.colorBufferSampler, index: 0)
        renderEncoder?.setVertexBuffer(screenQuad.vertexBuffer, offset: 0, index: 0)
        
        renderEncoder?.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: 6
        )
        
    }
    
    func sendCameraData(renderEncoder: MTLRenderCommandEncoder?) {
        
        var cameraData: CameraParameters = CameraParameters()
        cameraData.view = scene.player.get_view_transform()
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
        fragUBO.lightCount = Int32(scene.pointLights.count)
        renderEncoder?.setFragmentBytes(&fragUBO, length: MemoryLayout<FragmentData>.stride, index: 3)
        
    }
    
    func draw(
        renderEncoder: MTLRenderCommandEncoder?,
        meshType: Int32) {
        
        renderEncoder?.drawPrimitives(
            type: .triangle,
            vertexStart: Int(menagerie.firstVertices[meshType]!),
            vertexCount: Int(menagerie.vertexCounts[meshType]!),
            instanceCount: scene.instanceCounts[meshType]!,
            baseInstance: scene.firstInstances[meshType]!);
        
    }
    
}
