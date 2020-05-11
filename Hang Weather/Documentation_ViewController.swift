//
//  Documentation_ViewController.swift
//  Hang Weather
//
//  Created by Fabio Magarelli on 08/05/2020.
//  Copyright © 2020 Fabio Magarelli. All rights reserved.
//

import UIKit

class Documentation_ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    override func viewDidAppear(_ animated: Bool) {
        setPageControlHidden(hidden: true)
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
    
    @IBAction func click_button(_ sender: UIButton) {
        let url = URL(string: "https://physics.stackexchange.com/questions/510652/estimate-clothes-drying-time-evaporation")
        UIApplication.shared.open(url!)
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
