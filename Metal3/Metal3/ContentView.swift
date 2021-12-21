//
//  ContentView.swift
//  Metal3
//
//  Created by Andrew Mengede on 14/12/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MetalView()
            .frame(width: 600, height: 600)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
