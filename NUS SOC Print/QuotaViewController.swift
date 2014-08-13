//
//  QuotaViewController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 12/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

class QuotaViewController: UIViewController {
    
    @IBOutlet weak var quotaOutput: UITextView!
    
    
    @IBAction func refreshButtonPress(sender: UIButton) {
        refreshQuota()
    }
    
    
    func refreshQuota(){
        var preferences : Storage = Storage.sharedInstance;
        
        
        var username : String?  = preferences.getUsername()
        var password : String? = preferences.getPassword()
        
        if(username == nil || username!.isEmpty || password == nil || password!.isEmpty){
            quotaOutput.text = CREDENTIALS_MISSING
        }


    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshQuota()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
