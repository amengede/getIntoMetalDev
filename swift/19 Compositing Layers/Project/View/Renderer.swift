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
    
    let worldLayer: RenderPass
    let gunLayer: RenderPass
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
            OBJECT_TYPE_POINT_LIGHT: "light",
            OBJECT_TYPE_GUN: "gun",
        ]
        menagerie = vertexMenagerie();
        for (objectType, modelName) in modelInfo {
            menagerie.consume(mesh: ObjMesh(filename: modelName), meshType: objectType);
        }
        menagerie.finalize(device: metalDevice);
        
        let materialInfo: [Int32: String] = [
            OBJECT_TYPE_CUBE: "arty",
            OBJECT_TYPE_GROUND: "wood",
            OBJECT_TYPE_MOUSE: "maus",
            OBJECT_TYPE_POINT_LIGHT: "star",
            OBJECT_TYPE_GUN: "gun0"
        ]
        materialLump = MaterialLump(device: metalDevice, allocator: materialLoader,
                                    layerCount: materialInfo.count, queue: metalCommandQueue, format: .bgra8Unorm);
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
                                  queue: metalCommandQueue, format: .bgra8Unorm)
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
        pipelines[PIPELINE_TYPE_GUN] = pipelineBuilder.BuildPipeline(
            vsEntry: "vertexShaderGun", fsEntry: "fragmentShader")
        pipelines[PIPELINE_TYPE_EMISSIVE] = pipelineBuilder.BuildPipeline(
            vsEntry: "vertexShaderUnlit", fsEntry: "fragmentShaderUnlit")
        
        screenQuad = ScreenQuad(device: metalDevice)
        pipelineBuilder.setVertexDescriptor(vertexDescriptor: screenQuad.getVertexDescriptor())
        pipelines[PIPELINE_TYPE_POST] = pipelineBuilder.BuildPipeline(
            vsEntry: "vertexShaderPost", fsEntry: "fragmentShaderPost", depthEnabled: false)
        
        pipelines[PIPELINE_TYPE_SKY] = pipelineBuilder.BuildPipeline(
            vsEntry: "vertexShaderSky", fsEntry: "fragmentShaderSky")
        
        worldLayer = RenderPass(device: metalDevice,
                                      width: 640, height: 480)
        gunLayer = RenderPass(device: metalDevice,
                                      width: 640, height: 480)
        
        self.scene = scene
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        
        //update
        scene.update();
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = metalCommandQueue.makeCommandBuffer()!
        
        drawWorld(commandBuffer: commandBuffer)
        
        drawGun(commandBuffer: commandBuffer)
        
        drawScreen(commandBuffer: commandBuffer, view: view)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func drawWorld(commandBuffer: MTLCommandBuffer) {
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: worldLayer.renderpassDescriptor)
        renderEncoder?.setDepthStencilState(worldLayer.depthStencilState)
        
        drawSky(renderEncoder: renderEncoder)
        
        drawLitObjects(renderEncoder: renderEncoder)
        
        drawUnlitObjects(renderEncoder: renderEncoder)
        
        renderEncoder?.endEncoding()
    }
    
    func drawSky(renderEncoder: MTLRenderCommandEncoder?) {
        
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_SKY]!)
        renderEncoder?.setVertexBuffer(screenQuad.vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setFragmentTexture(cubemap.texture, index: 0)
        renderEncoder?.setFragmentSamplerState(cubemap.sampler, index: 0)
        
        let dy: Float32 = tan(.pi / 8);
        let dx: Float32 = 0.5 * dy * 800/600;
        
        var cameraFrame: CameraFrame = CameraFrame(
            forwards: scene.player.forwards,
            right: dx * scene.player.right,
            up: dy * scene.player.up)
        renderEncoder?.setVertexBytes(&cameraFrame, length: MemoryLayout<CameraFrame>.stride, index: 1)
        
        renderEncoder?.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: 6
        )
        
    }
    
    func drawLitObjects(renderEncoder: MTLRenderCommandEncoder?) {
        
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_LIT]!)
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
    
    func drawUnlitObjects(renderEncoder: MTLRenderCommandEncoder?) {
        
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_EMISSIVE]!)
        
        draw(renderEncoder: renderEncoder, meshType: OBJECT_TYPE_POINT_LIGHT);
        
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
    
    func drawGun(commandBuffer: MTLCommandBuffer) {
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: gunLayer.renderpassDescriptor)
        
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_GUN]!)
        renderEncoder?.setDepthStencilState(gunLayer.depthStencilState)
        renderEncoder?.setVertexBuffer(menagerie.vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setFragmentTexture(materialLump.texture, index: 0)
        renderEncoder?.setFragmentSamplerState(materialLump.sampler, index: 0)
        
        sendCameraData(renderEncoder: renderEncoder)
        
        sendLightData(renderEncoder: renderEncoder)
        
        let scale = float4x4(
            [0.1, 0, 0, 0],
            [0, 0.1, 0, 0],
            [0, 0, 0.1, 0],
            [0, 0, 0, 1]);
        
        let pitch = Matrix44.create_from_rotation(eulers: [90 - scene.player.eulers[1], 0, 0]);
        
        let yaw = Matrix44.create_from_rotation(eulers: [0, 0, 90 + scene.player.eulers[2]]);
        
        let translation = Matrix44.create_from_translation(translation:
            scene.player.position + scene.player.forwards - 0.1 * scene.player.right - 0.4 * scene.player.up);
        
        var model = translation * yaw * pitch * scale;
        renderEncoder?.setVertexBytes(&model, length: MemoryLayout<float4x4>.stride, index: 1);
        
        var materialID = Float32(OBJECT_TYPE_GUN);
        renderEncoder?.setVertexBytes(&materialID, length: MemoryLayout<Float32>.stride, index: 3);
        
        renderEncoder?.drawPrimitives(type: .triangle,
                                      vertexStart: Int(menagerie.firstVertices[OBJECT_TYPE_GUN]!),
                                      vertexCount: Int(menagerie.vertexCounts[OBJECT_TYPE_GUN]!))
        
        renderEncoder?.endEncoding()
    }
    
    func drawScreen(commandBuffer: MTLCommandBuffer, view: MTKView) {
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        
        // World
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_POST]!)
        renderEncoder?.setFragmentTexture(worldLayer.colorBuffer, index: 0)
        renderEncoder?.setFragmentSamplerState(worldLayer.colorBufferSampler, index: 0)
        renderEncoder?.setVertexBuffer(screenQuad.vertexBuffer, offset: 0, index: 0)
        
        renderEncoder?.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: 6
        )
        
        // Gun
        renderEncoder?.setFragmentTexture(gunLayer.colorBuffer, index: 0)
        renderEncoder?.setFragmentSamplerState(gunLayer.colorBufferSampler, index: 0)
        
        renderEncoder?.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: 6
        )
        
        renderEncoder?.endEncoding()
        
    }
    
}
