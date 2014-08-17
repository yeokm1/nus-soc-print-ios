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
    var operation : GetStatusOperation?
    
    
    @IBOutlet weak var statusOutputView: UITextView!
    
    @IBAction func closeButtonPressed(sender: UIBarButtonItem) {
        operation?.cancel()

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func refreshButtonPressed(sender: UIButton) {
        getStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStatus()
    }
    
    
    func getStatus(){
        
        if(operation != nil){
            return
        }
        
        var preferences : Storage = Storage.sharedInstance;
        
        
        var username : String?  = preferences.getUsername()
        var password : String? = preferences.getPassword()
        var hostname : String = preferences.getServer()
        var printerList : Array<String> = preferences.getPrinterList()
        
        if(username == nil || username!.isEmpty || password == nil || password!.isEmpty){
            statusOutputView.text = FULL_CREDENTIALS_NOT_SET
        } else {
            statusOutputView.text = TEXT_GETTING_STATUS
            
            operation = GetStatusOperation(hostname: hostname, username: username!, password: password!, printersList: printerList, outputView:statusOutputView)
        
            operation!.completionBlock = {(void) in
                self.operation = nil
            }

            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {(void) in
                self.operation!.start()
            })
    
            
        }
        
        
    }
    
    
    
    class GetStatusOperation : NSOperation {
    
        let FORMAT_PRINTER_COMMAND = "lpq -P %@"
        let FORMAT_PRINTER_OUTPUT = "%@ : %@\n"
        let FORMAT_PRINTER_NO_OUTPUT = "%@ : No Output\n"
        let TEXT_NO_JOB = "Print Queue Empty\n"
        
        var connection : SSHConnectivity?
        var username : String?
        var password : String?
        var hostname : String?
        var printersArray : Array<String>
        weak var outputView : UITextView?
        
        
        init(hostname : String, username : String, password : String, printersList : Array<String>, outputView : UITextView) {
            self.username = username
            self.password = password
            self.hostname = hostname
            self.outputView = outputView
            self.printersArray = printersList

        }
        
        override func main() {
            connection = SSHConnectivity(hostname: hostname!, username: username!, password: password!)
            var connectionStatus = connection!.connect()
            
            var serverFound : Bool = connectionStatus.serverFound
            var authorised : Bool = connectionStatus.authorised
            
            if(serverFound){
                if(!authorised){
                    showOnOutputViewOnUIThread(CREDENTIALS_WRONG)
                    return
                }
            } else {
                showOnOutputViewOnUIThread(SERVER_UNREACHABLE)
                return
            }
            
            var outputString : String = ""
            
            for printer in printersArray {
                
                if(cancelled) {
                    break
                }
                
                var command = String(format: FORMAT_PRINTER_COMMAND, printer)
                var commandOutput : String? = connection!.runCommand(command)
                
                var lineToShowToUI : String?
                
                if(commandOutput == nil){
                    lineToShowToUI = String(format: FORMAT_PRINTER_NO_OUTPUT, printer)
                } else {
                    
                    if(commandOutput == "no entries\n"){
                        lineToShowToUI = String(format: FORMAT_PRINTER_OUTPUT, printer, TEXT_NO_JOB)
                    } else {
                        lineToShowToUI = String(format: FORMAT_PRINTER_OUTPUT, printer, commandOutput!)
                    }
                }
                
                outputString += lineToShowToUI!
                showOnOutputViewOnUIThread(outputString)
                
            }
            
            
            
            
            self.connection?.disconnect()
            self.connection = nil
            
            
        }
        

        
        
        func showOnOutputViewOnUIThread(output: String){
            dispatch_async(dispatch_get_main_queue(), {(void) in
                self.outputView!.text = output
            })
        }
        
        
        
    }
    
}
