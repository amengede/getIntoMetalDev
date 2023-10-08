//
//  appView.swift
//  Transformations
//
//  Created by Andrew Mengede on 2/3/2022.
//

import SwiftUI

/*
 game scene will be automatically forwarded here...
 */
struct appView: View {
    
    @EnvironmentObject var gamescene: GameScene
    
    var body: some View {
        VStack{
            
            Text("Ray Tracing!")
        
            ContentView()
                .frame(width: 800, height: 600)
            
        }
    }
}

/*
 ...but must be manually forwarded if a preview is requested
 */
struct appView_Previews: PreviewProvider {
    static var previews: some View {
        appView().environmentObject(GameScene())
    }
}
