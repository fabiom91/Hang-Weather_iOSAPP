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
