//
//  Page_ViewController.swift
//  Hang Weather
//
//  Created by Fabio Magarelli on 04/05/2020.
//  Copyright © 2020 Fabio Magarelli. All rights reserved.
//

// Thank you Seemu APPS for the tutorial on how to configure a scroll page view:
// https://www.youtube.com/watch?v=RVAtqQ8CyKM&t=748s

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import ProgressHUD

class Page_ViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, CLLocationManagerDelegate {
    
    let OWM_API_KEY = API_KEYS.OWM_API_KEY
    let OWM_URL = "https://api.openweathermap.org/data/2.5/weather"
    let locationManager = CLLocationManager()
   
    lazy var orderedViewController : [UIViewController] = {
        return [
            self.newVC(ViewController: "settings"),
            self.newVC(ViewController: "today"),
            self.newVC(ViewController: "documentation")
        ]
    }()

    var pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ProgressHUD.show()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations[locations.count - 1]
        if loc.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            process_location_info(loc: loc)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        locationUnavailableAlert()
        let loc = CLLocation.init(coordinate: CLLocationCoordinate2D(latitude: 37.33182, longitude:  -122.03118), altitude: 0.0, horizontalAccuracy: CLLocationAccuracy(), verticalAccuracy: CLLocationAccuracy(), course: CLLocationDirection(), speed: CLLocationSpeed(), timestamp: Date())
        process_location_info(loc: loc)
    }
    
    func process_location_info(loc: CLLocation) {
        let latitude = String(loc.coordinate.latitude)
        let longitude = String(loc.coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) -> Void in
            guard error == nil else {
                weatherStruct.city = "Unavailable"
                return
            }
            guard placemarks!.count > 0 else {
                weatherStruct.city = "Unavailable"
                return
            }
            let pm = placemarks![0]
            weatherStruct.city = String(pm.locality!)
        })
        
        
        let params : [String:String] = ["lat":latitude,"lon":longitude,"appid":OWM_API_KEY]
        
        getWeatherData(url: OWM_URL, parameters: params)
    }
    
    func getWeatherData(url: String, parameters: [String:String]) {
        AF.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if (response.error != nil) {
                self.locationUnavailableAlert()
            } else {
                let weatherJSON : JSON = JSON(response.value!)
                self.updateWeatherData(json: weatherJSON)
            }
        }
    }
    
    func updateWeatherData(json:JSON){
        let timezoneOffset =  Double(TimeZone.current.secondsFromGMT())
        let calendar = Calendar.current
        let sunrise = NSDate(timeIntervalSince1970: TimeInterval(json["sys"]["sunrise"].int!) + timezoneOffset)
        let sunset = NSDate(timeIntervalSince1970: TimeInterval(json["sys"]["sunset"].int!) + timezoneOffset)
        let sunrise_sec = Float((calendar.component(.hour, from: sunrise as Date) * 3600) + (calendar.component(.minute, from: sunrise as Date) * 60) + calendar.component(.second, from: sunrise as Date))
        let sunset_sec = Float((calendar.component(.hour, from: sunset as Date) * 3600) + (calendar.component(.minute, from: sunset as Date) * 60) + calendar.component(.second, from: sunset as Date))

        weatherStruct.desc = json["weather"][0]["main"].string!
        weatherStruct.temp = json["main"]["temp"].float!
        weatherStruct.hum = json["main"]["humidity"].int!
        weatherStruct.windSpeed = json["wind"]["speed"].float!
        weatherStruct.pressure = json["main"]["pressure"].int!
        weatherStruct.sunrise = sunrise_sec
        weatherStruct.sunset = sunset_sec
        if weatherStruct.city == "" {
            weatherStruct.city = json["name"].string!
        }
        ProgressHUD.dismiss()
        
        self.dataSource = self
        if orderedViewController.first != nil {
            let secondViewController = orderedViewController[1]
            setViewControllers([secondViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        self.delegate = self
        configurePageControl()
    }
    
    func locationUnavailableAlert () {
        ProgressHUD.dismiss()
        let alert = UIAlertController(title: "Location Unavailable", message: "There was an error with your GPS Location, please make sure you allowed GPS location and try again.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        alert.addAction(dismissAction)
        self.present(alert, animated: true)
    }
    
    func configurePageControl(){
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 100, width: UIScreen.main.bounds.width, height: 50))
        pageControl.numberOfPages = orderedViewController.count
        pageControl.currentPage = 1
//        pageControl.tintColor = UIColor.black
//        pageControl.pageIndicatorTintColor = UIColor.white
//        pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
    
    func newVC(ViewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ViewController)
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
           guard let viewControllerIndex = orderedViewController.firstIndex(of: viewController) else {
               return nil
           }
           let previousIndex = viewControllerIndex - 1
           guard previousIndex >= 0 else {
               // uncomment the following line to allow pages scroll loop
               // return orderedViewController.last
               return nil
           }
           guard orderedViewController.count > previousIndex else {
               return nil
           }
           return orderedViewController[previousIndex]
       }
       
       func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
           guard let viewControllerIndex = orderedViewController.firstIndex(of: viewController) else {
               return nil
           }
           let nextIndex = viewControllerIndex + 1
           guard orderedViewController.count != nextIndex else {
               // uncomment the following line to allow pages scroll loop
               // return orderedViewController.first
               return nil
           }
           guard orderedViewController.count > nextIndex else {
               return nil
           }
           return orderedViewController[nextIndex]
       }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewController.firstIndex(of: pageContentViewController)!
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


struct DayNightColors {
    static let day : [String] = [
        "007BBA",
        "00A9E2",
        "7CCDF4",
        "EBF2FA",
    ]
    static let dawn_dusk : [String] = [
        "FF9B71",
        "FFCA3A",
        "FF9B71",
    ]
    static let night : [String] = [
        "03256C",
        "000000",
        "03256C",
    ]
}

struct weatherStruct {
    static var city : String = ""
    static var desc : String = ""
    static var temp : Float = 0.0
    static var hum : Int = 0
    static var windSpeed : Float = 0.0
    static var pressure : Int = 0
    static var sunrise : Float = 0.0
    static var sunset : Float = 0.0
}

struct emojiWeather {
    static let emojiDict : [String:String] = [
        "Clear_day" : "☀️",
        "Clear_night" : "🌙",
        "Clouds" : "☁️",
        "Drizzle" : "🌦️",
        "Rain" : "🌧️",
        "Thunderstorm" : "⛈️",
        "Snow": "❄️",
        "Windy": "🌬️",
        "noWindy" : "🍃",
        "Humidity" : "💧"
    ]
}
