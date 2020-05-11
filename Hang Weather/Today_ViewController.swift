//
//  Today_ViewController.swift
//  Hang Weather
//
//  Created by Fabio Magarelli on 04/05/2020.
//  Copyright © 2020 Fabio Magarelli. All rights reserved.
//

import UIKit
import AnimatedGradientView
import CSV

class Today_ViewController: UIViewController {
    
    let cloudWeather = ["Clouds","Drizzle","Rain","Thunderstorm","Snow"]
    
  
    @IBOutlet weak var clouds_view: AnimatedGradientView!
    @IBOutlet weak var thunders: UIView!
    
    @IBOutlet weak var date_label: UILabel!
    @IBOutlet weak var time_label: UILabel!
    
    @IBOutlet weak var temp_label: UILabel!
    @IBOutlet weak var desc_label: UILabel!
    @IBOutlet weak var hum_label: UILabel!
    @IBOutlet weak var windSpeed_label: UILabel!
    @IBOutlet weak var city_label: UILabel!
    @IBOutlet weak var eta1_label: UILabel!
    @IBOutlet weak var eta2_label: UILabel!
    
    @IBOutlet weak var etaLaundry_label: UILabel!
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO display weather info
        
        city_label.text = weatherStruct.city
        
        let dayTime : String = updateDayNightCycle()
        displayCurrentDateTime()
        displayPrecipitations(dayTime: dayTime)
        var sun = 0
        var rain = 0
        var outdoorScore : Float?
        if cloudWeather.contains(weatherStruct.desc) || dayTime == "night" {
            sun = 0
            if cloudWeather.contains(weatherStruct.desc) && weatherStruct.desc != "Clouds" {
                rain = 1
            }
            if dayTime != "night" {
                outdoorScore = calculateOutdoorScore(pressure: Float(weatherStruct.pressure), humidity: Float(weatherStruct.hum), temperature: weatherStruct.temp, weather: weatherStruct.desc, wind_speed: weatherStruct.windSpeed, sun: sun, rain: rain)
            } else {
                outdoorScore = 0
            }
        } else {
            sun = 1
            rain = 0
            outdoorScore = calculateOutdoorScore(pressure: Float(weatherStruct.pressure), humidity: Float(weatherStruct.hum), temperature: weatherStruct.temp, weather: weatherStruct.desc, wind_speed: weatherStruct.windSpeed, sun: sun, rain: rain)
        }
        if (outdoorScore != nil) {
            if outdoorScore! > 4 {
                outdoorScore! = 4
            }
            let out = Int(round(outdoorScore! * 10))
            if out > 35 {
                etaLaundry_label.text = "1 Hour"
            } else if out <= 35 && out > 30 {
                etaLaundry_label.text = "2 Hours"
            } else if out <= 30 && out > 25 {
                etaLaundry_label.text = "3 Hours"
            } else if out <= 25 && out > 20 {
                etaLaundry_label.text = "4 Hours"
            } else if out <= 20 && out > 15 {
                etaLaundry_label.text = "5 Hours"
            } else if out <= 15 && out > 10 {
                etaLaundry_label.text = "6 Hours"
            } else if out <= 10 && out > 5 {
                etaLaundry_label.text = "> 6 Hours"
            } else if out <= 5 {
                etaLaundry_label.text = "\u{221E}"
            }
        } else {
            etaLaundry_label.text = "Unavailable \u{2639}"
        }
        
        if ["iPhone SE","iPhone 5s","iPhone 5c","iPhone 5"].contains(UIDevice.modelName) {
            resize_labels_iphoneSE()
        }
    }
    
    func resize_labels_iphoneSE(){
        let labels : [UILabel] = [date_label,time_label,temp_label,desc_label,hum_label,windSpeed_label,city_label,etaLaundry_label,eta1_label,eta2_label]
        for lab in labels {
            lab.font = lab.font.withSize(lab.font.pointSize * 0.6)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let dayTime : String = updateDayNightCycle()
        let customTempWSPD = formatTempWSPD()
        let temperature = customTempWSPD[0]
        let windspeed = customTempWSPD[1]

        displayCurrentWeather(description: weatherStruct.desc, temperature: temperature, humidity: weatherStruct.hum, windspeed: windspeed)
        displayCurrentDateTime()
        displayPrecipitations(dayTime: dayTime)
        setPageControlHidden(hidden: false)
    }
    
    func formatTempWSPD() -> [String] {
        let defaults = UserDefaults.standard
        var temperature : String = ""
        var windspeed : String = ""
        
        if let temp_unit = defaults.object(forKey: "Temp_unit") as? String {
            if temp_unit == "°C" {
                temperature = String(Int(round(weatherStruct.temp - 273.16))) + "°C"
            } else if temp_unit == "°F" {
                temperature = String(Int(round((weatherStruct.temp - 273.16) * 9/5 + 32))) + "°F"
            } else if temp_unit == "K" {
                temperature = String(Int(round(weatherStruct.temp))) + "K"
            }
        } else {
            temperature = String(Int(round(weatherStruct.temp - 273.16))) + "°C"
        }
        if let wspd_unit = defaults.object(forKey: "Wspd_unit") as? String {
            if wspd_unit == "mph" {
                windspeed = String(round(weatherStruct.windSpeed * 0.62 * 100) / 100) + "mph"
            } else {
                windspeed = String(weatherStruct.windSpeed) + "Km/h"
            }
        } else {
            windspeed = String(weatherStruct.windSpeed) + "Km/h"
        }
        return [temperature,windspeed]
    }
    
    
    func calculateOutdoorScore(pressure:Float,humidity:Float,temperature:Float,weather:String,wind_speed:Float,sun:Int,rain:Int) -> Float? {
        if rain == 1 {
            return 0.0
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
            var indoorScore = (pressure * corr_dict["msl"]!) + (humidity * corr_dict["rhum"]!)
            indoorScore = indoorScore + (temperature * corr_dict["temp"]!)
            var outdoorScore = indoorScore + (Float(sun) * corr_dict["sun"]!)
            outdoorScore = outdoorScore + (wind_speed * corr_dict["wdsp"]!) * Float(abs(rain - 1))
            if outdoorScore > 0 {
                outdoorScore = log10(outdoorScore)
            }
            return outdoorScore
        } else {
            return nil
        }
    }
        
    
    func displayCurrentDateTime(){
        let month_dict = [
            1 : "Jan",
            2 : "Feb",
            3 : "Mar",
            4 : "Apr",
            5 : "May",
            6 : "Jun",
            7 : "Jul",
            8 : "Aug",
            9 : "Sep",
            10 : "Oct",
            11 : "Nov",
            12 : "Dec"
        ]
        
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = month_dict[Int(calendar.component(.month, from: date))]
        let year = calendar.component(.year, from:date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        date_label.text = String(day) + " " + String(month!) + " " + String(year)
        time_label.text = String(format:"%02d:%02d", hour, minutes)
    }
    
    func displayCurrentWeather(description:String,temperature:String,humidity:Int,windspeed:String){
        desc_label.text = description
        temp_label.text = temperature
        hum_label.text = "Humidity " + String(humidity) + "%"
        windSpeed_label.text = "Wind speed " + windspeed
    }
    
    func updateDayNightCycle() -> String{
        let labels : [UILabel] = [date_label,time_label,temp_label,desc_label,hum_label,windSpeed_label,city_label,etaLaundry_label,eta1_label,eta2_label]
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        let secondsNow = Float((hour * 3600) + (minutes * 60) + (seconds))
        if secondsNow < weatherStruct.sunrise - 1800 || secondsNow > weatherStruct.sunset + 1800 {
            animatedGradientBackgound(colors: DayNightColors.night)
            for lab in labels {
                lab.textColor = UIColor.white
            }
            return "night"
        } else if secondsNow > weatherStruct.sunrise + 1800 && secondsNow < weatherStruct.sunset - 1800 {
            animatedGradientBackgound(colors: DayNightColors.day)
            for lab in labels {
                lab.textColor = UIColor.black
            }
            return "day"
        } else {
            animatedGradientBackgound(colors: DayNightColors.dawn_dusk)
            for lab in labels {
                lab.textColor = UIColor.black
            }
            return "dawn_dusk"
        }
    }
    
    func displayPrecipitations(dayTime: String){
        hum_label.text?.append(" " + emojiWeather.emojiDict["Humidity"]!)
        if weatherStruct.windSpeed < 5 {
            windSpeed_label.text?.append(" " + emojiWeather.emojiDict["noWindy"]!)
        } else {
            windSpeed_label.text?.append(" " + emojiWeather.emojiDict["Windy"]!)
        }
        if cloudWeather.contains(weatherStruct.desc) {
            displayClouds(dayTime: dayTime)
            if weatherStruct.desc == "Drizzle" {
                desc_label.text?.append(" " + emojiWeather.emojiDict["Drizzle"]!)
                generatePrecipitation(image: UIImage(named: "raindrop")!, type: particleSettings.drizzle)
            } else if weatherStruct.desc == "Rain" {
                desc_label.text?.append(" " + emojiWeather.emojiDict["Rain"]!)
                generatePrecipitation(image: UIImage(named: "raindrop")!, type: particleSettings.rain)
            } else if weatherStruct.desc == "Thunderstorm" {
                desc_label.text?.append(" " + emojiWeather.emojiDict["Thunderstorm"]!)
                generatePrecipitation(image: UIImage(named: "raindrop")!, type: particleSettings.heavyRain)
                generateThunders()
            } else if weatherStruct.desc == "Snow" {
                desc_label.text?.append(" " + emojiWeather.emojiDict["Snow"]!)
                generatePrecipitation(image: UIImage(named: "snowball")!, type: particleSettings.snow)
            } else {
                desc_label.text?.append(" " + emojiWeather.emojiDict["Clouds"]!)
            }
        } else {
            if dayTime == "night"{
                desc_label.text?.append(" " + emojiWeather.emojiDict["Clear_night"]!)
            } else {
                desc_label.text?.append(" " + emojiWeather.emojiDict["Clear_day"]!)
            }
        }
    }
    
    
    func animatedGradientBackgound(colors: [String]) {
        let animatedGradient = AnimatedGradientView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 5, height: UIScreen.main.bounds.width * 5))
        animatedGradient.direction = .right
        animatedGradient.animationValues = [
            (colors: colors, .up, .conic),
            (colors: colors, .right, .conic),
            (colors: colors, .down, .conic),
            (colors: colors, .left, .conic),
            (colors: colors, .down, .conic),
            (colors: colors, .right, .conic),
        ]
        animatedGradient.animationDuration = 5
        animatedGradient.alpha = 1
        view.addSubview(animatedGradient)
        view.sendSubviewToBack(animatedGradient)
    }
    
    
    func displayClouds(dayTime: String){
        let clouds = clouds_view
        var cloud_color : [UIColor] = []
        if dayTime == "night" {
            cloud_color.append(UIColor.black.withAlphaComponent(0))
            cloud_color.append(UIColor.init(red: 33/255, green: 33/255, blue: 33/255, alpha: 1))
        } else {
            cloud_color.append(UIColor.white.withAlphaComponent(0))
            cloud_color.append(UIColor.init(red: 229/255, green: 229/255, blue: 229/255, alpha: 1))
        }
        UIView.animate(withDuration: 5, animations: {
            clouds!.colors = [cloud_color]
            clouds!.direction = .up
        }, completion: {
            (completed: Bool) -> Void in
            UIView.animate(withDuration: 2, animations: {
                clouds!.colors = [[cloud_color[0],cloud_color[1].withAlphaComponent(0.5)]]
                clouds!.direction = .up
            }, completion: {
                (completed: Bool) -> Void in
                self.displayClouds(dayTime: dayTime)
            })
        })
        
    }
    

    
    func generateThunders() {
        UIView.animate(withDuration: 0.5, animations: {
            self.thunders.alpha = 0.8
        }, completion: {
            (completed: Bool) -> Void in
            UIView.animate(withDuration: 1, animations: {
                self.thunders.alpha = 0.0
            }, completion: {
                (completed: Bool) -> Void in
                sleep(UInt32.random(in: 3 ... 10))
                self.generateThunders()
            })
            
        })
    }
    
    func generatePrecipitation (image: UIImage, type: Dictionary<String, Float>) {
        let emitter = Emitter.get(with: image, type: type)
        emitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.maxX / 2, y: -50)
        emitter.emitterSize = CGSize(width: UIScreen.main.bounds.maxX, height: 2)
        view.layer.addSublayer(emitter)
        
    }
    
    func setPageControlHidden (hidden: Bool)
    {
        for subView in parent!.view.subviews
        {
            if subView is UIScrollView
            {
                subView.frame = parent!.view.bounds
            }
            else if subView is UIPageControl
            {
                subView.isHidden = hidden
            }
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
