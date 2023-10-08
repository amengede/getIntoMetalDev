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
    @Published var mouse: Billboard
    @Published var sun: Light
    @Published var spotlight: Light
    @Published var currentKey: String
    @Published var mouseDelta: Point2D
    @Published var cubes: [Entity]
    @Published var groundTiles: [Entity]
    @Published var pointLights: [BrightBillboard]
    
    
    init() {
        
        groundTiles = []
        cubes = []
        pointLights = []
        currentKey = ""
        mouseDelta = Point2D(x: 0, y: 0)
        
        let newPlayer = Entity()
        newPlayer.addCameraComponent(position: [-6.0, 6.0, 4.0], eulers: [0.0, -15.0, -45.0])
        player = newPlayer
        
        let newMouse = Billboard(position: [0.0, 0.0, 2.7])
        mouse = newMouse
        
        let newSpotlight = Light(color: [1.0, 0.0, 0.0])
        newSpotlight.declareSpotlight(position: [-2, 0.0, 3.0], eulers: [0.0, 0.0, 180.0], eulerVelocity: [0.0, 0.0, 45.0])
        spotlight = newSpotlight;
        
        let newSun = Light(color: [1.0, 1.0, 0.0])
        newSun.declareDirectional(eulers: [0.0, 135.0, 45.0])
        sun = newSun
        sun.update()
        
        let newCube = Entity()
        newCube.addTransformComponent(position: [0.0, 0.0, 1.0], eulers: [0.0, 0.0, 0.0])
        cubes.append(newCube)
        
        let newTile = Entity()
        newTile.addTransformComponent(position: [0.0, 0.0, 0.0], eulers: [90.0, 0.0, 0.0])
        groundTiles.append(newTile)
        
        var newPointLight = BrightBillboard(position: [0.0, 0.0, 1.0], color: [0.0, 1.0, 1.0], rotation_center: [0.0, 0.0, 1.0], pathRadius: 2.0, pathPhi: 60.0, angularVelocity: 1.0)
        pointLights.append(newPointLight)
        newPointLight = BrightBillboard(position: [0.0, 0.0, 1.0], color: [0.0, 0.0, 1.0], rotation_center: [0.0, 0.0, 1.0], pathRadius: 3.0, pathPhi: 0.0, angularVelocity: 2.0)
        pointLights.append(newPointLight)
        
    }
    
    func updateView() {
        self.objectWillChange.send()
    }
    
    func update() {
        
        if InputController.controller.keysPressed.contains(.keyW) {
            currentKey = "W"
        }
        else if InputController.controller.keysPressed.contains(.keyA) {
            currentKey = "A"
        }
        else if InputController.controller.keysPressed.contains(.keyS) {
            currentKey = "S"
        }
        else if InputController.controller.keysPressed.contains(.keyD) {
            currentKey = "D"
        }
        else {
            currentKey = ""
        }
        
        let newMouseDelta: Point2D = InputController.controller.mouseDelta
        if (
            abs(mouseDelta.x - newMouseDelta.x)
            + abs(mouseDelta.y - newMouseDelta.y) > 0.00001) {
            mouseDelta = newMouseDelta
            spinPlayer(angles: mouseDelta)
        }
        player.update()
        
        for cube in cubes {
            cube.update()
        }
        
        for ground in groundTiles {
            ground.update()
        }
        
        spotlight.update()
        
        for light in pointLights {
            light.update(viewerPosition: player.position!)
        }
        
        mouse.update(viewerPosition: player.position!)
        
        updateView()
    }
    
    func spinPlayer(angles: Point2D) {
        
        let dTheta: Float = angles.x
        let dPhi: Float = angles.y
        
        player.eulers!.z -= 0.1 * dTheta
        player.eulers!.y += 0.1 * dPhi
        
        if player.eulers!.z < 0 {
            player.eulers!.z += 360
        } else if player.eulers!.z > 360 {
            player.eulers!.z -= 360
        }
        
        if player.eulers!.y < -89 {
            player.eulers!.y = -89
        } else if player.eulers!.y > 89 {
            player.eulers!.y = 89
        }
        
    }
    
}
