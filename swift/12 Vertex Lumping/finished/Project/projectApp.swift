//
//  projectApp.swift
//  Project
//
//  Created by Andrew Mengede on 3/3/2022.
//

import SwiftUI

@main
struct ProjectApp: App {
    
    /*
     We want the game state to be owned by the App,
     not the renderer.
     */
    @StateObject private var gameScene = GameScene()
    
    var body: some Scene {
        
        //create a view of the underlying scene data
        WindowGroup {
            appView().environmentObject(gameScene)
        }
    }
}
