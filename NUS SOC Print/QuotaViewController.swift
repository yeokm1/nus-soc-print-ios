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
    
    
    func refreshQuota(){
        var preferences : Storage = Storage.sharedInstance;
        
        
        var username : String?  = preferences.getUsername()
        var password : String? = preferences.getPassword()
        
        if(username == nil || username!.isEmpty || password == nil || password!.isEmpty){
            quotaOutput.text = CREDENTIALS_MISSING
        } else {
            quotaOutput.text = TEXT_REFRESHING
            retrieveQuota(username!, password: password!)
        }


    }
    
    
    func retrieveQuota(username : String, password: String) {

        NSLog("%@ %@", TAG, "Refreshing Quota")
        var post : String = String(format: SERVER_PAIR, SERVER_PATH, username, password)

        var postData : NSData? = post.dataUsingEncoding(NSASCIIStringEncoding);
        
        var postLength : String = String(format: "%d", postData!.length)
        
        var url : NSURL = NSURL.URLWithString(SERVER_URL)

        var request : NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        
        NSURLConnection(request: request, delegate: self, startImmediately: true)

    }
    

    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {

        var dataStringNS : NSString = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        NSLog("%@ %@", TAG, dataStringNS)
        
  
        var regex : NSRegularExpression = NSRegularExpression.regularExpressionWithPattern(QUOTA_REGEX_PATTERN, options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!
        
        var matches : NSArray = dataStringNS.matchesWithDetails(regex)

  
        quotaOutput.text = ""
        
        if(matches.count == 0){
            quotaOutput.text = CREDENTIALS_WRONG
        }
        
        for match in matches {
            
            var groups : NSArray = match.groups
            
            var quotaTypeGroup : RxMatchGroup = groups.objectAtIndex(1) as RxMatchGroup
            var quotaValueGroup : RxMatchGroup = groups.objectAtIndex(2) as RxMatchGroup
            

            var quotaType : String = stringByStrippingHTML(quotaTypeGroup.value)
            var quotaValue : String = stringByStrippingHTML(quotaValueGroup.value)
            
        
            NSLog("%@ %@ %@", TAG, quotaType, quotaValue)
            
            
            var quotaString : String = quotaType + " : " + quotaValue + "\n\n"
        
            
            quotaOutput.text = quotaOutput.text.stringByAppendingString(quotaString)
            

        }
        
    
        
        
    }
    
    
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        quotaOutput.text = SERVER_UNREACHABLE
    }
    

    func stringByStrippingHTML(input : String) -> String{
  
        var regex : NSRegularExpression = NSRegularExpression.regularExpressionWithPattern("<[^>]+>", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!
   
        var output = regex.replace(input, with: "")
        
        return output
    
    }
    
    func RangeMake(start:Int, end:Int) -> Range<String.Index> {
        assert(start <= end, "start must be less than or equal to end")
        func rep(str: String, count: Int) -> String {
            var result = ""
            for i in 0 ... count {
                result += str
            }
            return result
        }
        let length = end - start
        let padding = rep(" ", start)
        let dashes = rep("-", length)
        let search = padding + dashes
        return search.rangeOfString(dashes, options: nil, range: Range(start: search.startIndex, end: search.endIndex), locale: NSLocale.systemLocale())!
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
