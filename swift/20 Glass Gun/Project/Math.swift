//
//  Math.swift
//  Project
//
//  Created by Sergey on 27.11.2024.
//

extension Float {
    func degreesToRadians() -> Float {
        self * .pi / 180.0
    }
    
    func radiansToDegrees() -> Float {
        self *  180.0 / .pi
    }
}
