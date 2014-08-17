//
//  StatusViewController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 17/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

class StatusViewController : UIViewController {
    
    let TEXT_GETTING_STATUS = "Retrieving Status"
    var connection : SSHConnectivity?
    
    @IBOutlet weak var statusOutputView: UITextView!
    
    @IBAction func closeButtonPressed(sender: UIBarButtonItem) {
        connection?.disconnect()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func refreshButtonPressed(sender: UIButton) {
        getStatus()
    }
    
    
    func getStatus(){
        var preferences : Storage = Storage.sharedInstance;
        
        
        var username : String?  = preferences.getUsername()
        var password : String? = preferences.getPassword()
        var hostname : String = preferences.getServer()
        
        if(username == nil || username!.isEmpty || password == nil || password!.isEmpty){
            statusOutputView.text = FULL_CREDENTIALS_NOT_SET
        } else {
            statusOutputView.text = TEXT_GETTING_STATUS
            
            connection = SSHConnectivity(hostname: hostname, username: username!, password: password!)
            var connectionStatus = connection!.connect()
            
            var serverFound : Bool = connectionStatus.serverFound
            var authorised : Bool = connectionStatus.authorised
            
            
            if(serverFound){
                if(!authorised){
                   statusOutputView.text = CREDENTIALS_WRONG
                }
            } else {
                statusOutputView.text = SERVER_UNREACHABLE
            }
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
