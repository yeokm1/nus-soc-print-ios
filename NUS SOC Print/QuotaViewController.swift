//
//  QuotaViewController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 12/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

class QuotaViewController: GAITrackedViewController, NSURLConnectionDataDelegate {
    
    let TAG = "QuotaViewController"
    let TEXT_REFRESHING = "Refreshing Quota..."
    let SERVER_URL = "https://mysoc.nus.edu.sg/images/LOGIN"
    let SERVER_PAIR = "destination=%@&credential_0=%@&credential_1=%@&AuthType=AuthDBICookieHandler&AuthName=mysoc"
    let SERVER_PATH = "/~eprint/forms/quota.php"
    let QUOTA_REGEX_PATTERN = "<tr><td bgcolor=.*?>(.*?)</td><td bgcolor=.*?>(.*?)</td></tr>"
    
    
    @IBOutlet weak var quotaOutput: UITextView!
    
    
    @IBAction func refreshButtonPress(sender: UIButton) {
        refreshQuota()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = TAG;
    }
    
    
    func refreshQuota(){
        let preferences : Storage = Storage.sharedInstance;
        
        
        let username : String?  = preferences.getUsername()
        let password : String? = preferences.getPassword()
        
        if(username == nil || username!.isEmpty || password == nil || password!.isEmpty){
            quotaOutput.text = CREDENTIALS_MISSING
        } else {
            quotaOutput.text = TEXT_REFRESHING
            retrieveQuota(username!, password: password!)
        }


    }
    
    
    func retrieveQuota(username : String, password: String) {

        NSLog("%@ %@", TAG, "Refreshing Quota")
        let post : String = String(format: SERVER_PAIR, SERVER_PATH, username, password)

        let postData : NSData? = post.dataUsingEncoding(NSASCIIStringEncoding);
        
        let postLength : String = String(format: "%d", postData!.length)
        
        let url : NSURL = NSURL(string:SERVER_URL)!

        let request : NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        
        _ = NSURLConnection(request: request, delegate: self, startImmediately: true)

    }
    

    func connection(connection: NSURLConnection, didReceiveData data: NSData) {

        let dataStringNS : NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        
        NSLog("%@ %@", TAG, dataStringNS)
        
  
        let regex : NSRegularExpression = try! NSRegularExpression(pattern:QUOTA_REGEX_PATTERN, options: NSRegularExpressionOptions.CaseInsensitive)
        
        let matches = regex.matchesInString(dataStringNS as String, options: NSMatchingOptions(), range: NSMakeRange(0, dataStringNS.length))
        
  
        quotaOutput.text = ""
        
        if(matches.count == 0){
            quotaOutput.text = CREDENTIALS_WRONG
        }
        
        for match in matches {
            
            let quotaTypeRange : NSRange = match.rangeAtIndex(1)
            let quotaValueRange : NSRange = match.rangeAtIndex(2)
            let quotaTypeHTML = dataStringNS.substringWithRange(quotaTypeRange)
            let quotaValueHTML = dataStringNS.substringWithRange(quotaValueRange)
            
            let quotaType : String = stringByStrippingHTML(quotaTypeHTML)
            let quotaValue : String = stringByStrippingHTML(quotaValueHTML)
            
        
            NSLog("%@ %@ %@", TAG, quotaType, quotaValue)
            
            
            let quotaString : String = quotaType + " : " + quotaValue + "\n\n"
        
            
            quotaOutput.text = quotaOutput.text.stringByAppendingString(quotaString)
            
        }
        
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        quotaOutput.text = SERVER_UNREACHABLE
    }
    

    func stringByStrippingHTML(input : String) -> String{
  
        let regex : NSRegularExpression = try! NSRegularExpression(pattern:"<[^>]+>", options: NSRegularExpressionOptions.CaseInsensitive)

        let output = regex.stringByReplacingMatchesInString(input, options: NSMatchingOptions(), range: NSMakeRange(0, input.utf16.count), withTemplate: "")
   

        return output
    
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
