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
        
        //To enable scrolling if the scrollview content is larger than the physical scrollview size
        //http://stackoverflow.com/questions/20502860/scroll-view-not-functioning-ios-7
        scrollView.contentSize = CGSizeMake(288, 453);
    }
    
    
    
    
    @IBAction func videoButtonPress(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.youtube.com/watch?v=PRGcK7gzbnM")!)
    }

    @IBAction func emailMe(sender: UIButton) {
        
        let device = getDeviceSpec()
        let subject : String = "NUS%20SOC%20Print%20iOS"
        let myEmail : String = "yeokm1@gmail.com"
        let versionString : String = getVersionString()
        
        let urlString : String = String(format: "mailto:?to=%@&subject=%@(%@)(%@)(%@)", myEmail, subject, device.model, device.osVersion, versionString)
        
        let url : NSURL = NSURL(string: urlString)!
        
        UIApplication.sharedApplication().openURL(url)
       

        
    }
    
    
    func getDeviceSpec() -> (model : String, osVersion : String) {
        let platform = UIDevice.currentDevice().platform()
        let version = getSystemVersion()
        return (platform, version)
    }
    
    
}