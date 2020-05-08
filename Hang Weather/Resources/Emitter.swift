//
//  Emitter.swift
//  Hang Weather
//
//  Created by Fabio Magarelli on 04/05/2020.
//  Copyright © 2020 Fabio Magarelli. All rights reserved.
//

import UIKit

class Emitter {
    static func get(with image: UIImage, type: Dictionary<String, Float>) -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterShape = CAEmitterLayerEmitterShape.line
        emitter.emitterCells = generateEmitterCells(with: image, type: type)
        
        return emitter
    }
    
    static func generateEmitterCells(with image: UIImage, type: Dictionary<String, Float>) -> [CAEmitterCell] {
        var cells = [CAEmitterCell]()
        
        let cell = CAEmitterCell()
        cell.contents = image.cgImage
        cell.birthRate = type["birthrate"]!
        cell.lifetime = type["lifetime"]!
        cell.velocity = CGFloat(type["velocity"]!)
        cell.emissionLongitude = (180 * (.pi/180))
        cell.emissionRange = CGFloat(type["emissionRange"]! * (.pi/180))
        cell.scale = CGFloat(type["scale"]!)
        cell.scaleRange = CGFloat(type["scaleRange"]!)
        
        cells.append(cell)
        
        return cells
    }
}

struct particleSettings {
    static let rain = [
        "birthrate": Float(5.0),
        "lifetime" : Float(5.0),
        "velocity" : Float(500.0),
        "emissionRange" : Float(0.0),
        "scale" : Float(0.03),
        "scaleRange" : Float(0.02)
    ]
    static let heavyRain = [
        "birthrate": Float(40.0),
        "lifetime" : Float(5.0),
        "velocity" : Float(700.0),
        "emissionRange" : Float(0.0),
        "scale" : Float(0.03),
        "scaleRange" : Float(0.02)
    ]
    static let drizzle = [
        "birthrate": Float(1.0),
        "lifetime" : Float(5.0),
        "velocity" : Float(400.0),
        "emissionRange" : Float(0.0),
        "scale" : Float(0.03),
        "scaleRange" : Float(0.02)
    ]
    static let snow = [
        "birthrate": Float(1.0),
        "lifetime" : Float(50),
        "velocity" : Float(25),
        "emissionRange" : Float(45),
        "scale" : Float(0.1),
        "scaleRange" : Float(0.1)
    ]
}
