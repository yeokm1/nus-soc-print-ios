//
//  PrintViewController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 12/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

var incomingURL : NSURL?

class PrintViewController: UIViewController, UIActionSheetDelegate {
    
    let TAG = "PrintViewController"
    let PRINTER_LIST = ["psts", "psts-sx", "pstsb", "pstsb-sx", "pstsc", "pstsc-sx", "psc008", "psc008-sx", "psc011", "psc011-sx", "psc245", "psc245-sx"]
    
    let TEXT_SELECT_PRINTER = "Select Printer"
    let TEXT_CANCEL = "---Cancel---"
    
    let TEXT_INSUFFICIENT_DETAILS_TITLE = "Application not set up"
    let TEXT_INSUFFICIENT_DETAILS_TEXT = "Please configure your Unix username, password and/or server in Settings before printing"
    
    
    let TEXT_SELECTION_INCOMPLETE_TITLE = "Print options not chosen"
    let TEXT_SELECTION_INCOMPLOTE_MESSAGE = "Please select a printer and/or import a file to print"
    
    
    var selectedPrinter : Int = -1
    

    
    
    @IBOutlet weak var selectPrinter: UIButton!
    @IBOutlet weak var pdfShower: UIWebView!
    
    @IBOutlet weak var filenameLabel: UILabel!
    

    @IBAction func selectPrinterPressed(sender: UIButton) {
        
        //Cancel button is added separately due to a bug up to iOS 7.1.
        //http://stackoverflow.com/questions/5262428/uiactionsheet-buttonindex-values-faulty-when-using-more-than-6-custom-buttons
        
        var selectPrinterWindow : UIActionSheet = UIActionSheet(title: TEXT_SELECT_PRINTER, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        
        selectPrinterWindow.addButtonWithTitle(TEXT_CANCEL)
        
        for printer in PRINTER_LIST {
            selectPrinterWindow.addButtonWithTitle(printer)
        }
        
    
        selectPrinterWindow.showInView(self.view)
        
    }
    
    @IBAction func printButtonPress(sender: UIButton) {
        
        var credentials = getCredentialsAndShowWarning()
        
        var settingsOK = credentials.settingsOK
        var username : String? = credentials.username
        var password : String? = credentials.password
        var server : String? = credentials.server
        
        
        if(selectedPrinter < 0 || incomingURL == nil){
            showAlert(TEXT_SELECTION_INCOMPLETE_TITLE, TEXT_SELECTION_INCOMPLOTE_MESSAGE, self)
        }
        

        
    }
    
    @IBAction func checkStatusButtonPressed(sender: UIButton) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("%@ viewDidLoad", TAG);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePDFToWebview", name: UIApplicationDidBecomeActiveNotification, object: nil)
        

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getCredentialsAndShowWarning()
    }
    
    func getCredentialsAndShowWarning() -> (settingsOK : Bool, username : String?, password : String?, server : String){
        var preferences : Storage = Storage.sharedInstance;
        
        var username : String?  = preferences.getUsername()
        var password : String? = preferences.getPassword()
        var server : String = preferences.getServer()
        
        
        if username == nil || username!.isEmpty
            || password == nil || password!.isEmpty
            || server.isEmpty {
                showAlert(TEXT_INSUFFICIENT_DETAILS_TITLE, TEXT_INSUFFICIENT_DETAILS_TEXT, self)
             return (false, username, password, server)
                
        } else {
            return (true, username, password, server)

        }
        
        
    }
    

    func updatePDFToWebview(){
        
        var urlRequest : NSURLRequest = NSURLRequest(URL: incomingURL)
        
        //iOS8 beta 5 has this bug of not displaying the PDF and showing "failed to find PDF header: `%PDF' not found." in the log
        
        if(incomingURL != nil){
            pdfShower.loadRequest(urlRequest)
            var filename : String = incomingURL!.lastPathComponent
            
            filenameLabel.text = filename
            
            
        }
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        //As index 0 is reserved for the cancelButton
        var actualSelectedIndex = buttonIndex - 1
        
        if(actualSelectedIndex != -1){
            selectedPrinter = actualSelectedIndex
            selectPrinter.setTitle(PRINTER_LIST[actualSelectedIndex], forState: UIControlState.Normal)
        }
        
        NSLog("%@ Selected Printer %d", TAG, actualSelectedIndex);
    }
    
    func receiveDocumentURL(url : NSURL){
        NSLog("%@ incoming file %@", TAG, url);
        incomingURL = url
    }
    
    
}
