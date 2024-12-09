//
//  GameScene.swift
//  Transformations
//
//  Created by Andrew Mengede on 2/3/2022.
//

import Foundation
import SwiftUI

class GameScene: ObservableObject {
    
    @Published var player: Camera
    @Published var renderables: [Int32:[Entity]]
    @Published var firstInstances: [Int32:Int]
    @Published var instanceCounts: [Int32:Int]
    var mouse: Billboard
    @Published var sun: Light
    @Published var spotlight: Light
    var mouseDelta: Point2D
    var cubes: [Entity]
    var groundTiles: [Entity]
    @Published var pointLights: [BrightBillboard]
    
    
    init() {
        
        groundTiles = []
        cubes = []
        pointLights = []
        mouseDelta = Point2D(x: 0.0, y: 0.0)
        renderables = [:]
        firstInstances = [:]
        instanceCounts = [:]
        //firstInstancesFlat = []
        
        player = Camera(position: [-6.0, 6.0, 4.0], eulers: [0.0, -15.0, -45.0], id: OBJECT_TYPE_PLAYER)
        
        mouse = Billboard(
            position: [0.0, 0.0, 2.7], id: OBJECT_TYPE_MOUSE, color: simd_float3(repeating: 1.0))
        
        let newSpotlight = Light(color: [1.0, 0.0, 0.0])
        newSpotlight.declareSpotlight(position: [-2, 0.0, 3.0], eulers: [0.0, 0.0, 180.0], eulerVelocity: [0.0, 0.0, 45.0])
        spotlight = newSpotlight
        
        let newSun = Light(color: [1.0, 1.0, 0.0])
        newSun.declareDirectional(eulers: [0.0, 135.0, 45.0])
        sun = newSun
        sun.update()
        
        cubes.append(
            Entity(
                position: [0.0, 0.0, 1.0], eulers: [0.0, 0.0, 0.0],
                id: OBJECT_TYPE_CUBE, color: simd_float3(repeating: 1.0))
        )
        
        for x in stride(from: Float(-10), through: Float(10), by: Float(4)) {
            for y in stride(from: Float(-10), through: Float(10), by: Float(4)) {
                groundTiles.append(
                    Entity(
                        position: [x, y, 0.0], eulers: [90.0, 0.0, 0.0],
                        id: OBJECT_TYPE_GROUND, color: simd_float3(repeating: 1.0))
                )
            }
        }
        
        pointLights.append(BrightBillboard(position: [0.0, 0.0, 1.0], color: [0.0, 1.0, 1.0], rotation_center: [0.0, 0.0, 1.0], pathRadius: 2.0, pathPhi: 60.0, angularVelocity: 1.0, id: OBJECT_TYPE_POINT_LIGHT))
        pointLights.append(BrightBillboard(position: [0.0, 0.0, 1.0], color: [0.0, 0.0, 1.0], rotation_center: [0.0, 0.0, 1.0], pathRadius: 3.0, pathPhi: 0.0, angularVelocity: 2.0, id: OBJECT_TYPE_POINT_LIGHT))
        
        captureRenderables()
        
    }
    
    private func captureRenderables() {
        var offset = 0
        captureRenderable(key: OBJECT_TYPE_CUBE, entities: cubes, offset: &offset)
        captureRenderable(key: OBJECT_TYPE_GROUND, entities: groundTiles, offset: &offset)
        captureRenderable(key: OBJECT_TYPE_MOUSE, entities: [mouse], offset: &offset)
        captureRenderable(key: OBJECT_TYPE_POINT_LIGHT, entities: pointLights, offset: &offset)        
        //firstInstancesFlat = firstInstances.sorted(by: { $0.0 < $1.0 })
    }
    
    private func captureRenderable(key: Int32, entities: [Entity], offset: inout Int) {
        renderables[key] = []
        firstInstances[key] = offset
        renderables[key]?.append(contentsOf: entities)
        let count = renderables[key]?.count ?? 0
        instanceCounts[key] = count
        offset += count
    }
    
    func updateView() {
        self.objectWillChange.send()
    }
    
    func update() {
        let speed: Float = 0.1
        var movement: simd_float2 = [0.0, 0.0]
        if InputController.controller.keysPressed.contains(.keyW) {
            movement[0] += speed
        }
        else if InputController.controller.keysPressed.contains(.keyA) {
            movement[1] += speed
        }
        else if InputController.controller.keysPressed.contains(.keyS) {
            movement[0] -= speed
        }
        else if InputController.controller.keysPressed.contains(.keyD) {
            movement[1] -= speed
        }
        player.move(amount: movement)
                
        let newMouseDelta: Point2D = InputController.controller.mouseDelta
        if (
            abs(mouseDelta.x - newMouseDelta.x)
            + abs(mouseDelta.y - newMouseDelta.y) > 0.00001) {
            mouseDelta = newMouseDelta
            spinPlayer(angles: mouseDelta)
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
