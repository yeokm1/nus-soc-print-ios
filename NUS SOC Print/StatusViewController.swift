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
    var statusOperation : GetStatusOperation?
    var deleteOperation : DeleteOperation?
    

    
    @IBOutlet weak var statusOutputView: UITextView!
    
    @IBAction func closeButtonPressed(sender: UIBarButtonItem) {
        statusOperation?.cancel()
        deleteOperation?.cancel()
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func refreshButtonPressed(sender: UIButton) {
        getStatus()
    }
    
    @IBAction func deleteJobsPressed(sender: UIButton) {
        startDeleting()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStatus()
    }
    
    func startDeleting(){
        
        if(deleteOperation != nil){
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
            
            deleteOperation = DeleteOperation(hostname: hostname, username: username!, password: password!, printersList: printerList, outputView:statusOutputView)
            
            deleteOperation!.completionBlock = {(void) in
                self.deleteOperation = nil
            }
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {(void) in
                self.deleteOperation!.start()
            })
            
            
        }
        
        
    }
    
    func getStatus(){
        
        if(statusOperation != nil){
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
            
            statusOperation = GetStatusOperation(hostname: hostname, username: username!, password: password!, printersList: printerList, outputView:statusOutputView)
        
            statusOperation!.completionBlock = {(void) in
                self.statusOperation = nil
            }

            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {(void) in
                self.statusOperation!.start()
            })
    
            
        }
        
        
    }
    
    class BaseOperation : NSOperation {
        var connection : SSHConnectivity!
        var username : String!
        var password : String!
        var hostname : String!
        var printersArray : Array<String>
        weak var outputView : UITextView!
        
        
        init(hostname : String, username : String, password : String, printersList : Array<String>, outputView : UITextView) {
            self.username = username
            self.password = password
            self.hostname = hostname
            self.outputView = outputView
            self.printersArray = printersList
            
        }
        
        
        func showOnOutputViewOnUIThread(output: String){
            dispatch_async(dispatch_get_main_queue(), {(void) in
                self.outputView!.text = output
            })
        }
        
    }
    
    class DeleteOperation : BaseOperation {
        let FORMAT_PRINTER_COMMAND = "lprm -P %@ -"
        let FORMAT_DELETION_OUTPUT = "Deletion command sent to %@\n"
        let DELETION_COMMAND_SENT_TO_ALL = "Delection command set to all printers"
        
        override func main() {
            connection = SSHConnectivity(hostname: hostname!, username: username!, password: password!)
            var connectionStatus = connection.connect()
            
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
                connection!.runCommand(command)
                
                var lineToShowToUI : String = String(format: FORMAT_DELETION_OUTPUT, printer)
                
                outputString += lineToShowToUI
                showOnOutputViewOnUIThread(outputString)
                
            }
            
            outputString += DELETION_COMMAND_SENT_TO_ALL
            showOnOutputViewOnUIThread(outputString)
            
            
            self.connection.disconnect()
            self.connection = nil
            
            
        }
        
        
    }
    
    
    
    class GetStatusOperation : BaseOperation {
    
        let FORMAT_PRINTER_COMMAND = "lpq -P %@"
        let FORMAT_PRINTER_OUTPUT = "%@ : %@\n"
        let FORMAT_PRINTER_NO_OUTPUT = "%@ : No Output\n"
        let TEXT_NO_JOB = "Print Queue Empty\n"
        
        
        override func main() {
            connection = SSHConnectivity(hostname: hostname!, username: username!, password: password!)
            var connectionStatus = connection.connect()
            
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
            
            
            
            
            self.connection.disconnect()
            self.connection = nil
            
            
        }
        

    
        
        
        
    }
    
}
