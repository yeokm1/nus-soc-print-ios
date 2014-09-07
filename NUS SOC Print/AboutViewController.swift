//
//  AboutViewController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 5/9/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation

class AboutViewController: GAITrackedViewController {
    
    let TAG = "AboutViewController"
    
    @IBOutlet weak var placeToPutVersion: UILabel!
    
    @IBAction func closeButtonPress(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = TAG;
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var versionString = getVersionString()
        
        placeToPutVersion.text = "NUS SOC Print " + versionString
    }
    
    
    @IBAction func sourceCodeButtonPress(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://github.com/yeokm1/nus-soc-print-ios"))
    }
    
}