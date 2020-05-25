//
//  Settings_ViewController.swift
//  Hang Weather
//
//  Created by Fabio Magarelli on 08/05/2020.
//  Copyright © 2020 Fabio Magarelli. All rights reserved.
//

import UIKit

class Settings_ViewController: UIViewController {
    
    
    @IBOutlet weak var tempUnit_control: UISegmentedControl!
    @IBOutlet weak var wspd_control: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        
        if let temp_unit = defaults.object(forKey: "Temp_unit") as? String {
            switch temp_unit {
            case "°C":
                tempUnit_control.selectedSegmentIndex = 0
            case "°F":
                tempUnit_control.selectedSegmentIndex = 1
            case "K":
                tempUnit_control.selectedSegmentIndex = 2
            default:
                break
            }
        }
        if let wspd_unit = defaults.object(forKey: "Wspd_unit") as? String {
            switch wspd_unit {
            case "mph":
                wspd_control.selectedSegmentIndex = 1
            default:
                wspd_control.selectedSegmentIndex = 0
            }
        }
        
    }
    
    @IBAction func tempUnit_toggle(_ sender: UISegmentedControl) {
        let defaults = UserDefaults.standard
        switch tempUnit_control.selectedSegmentIndex
        {
        case 0:
            defaults.set(tempUnit_control.titleForSegment(at: 0), forKey: "Temp_unit")
        case 1:
            defaults.set(tempUnit_control.titleForSegment(at: 1), forKey: "Temp_unit")
        case 2:
            defaults.set(tempUnit_control.titleForSegment(at: 2), forKey: "Temp_unit")
        default:
            break
        }
    }
    
    @IBAction func wspd_toggle(_ sender: UISegmentedControl) {
        let defaults = UserDefaults.standard
        switch wspd_control.selectedSegmentIndex
        {
        case 0:
            defaults.set(wspd_control.titleForSegment(at: 0), forKey: "Wspd_unit")
        case 1:
            defaults.set(wspd_control.titleForSegment(at: 1), forKey: "Wspd_unit")
        default:
            break
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
