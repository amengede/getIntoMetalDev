//
//  ContentView.swift
//  Metal1
//
//  Created by Andrew Mengede on 11/12/21.
//

import SwiftUI
import MetalKit

struct MetalView: NSViewRepresentable {
    // make, update
    
    func makeCoordinator() -> Renderer {
        Renderer(self)
    }
    
    func makeNSView(context: NSViewRepresentableContext<MetalView>) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.clearColor = MTLClearColor(red:1, green:0, blue:0, alpha: 1)
        mtkView.drawableSize = mtkView.frame.size
        
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<MetalView>) {
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MetalView()
    }
}
