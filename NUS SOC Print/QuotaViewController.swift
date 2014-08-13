//
//  QuotaViewController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 12/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

class QuotaViewController: UIViewController, NSURLConnectionDataDelegate {
    
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
        } else {
            retrieveQuota(username!, password: password!)
        }


    }
    
    
    func retrieveQuota(username : String, password: String) {

            
        var post : String = String(format: "destination=%@&credential_0=%@&credential_1=%@&AuthType=AuthDBICookieHandler&AuthName=mysoc", "/~eprint/forms/quota.php", username, password)

        var postData : NSData? = post.dataUsingEncoding(NSASCIIStringEncoding);
        
        var postLength : String = String(format: "%d", postData!.length)
        
        var url : NSURL = NSURL.URLWithString("https://mysoc.nus.edu.sg/images/LOGIN")

        var request : NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        
        NSURLConnection(request: request, delegate: self, startImmediately: true)

    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {

        
    }
    
    
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        quotaOutput.text = SERVER_UNREACHABLE
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
