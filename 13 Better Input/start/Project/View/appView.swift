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
    
    @EnvironmentObject var gameScene: GameScene
    
    var body: some View {
        VStack{
            
            Text("Billboards")
        
            ContentView()
                .frame(width: 800, height: 600)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            gameScene.strafePlayer(offset: gesture.translation)
                        }
                )
            
            Text("Debug Info")
            VStack{
                Text("Camera")
                HStack{
                    Text("Position")
                    VStack{
                        Text(String(gameScene.player.position![0]))
                        Text(String(gameScene.player.position![1]))
                        Text(String(gameScene.player.position![2]))
                    }
                    Text("Distance: " + String(simd.length(gameScene.player.position!)))
                    Text("Forwards")
                    VStack{
                        Text(String(gameScene.player.forwards![0]))
                        Text(String(gameScene.player.forwards![1]))
                        Text(String(gameScene.player.forwards![2]))
                    }
                    Text("Right")
                    VStack{
                        Text(String(gameScene.player.right![0]))
                        Text(String(gameScene.player.right![1]))
                        Text(String(gameScene.player.right![2]))
                    }
                    Text("Up")
                    VStack{
                        Text(String(gameScene.player.up![0]))
                        Text(String(gameScene.player.up![1]))
                        Text(String(gameScene.player.up![2]))
                    }
                }
            }
            
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
