//
//  Constants.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 13/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

let TITLE_STOP = "Cannot continue"
let CREDENTIALS_WRONG = "Username/Password incorrect"
let CREDENTIALS_MISSING = "Username/Password not set"
let FULL_CREDENTIALS_NOT_SET = "Username/Password/Server not set"
let SERVER_UNREACHABLE = "Server unreachable. Check your internet connection"

let DIALOG_OK = "OK"

let APP_DID_BECOME_ACTIVE = "appDidBecomeActive"

func showAlertInUIThread(title: String, message : String, viewController : UIViewController){
    dispatch_async(dispatch_get_main_queue(), {(void) in
        showAlert(title, message, viewController)
    })
}

func showAlert(title: String, message : String, viewController : UIViewController){
    
    if(isSystemAtLeastiOS8()){
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: DIALOG_OK, style: UIAlertActionStyle.Default, handler: nil))
        
        viewController.presentViewController(alert, animated: true, completion: nil)
    } else {
        
        var alertView : UIAlertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: DIALOG_OK)
        alertView.show()
        
    }
    
}

func getSystemVersion() -> String{
    var systemVersion = UIDevice.currentDevice().systemVersion
    return systemVersion
}

func getVersionString() -> String {
    var infoDict : NSDictionary = NSBundle.mainBundle().infoDictionary
    var majorVersion : String = infoDict.objectForKey("CFBundleShortVersionString") as String
    var minorVersion : String = infoDict.objectForKey("CFBundleVersion") as String
    
    var appString = String(format: "Ver:%@,%@", majorVersion, minorVersion)
    
    return appString
    
}


func isSystemAtLeastiOS8() -> Bool{
    var systemVersion = getSystemVersion() as NSString
    
    var systemVersionFloat = systemVersion.floatValue
    if(systemVersionFloat >= 8.0){
        return true
    } else {
        return false
    }
    
}