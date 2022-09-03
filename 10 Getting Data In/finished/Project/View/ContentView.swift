//
//  ContentView.swift
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

import SwiftUI
import MetalKit

struct ContentView: UIViewRepresentable {
    
    @EnvironmentObject var gamescene: GameScene
    
    func makeCoordinator() -> Renderer {
        Renderer(self, gamescene: gamescene)
    }
    
    func makeUIView(context: UIViewRepresentableContext<ContentView>) -> MTKView {
        
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        mtkView.isPaused = false
        mtkView.depthStencilPixelFormat = .depth32Float
        
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
