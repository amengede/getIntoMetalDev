//
//  ContentView.swift
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

import SwiftUI
import MetalKit

struct ContentView: UIViewRepresentable {
    
    @EnvironmentObject var gameScene: GameScene
        
    func makeCoordinator() -> Renderer? {
        Renderer(self, scene: gameScene)
    }
    
    func makeUIView(context: UIViewRepresentableContext<ContentView>) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.framebufferOnly = true
        mtkView.drawableSize = mtkView.frame.size
        mtkView.isPaused = false
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<ContentView>) {
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
