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
    let FORMAT_PRINTER_COMMAND = "lpq -P %@"
    let FORMAT_PRINTER_OUTPUT = "%@ : %@\n"
    let FORMAT_PRINTER_NO_OUTPUT = "%@ : No Output\n"
    
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
        
        if(connection != nil){
            return
        }
        
        var preferences : Storage = Storage.sharedInstance;
        
        
        var username : String?  = preferences.getUsername()
        var password : String? = preferences.getPassword()
        var hostname : String = preferences.getServer()
        
        if(username == nil || username!.isEmpty || password == nil || password!.isEmpty){
            statusOutputView.text = FULL_CREDENTIALS_NOT_SET
        } else {
            statusOutputView.text = TEXT_GETTING_STATUS
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {(void) in

                
                self.connection = SSHConnectivity(hostname: hostname, username: username!, password: password!)
                var connectionStatus = self.connection!.connect()
                
                var serverFound : Bool = connectionStatus.serverFound
                var authorised : Bool = connectionStatus.authorised
                
                if(serverFound){
                    if(!authorised){
                        self.showOnOutputViewOnUIThread(CREDENTIALS_WRONG)
                        return
                    }
                } else {
                    self.showOnOutputViewOnUIThread(SERVER_UNREACHABLE)
                    return
                }
                
                
                var printersArray : Array<String> = preferences.getPrinterList()
                var outputString : String = ""
                
                for printer in printersArray {
                    
                    var command = String(format: self.FORMAT_PRINTER_COMMAND, printer)
                    var commandOutput : String? = self.connection!.runCommand(command)
                    
                    var lineToShowToUI : String?
                    
                    if(commandOutput == nil){
                        lineToShowToUI = String(format: self.FORMAT_PRINTER_NO_OUTPUT, printer)
                    } else {
                        lineToShowToUI = String(format: self.FORMAT_PRINTER_OUTPUT, printer, commandOutput!)
                    }
                    
                    outputString += lineToShowToUI!
                    self.showOnOutputViewOnUIThread(outputString)
                    
                }
                
                

                
                self.connection?.disconnect()
                self.connection = nil
                
                
                
            });
            
        }
        
        
    }
    
    
    func showOnOutputViewOnUIThread(output: String){
        dispatch_async(dispatch_get_main_queue(), {(void) in
            self.statusOutputView.text = output
        });
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
