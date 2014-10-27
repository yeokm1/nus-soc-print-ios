//
//  HelpViewController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 12/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

class HelpViewController: GAITrackedViewController {
    
    
    
    let TAG = "HelpViewController"
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = TAG;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSizeMake(288, 453);

    }
    
    
    
    
    @IBAction func videoButtonPress(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.youtube.com/watch?v=PRGcK7gzbnM")!)
    }

    @IBAction func emailMe(sender: UIButton) {
        
        var device = getDeviceSpec()
        var subject : String = "NUS%20SOC%20Print%20iOS"
        var myEmail : String = "yeokm1@gmail.com"
        var versionString : String = getVersionString()
        
        var urlString : String = String(format: "mailto:?to=%@&subject=%@(%@)(%@)(%@)", myEmail, subject, device.model, device.osVersion, versionString)
        
        var url : NSURL = NSURL(string: urlString)!
        
        UIApplication.sharedApplication().openURL(url)
       

        
    }
    
    
    func getDeviceSpec() -> (model : String, osVersion : String) {
        var platform = UIDevice.currentDevice().platform()
        var version = getSystemVersion()
        return (platform, version)
    }
    
    
}