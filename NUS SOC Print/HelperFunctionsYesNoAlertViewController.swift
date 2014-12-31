//
//  HelperFunctionsYesNoAlertViewController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 31/12/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation

class HelperFunctionsYesNoAlertViewController : GAITrackedViewController, UIAlertViewDelegate {
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        receiveAlertViewResponse(alertView.tag, clickedButtonIndex: buttonIndex)
    }
    
    
    //Override this, 0 for yes, 1 for no
    func receiveAlertViewResponse(alertTag : Int, clickedButtonIndex : Int){
        
    }
    
}