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
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack{
            
            Text("Billboards")
                .onKeyPress(action: { _ in
                    print("keypress")
                    return .handled})
            
            ContentView()
                .frame(width: 800, height: 600)
            
            Text("Debug Info")
            VStack{
                Text("Camera")
                HStack{
                    Text("Position")
                    VStack{
                        Text(String(gameScene.player.position[0]))
                        Text(String(gameScene.player.position[1]))
                        Text(String(gameScene.player.position[2]))}
                    Text("Eulers: ")
                    VStack{
                        Text(String(gameScene.player.eulers[0]))
                        Text(String(gameScene.player.eulers[1]))
                        Text(String(gameScene.player.eulers[2]))}}}}
        .focusable()
        .focused($isFocused)
        .onAppear {
            isFocused = true
        }
        .onKeyPress(action: { _ in
            return .handled})
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
