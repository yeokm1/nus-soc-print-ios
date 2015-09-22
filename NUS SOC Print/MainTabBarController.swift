//
//  MainTabBarController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 17/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController : UITabBarController {
    
    var TAG = "MainTabBarController"
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("%@ viewdidload", TAG)
        
        if #available(iOS 8.0, *) {
            
            //So this controller will not turn black when the pop up comes in. See here http://stackoverflow.com/a/16230701
            self.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("%@ viewdidAppear", TAG)
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSLog("%@ viewdidDisappear", TAG)
    }
    
    
}