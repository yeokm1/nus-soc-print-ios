//
//  HelpViewController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 12/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

class HelpViewController: UIViewController {
    
    @IBAction func videoButtonPress(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.youtube.com/watch?v=PRGcK7gzbnM"))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}