//
//  Scene.swift
//  Transformations
//
//  Created by Andrew Mengede on 2/3/2022.
//

import Foundation
import SwiftUI

/*
 In order to be considered as an environmental object,
 the game scene must conform to the "Observable" protocol.
 In order to be observable, we mark which variables will be
 "Published" upon update.
 */
class GameScene : ObservableObject {
    
    @Published var player: Entity
    @Published var cubes: [Entity]
    
    init() {
        let newPlayer = Entity()
        newPlayer.addCameraComponent(position: [-6.0, 6.0, 4.0], eulers: [0.0, 110.0, -45.0])
        player = newPlayer
        
        cubes = []
        let newCube = Entity()
        newCube.addTransformComponent(position: [0.0, 0.0, 1.0], eulers: [0.0, 0.0, 0.0])
        cubes.append(newCube)
    }
    
    func update() {
        
        player.update()
        
        for cube in cubes {
            
            cube.update()
            
        }
        
    }
    
    func spinPlayer(offset: CGSize) {
        
        let dTheta: Float = Float(offset.width)
        let dPhi: Float = Float(offset.height)
        
        player.eulers!.z -= 0.001 * dTheta
        player.eulers!.y += 0.001 * dPhi
        
        if player.eulers!.z < 0 {
            player.eulers!.z -= 360
        } else if player.eulers!.z > 360 {
            player.eulers!.z -= 360
        }
        
        if player.eulers!.y < 1 {
            player.eulers!.y = 1
        } else if player.eulers!.y > 179 {
            player.eulers!.y = 179
        }
        
    }
    
}
