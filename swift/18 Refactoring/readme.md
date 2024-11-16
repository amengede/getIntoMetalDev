# Making a few changes
As this tutorial project has developed there's been a number of places where I've deferred some work for later. Now before we progress further, it's future me's job to clean things up a bit.

## Keyboard makes an annoying beep sound
You'll notice that when we move around, the keyboard presses trigger an annoying beep, this is because the program has a default handler for keypresses. We need some way to intercept a keypress and handle it ourselves.

A lot of tutorials will show the old way of doing things, which swiftui doesn't really support anymore. In Swiftui, handlers can be added as modifiers to view components.

<View/appView.swift>:
```
struct appView: View {
    
    var body: some View {
        VStack{
            // All of the components
        }
        .onKeyPress(action: { _ in
            return .handled})
    }
}
```

This is good, but it may not work just yet, because key preses are dispatched from the focussed component, which may not be our app. We can fix this though.

```
struct appView: View {

    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack{
            // ...
        }
        .focusable()
        .focused($isFocused)
        .onAppear {
            isFocused = true}
        .onKeyPress(action: { _ in
            return .handled})
    }
}
```

And just like that, the keypress sound is gone!

## Vertex Menagerie
Some resources are lumped, but their interface is cluttering the renderer's constructor. Here's the code to load and bundle models:

<View/Renderer.swift>:
```
menagerie = vertexMenagerie();
menagerie.consume(mesh: ObjMesh(filename: "cube"), meshType: OBJECT_TYPE_CUBE);
menagerie.consume(mesh: ObjMesh(filename: "ground"), meshType: OBJECT_TYPE_GROUND);
menagerie.consume(mesh: ObjMesh(filename: "mouse"), meshType: OBJECT_TYPE_MOUSE);
menagerie.consume(mesh: ObjMesh(filename: "light"), meshType: OBJECT_TYPE_POINT_LIGHT);
menagerie.finalize(device: metalDevice);
```

These lines are repetitive, and furthermore if we decide to change one of the models, we'll need to dive into it. The block can be improved a little with a dictionary.
```
let modelInfo: [Int32: String] = [
    OBJECT_TYPE_CUBE: "cube",
    OBJECT_TYPE_GROUND: "ground",
    OBJECT_TYPE_MOUSE: "mouse",
    OBJECT_TYPE_POINT_LIGHT: "light"]
menagerie = vertexMenagerie();
for (objectType, modelName) in modelInfo {
    menagerie.consume(mesh: ObjMesh(filename: modelName), 
        meshType: objectType);
}
menagerie.finalize(device: metalDevice);
```

## Material Lump
Similarly, consider the code for material loading.
```
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
```

We construct all of the materials individually, then feed them to the material lump. But why not let the material lump consume the filenames and then manage the temporary texture creation and blits internally?

First we'll give the MaterialLump an array to store temporary textures, along with the device and texture allocator, which will be needed to create them.

```
class MaterialLump {
        
    // ...
    var tempTextures: [Material]
    var device: MTLDevice
    var allocator: MTKTextureLoader
    
    init(device: MTLDevice, allocator: MTKTextureLoader, 
        layerCount: Int, queue: MTLCommandQueue, 
        format: MTLPixelFormat) {
        
        // ...
        
        tempTextures = []
        
        self.allocator = allocator
        self.device = device
    }

}
```

Then upon consumption, we create a temporary texture. The blit command encoder can record the pending copy operation, and the temporary texture is stored so that when the copies are flushed the temporary texture can be read.

```
class MaterialLump {
    
    // ...

    func consume(filename: String, layer: Int32) {
        
        let newMaterial = Material(
            device: device, allocator: allocator, 
            filename: filename, filenameExtension: "png")
        
        blitCommandEncoder.copy(
            from: newMaterial.texture, 
            sourceSlice: 0, sourceLevel: 0,
            to: texture, 
            destinationSlice: Int(layer), destinationLevel: 0,
            sliceCount: 1, levelCount: 1
        );
        
        tempTextures.append(newMaterial)
    }

}
```

Finalization is simple, after the blit commands have executed we can destroy the temporary textures.

```
class MaterialLump {

    // ...
    
    func finalize() {
        blitCommandEncoder.endEncoding();
        commandBuffer.commit();
        commandBuffer.waitUntilCompleted();
        
        tempTextures = []
    }

}
```

Now with the use of a dictionary the renderer's constructor gets a lot simpler.

```
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
```

As a practice exercise, try doing something similar with the skybox!