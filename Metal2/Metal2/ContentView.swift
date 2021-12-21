//
//  ContentView.swift
//  Metal2
//
//  Created by Andrew Mengede on 12/12/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MetalView()
            .frame(width: 800, height: 800)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

