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
let DIALOG_YES = "Yes"
let DIALOG_NO = "No"

let APP_DID_BECOME_ACTIVE = "appDidBecomeActive"

func showAlertInUIThread(title: String, message : String, viewController : UIViewController){
    dispatch_async(dispatch_get_main_queue(), {(void) in
        showAlert(title, message: message, viewController: viewController)
    })
}

func showAlert(title: String, message : String, viewController : UIViewController){
    
    if #available(iOS 8.0, *) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: DIALOG_OK, style: UIAlertActionStyle.Default, handler: nil))
            
        viewController.presentViewController(alert, animated: true, completion: nil)
    } else {
        let alertView : UIAlertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: DIALOG_OK)
        alertView.show()
    }


    
}

func showYesNoAlert(title: String, message : String, viewController : HelperFunctionsYesNoAlertViewController, alertTag : Int){
    
    if #available(iOS 8.0, *) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        
        let yesBlock = {(action: UIAlertAction!) -> Void in
            viewController.receiveAlertViewResponse(alertTag, clickedButtonIndex: 1)
        }
        
        
        let noBlock = {(action: UIAlertAction!) -> Void in
            viewController.receiveAlertViewResponse(alertTag, clickedButtonIndex: 0)
        }
        
        
        alert.addAction(UIAlertAction(title: DIALOG_YES, style: UIAlertActionStyle.Default, handler: yesBlock))
        alert.addAction(UIAlertAction(title: DIALOG_NO, style: UIAlertActionStyle.Cancel, handler: noBlock))
        
        viewController.presentViewController(alert, animated: true, completion: nil)
    } else {
        let alertView : UIAlertView = UIAlertView(title: title, message: message, delegate: viewController, cancelButtonTitle: DIALOG_NO, otherButtonTitles: DIALOG_YES)
        alertView.tag = alertTag
        alertView.show()
        
    }

}


func getSystemVersion() -> String{
    let systemVersion = UIDevice.currentDevice().systemVersion
    return systemVersion
}

func getVersionString() -> String {
    let infoDict : NSDictionary = NSBundle.mainBundle().infoDictionary!
    let majorVersion : String = infoDict.objectForKey("CFBundleShortVersionString") as! String
    let minorVersion : String = infoDict.objectForKey("CFBundleVersion") as! String
    
    let appString = String(format: "Ver:%@,%@", majorVersion, minorVersion)
    
    return appString
    
}
