//
//  score_system.swift
//  Hang Weather
//
//  Created by Fabio Magarelli on 25/05/2020.
//  Copyright © 2020 Fabio Magarelli. All rights reserved.
//

import Foundation
import CSV
import UIKit

class Scores {
    let cloudWeather = ["Clouds","Drizzle","Rain","Thunderstorm","Snow"]
    var outdoorRate : Float = 0.0
    var outdoorETA : String = "\u{221E}"
    
    init(dayTime:String) {
        var sun = 0
        var rain = 0
        if cloudWeather.contains(weatherStruct.desc) {
            sun = 0
            if cloudWeather.contains(weatherStruct.desc) && weatherStruct.desc != "Clouds" {
                rain = 1
            }
            if dayTime != "night" {
                outdoorRate = calculateOutdoorRate(sun: sun, rain: rain) ?? 0.0
                outdoorETA = getETAOutdoor()
            }
        } else {
            sun = 1
            rain = 0
            outdoorRate = calculateOutdoorRate(sun: sun, rain: rain) ?? 0.0
            outdoorETA = getETAOutdoor()
        }
    }
    
    func getETAOutdoor() -> String {
        var min : Float = (200 * outdoorRate) / 60
        var hours : Int = Int(min)
        min -= Float(Int(min))
        while min >= 0.6 {
            hours += 1
            min -= 0.6
        }
        let min_int = Int(round(min * 100))
        if min_int > 0 {
            return String(hours) + " Hours \n" + String(min_int) + " Min"
        } else  {
            return String(hours) + " Hours"
        }
    }
    
    
    func calculateIndoorRate() -> Float?{
        let A : Float = 1.0
        let z1 : Float = 0.000141
        let wMW : Float = 18.01528
        let R : Float = 0.0821
        let k : Float = 0.0000000000000000000000138
        let r : Float = 0.0000000001375
        let P : Float = Float(weatherStruct.pressure)
        let tempC : Float = weatherStruct.temp - 273.16
        let T :Float = weatherStruct.temp
        var u : Float = 0.0
        var pws : Float = 999.0
        
        if let filePath = Bundle.main.url(forResource: "viscosityH2O", withExtension: "csv") {
            let stream = InputStream(url: filePath)!
            let csv = try! CSVReader(stream: stream)
            var viscosity_dict : [Int:Float] = [:]
            while let row = csv.next() {
                if let value = Float(row[2]) {
                    viscosity_dict[Int(row[0])!] = value
                }
            }
            for i in 1...viscosity_dict.keys.count {
                var temp_array = Array(viscosity_dict.keys)
                temp_array.sort()
                let t = Float(temp_array[i])
                if t > tempC {
                    let j = temp_array[i-1]
                    u = viscosity_dict[j]!
                    break
                }
            }
        } else {
            return nil
        }
        
        if let filePath = Bundle.main.url(forResource: "pws", withExtension: "csv") {
            let stream = InputStream(url: filePath)!
            let csv = try! CSVReader(stream: stream)
            var pws_dict : [Int:Float] = [:]
            while let row = csv.next() {
                if let value = Float(row[2]) {
                    pws_dict[Int(row[0])!] = value
                }
            }
            for i in 1...pws_dict.keys.count {
                var temp_array = Array(pws_dict.keys)
                temp_array.sort()
                let t = Float(temp_array[i])
                if t > tempC {
                    let j = temp_array[i-1]
                    pws = pws_dict[j]!
                    break
                }
            }
        } else {
            return nil
        }
        
        let RH : Float = Float(weatherStruct.hum / 100)
        if pws != 999.0 && u != 0.0 {
            var Naz = P / R * T
            Naz = Naz * (k * T) / (6 * 3.14 * u * r)
            Naz = Naz / z1
            Naz = Naz * log((1-((RH * pws) / P)) / (1-((pws)/P)))
            let vap = Naz * A * wMW * 60 * 1000
            
            return vap
        } else {
            return nil
        }
        
    }
    
    
    func calculateOutdoorRate(sun:Int,rain:Int) -> Float?{
        if rain == 1 {
            return nil
        }
        if let filePath = Bundle.main.url(forResource: "df_corr", withExtension: "csv") {
            let stream = InputStream(url: filePath)!
            let csv = try! CSVReader(stream: stream)
            var corr_dict : [String:Float] = [:]
            while let row = csv.next() {
                if row[0] != "" {
                    corr_dict[row[0]] = Float(row[1])
                }
            }
            if let indoorRate = self.calculateIndoorRate() {
                let outdoorRate = indoorRate + (Float(sun) * corr_dict["sun"]!) + (weatherStruct.windSpeed * corr_dict["wdsp"]!)
                return outdoorRate
            }
        } else {
            return nil
        }
        return nil
    }
    
    
}
