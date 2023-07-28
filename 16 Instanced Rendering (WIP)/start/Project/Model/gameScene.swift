//
//  Scene.swift
//  Transformations
//
//  Created by Andrew Mengede on 2/3/2022.
//

import Foundation
import SwiftUI

class GameScene : ObservableObject {
    
    @Published var player: Camera
    @Published var mouse: Billboard
    @Published var sun: Light
    @Published var spotlight: Light
    var mouseDelta: Point2D
    @Published var cubes: [Entity]
    @Published var groundTiles: [Entity]
    @Published var pointLights: [BrightBillboard]
    
    
    init() {
        
        groundTiles = []
        cubes = []
        pointLights = []
        mouseDelta = Point2D(x: 0.0, y: 0.0)
        
        player = Camera(position: [-6.0, 6.0, 4.0], eulers: [0.0, -15.0, -45.0]);
        
        mouse = Billboard(position: [0.0, 0.0, 2.7]);
        
        let newSpotlight = Light(color: [1.0, 0.0, 0.0])
        newSpotlight.declareSpotlight(position: [-2, 0.0, 3.0], eulers: [0.0, 0.0, 180.0], eulerVelocity: [0.0, 0.0, 45.0])
        spotlight = newSpotlight;
        
        let newSun = Light(color: [1.0, 1.0, 0.0])
        newSun.declareDirectional(eulers: [0.0, 135.0, 45.0])
        sun = newSun
        sun.update()
        
        cubes.append(Entity(position: [0.0, 0.0, 1.0], eulers: [0.0, 0.0, 0.0]))
        
        for x in stride(from: Float(-10), through: Float(10), by: Float(4)) {
            for y in stride(from: Float(-10), through: Float(10), by: Float(4)) {
                groundTiles.append(Entity(position: [x, y, 0.0], eulers: [90.0, 0.0, 0.0]))
            }
        }
        
        var newPointLight = BrightBillboard(position: [0.0, 0.0, 1.0], color: [0.0, 1.0, 1.0], rotation_center: [0.0, 0.0, 1.0], pathRadius: 2.0, pathPhi: 60.0, angularVelocity: 1.0)
        pointLights.append(newPointLight)
        newPointLight = BrightBillboard(position: [0.0, 0.0, 1.0], color: [0.0, 0.0, 1.0], rotation_center: [0.0, 0.0, 1.0], pathRadius: 3.0, pathPhi: 0.0, angularVelocity: 2.0)
        pointLights.append(newPointLight)
        
    }
    
    func updateView() {
        self.objectWillChange.send()
    }
    
    func update() {
        
        var movement: simd_float2 = [0.0, 0.0];
        if InputController.controller.keysPressed.contains(.keyW) {
            movement[0] += 0.1;
        }
        else if InputController.controller.keysPressed.contains(.keyA) {
            movement[1] += 0.1;
        }
        else if InputController.controller.keysPressed.contains(.keyS) {
            movement[0] -= 0.1;
        }
        else if InputController.controller.keysPressed.contains(.keyD) {
            movement[1] -= 0.1;
        }
        player.move(amount: movement);
                
        let newMouseDelta: Point2D = InputController.controller.mouseDelta
        if (
            abs(mouseDelta.x - newMouseDelta.x)
            + abs(mouseDelta.y - newMouseDelta.y) > 0.00001) {
            mouseDelta = newMouseDelta
            spinPlayer(angles: mouseDelta)
        }
        
        for cube in cubes {
            cube.update();
        }
        
        for tile in groundTiles {
            tile.update();
        }
        
        player.update()
        
        spotlight.update()
        
        for light in pointLights {
            light.update(viewerPosition: player.position)
        }
        
        mouse.update(viewerPosition: player.position)
        
        updateView()
    }
    
    func spinPlayer(angles: Point2D) {
        
        let dTheta: Float = angles.x
        let dPhi: Float = angles.y
        
        player.eulers.z -= 0.1 * dTheta
        player.eulers.y += 0.1 * dPhi
        
        if player.eulers.z < 0 {
            player.eulers.z += 360
        } else if player.eulers.z > 360 {
            player.eulers.z -= 360
        }
        
        if player.eulers.y < -89 {
            player.eulers.y = -89
        } else if player.eulers.y > 89 {
            player.eulers.y = 89
        }
        
    }
    
}
