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
        
        guard let metalDevice = MTLCreateSystemDefaultDevice() else{
            fatalError("Could not create device")
        }
        let frame = CGRect(x:0,y:0,width:800,height:600)
        let mtkView = MTKView(frame: frame, device: metalDevice)
        
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        mtkView.framebufferOnly = false
        mtkView.clearColor = MTLClearColor(red:1, green:1, blue:0, alpha: 1)
        mtkView.drawableSize = mtkView.frame.size
        mtkView.isPaused = false
        
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<MetalView>) {
    }
}
