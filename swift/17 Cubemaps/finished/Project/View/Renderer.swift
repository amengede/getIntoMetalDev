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
        
        menagerie = vertexMenagerie();
        menagerie.consume(mesh: ObjMesh(filename: "cube"), meshType: OBJECT_TYPE_CUBE);
        menagerie.consume(mesh: ObjMesh(filename: "ground"), meshType: OBJECT_TYPE_GROUND);
        menagerie.consume(mesh: ObjMesh(filename: "mouse"), meshType: OBJECT_TYPE_MOUSE);
        menagerie.consume(mesh: ObjMesh(filename: "light"), meshType: OBJECT_TYPE_POINT_LIGHT);
        menagerie.finalize(device: metalDevice);
        
        let woodMaterial = Material(
            device: metalDevice, allocator: materialLoader, filename: "wood", filenameExtension: "png")
        let artyMaterial = Material(
            device: metalDevice, allocator: materialLoader, filename: "arty", filenameExtension: "png")
        let mouseMaterial = Material(
            device: metalDevice, allocator: materialLoader, filename: "maus", filenameExtension: "png")
        let lightMaterial = Material(
            device: metalDevice, allocator: materialLoader, filename: "star", filenameExtension: "png")
        materialLump = MaterialLump(
            device: metalDevice,
            layerCount: 4,
            queue: metalCommandQueue,
            format: artyMaterial.texture.pixelFormat
        );
        materialLump.consume(material: artyMaterial.texture, 
                             layer: OBJECT_TYPE_CUBE)
        materialLump.consume(material: woodMaterial.texture, 
                             layer: OBJECT_TYPE_GROUND)
        materialLump.consume(material: mouseMaterial.texture, 
                             layer: OBJECT_TYPE_MOUSE)
        materialLump.consume(material: lightMaterial.texture, 
                             layer: OBJECT_TYPE_POINT_LIGHT)
        materialLump.finalize()
        
        cubemap = CubemapMaterial(device: metalDevice, queue: metalCommandQueue,
                                  format: artyMaterial.texture.pixelFormat)
        let frontMaterial = Material(device: metalDevice, allocator: materialLoader, filename: "sky_front", filenameExtension: "png")
        let backMaterial = Material(device: metalDevice, allocator: materialLoader, filename: "sky_back", filenameExtension: "png")
        let leftMaterial = Material(device: metalDevice, allocator: materialLoader, filename: "sky_left", filenameExtension: "png")
        let rightMaterial = Material(device: metalDevice, allocator: materialLoader, filename: "sky_right", filenameExtension: "png")
        let topMaterial = Material(device: metalDevice, allocator: materialLoader, filename: "sky_top", filenameExtension: "png")
        let bottomMaterial = Material(device: metalDevice, allocator: materialLoader, filename: "sky_bottom", filenameExtension: "png")
        
        cubemap.consume(material: rightMaterial.texture, layer: 3)
        cubemap.consume(material: leftMaterial.texture, layer: 2)
        cubemap.consume(material: topMaterial.texture, layer: 4)
        cubemap.consume(material: bottomMaterial.texture, layer: 5)
        cubemap.consume(material: frontMaterial.texture, layer: 1)
        cubemap.consume(material: backMaterial.texture, layer: 0)
        
        cubemap.finalize()
        
        
        guard let library: MTLLibrary = metalDevice.makeDefaultLibrary() else {
            fatalError()
        }
        pipelines = [:];
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
        
        pipelines[PIPELINE_TYPE_LIT] = PipelineBuilder.BuildPipeline(
            metalDevice: metalDevice, library: library,
            vsEntry: "vertexShader", fsEntry: "fragmentShader",
            vertexDescriptor: vertexDescriptor)
        pipelines[PIPELINE_TYPE_EMISSIVE] = PipelineBuilder.BuildPipeline(
            metalDevice: metalDevice, library: library,
            vsEntry: "vertexShaderUnlit", fsEntry: "fragmentShaderUnlit",
            vertexDescriptor: vertexDescriptor)
        
        let simpleVertexDescriptor: MTLVertexDescriptor = MTLVertexDescriptor()
        offset = 0
        
        //position
        simpleVertexDescriptor.attributes[0].format = .float2
        simpleVertexDescriptor.attributes[0].offset = offset
        simpleVertexDescriptor.attributes[0].bufferIndex = 0
        offset += MemoryLayout<SIMD2<Float>>.stride
        
        simpleVertexDescriptor.layouts[0].stride = offset
        pipelines[PIPELINE_TYPE_POST] = PipelineBuilder.BuildPipeline(metalDevice: metalDevice, library: library, vsEntry: "vertexShaderPost", fsEntry: "fragmentShaderPost", vertexDescriptor: simpleVertexDescriptor)
        
        pipelines[PIPELINE_TYPE_SKY] = PipelineBuilder.BuildPipeline(
            metalDevice: metalDevice, library: library,
            vsEntry: "vertexShaderSky", fsEntry: "fragmentShaderSky",
            vertexDescriptor: simpleVertexDescriptor)
        
        customRenderPass = RenderPass(device: metalDevice,
                                      width: 640, height: 480)
        screenQuad = ScreenQuad(device: metalDevice)
        
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
        
        //Use the post processing shaders
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_POST]!)
        //Arm with the color buffer which we rendered to earlier
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
        fragUBO.lightCount = UInt32(scene.pointLights.count)
        renderEncoder?.setFragmentBytes(&fragUBO, length: MemoryLayout<FragmentData>.stride, index: 3)
        
    }
    
    func draw(
        renderEncoder: MTLRenderCommandEncoder?,
        meshType: Int32) {
        
            /*
        print("First Vertices: {}", menagerie.firstVertices)
        print("Vertex Counts: {}", menagerie.vertexCounts)
        print("Instance Counts: {}", scene.instanceCounts)
        print("First Instances: {}", scene.firstInstances)
        print("Requested mesh type: {}", meshType)
        print("First vertex: {}", Int(menagerie.firstVertices[meshType]!))
        print(Int(menagerie.vertexCounts[meshType]!))
        print(scene.instanceCounts[meshType]!)
        print(scene.firstInstances[meshType]!)
            */
        renderEncoder?.drawPrimitives(
            type: .triangle,
            vertexStart: Int(menagerie.firstVertices[meshType]!),
            vertexCount: Int(menagerie.vertexCounts[meshType]!),
            instanceCount: scene.instanceCounts[meshType]!,
            baseInstance: scene.firstInstances[meshType]!);
        
    }
    
}
