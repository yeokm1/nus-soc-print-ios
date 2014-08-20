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

    
    let TEXT_SELECT_PRINTER = "Select Printer"
    let TEXT_CANCEL = "---Cancel---"
    
    let TEXT_INSUFFICIENT_DETAILS_TITLE = "Application not set up"
    let TEXT_INSUFFICIENT_DETAILS_TEXT = "Please configure your Unix username, password and/or server in Settings before printing"
    
    
    let TEXT_SELECTION_INCOMPLETE_TITLE = "Print options not chosen"
    let TEXT_SELECTION_INCOMPLOTE_MESSAGE = "Please select a printer and/or import a file to print"
    
    
    var selectedPrinter : String!
    
    private var latestPrinterList : Array<String>! = nil
    
    
    @IBOutlet weak var selectPrinter: UIButton!
    @IBOutlet weak var pdfShower: UIWebView!
    @IBOutlet weak var pagesPerSheetSelection: UISegmentedControl!
    
    @IBOutlet weak var filenameLabel: UILabel!
    

    @IBAction func selectPrinterPressed(sender: UIButton) {
        
        var storage : Storage = Storage.sharedInstance
        
        latestPrinterList = storage.getPrinterList()
        
        //Cancel button is added separately due to a bug up to iOS 7.1.
        // http://stackoverflow.com/a/6193431
        
        var selectPrinterWindow : UIActionSheet = UIActionSheet(title: TEXT_SELECT_PRINTER, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        
        selectPrinterWindow.addButtonWithTitle(TEXT_CANCEL)
        
        for printer in latestPrinterList! {
            selectPrinterWindow.addButtonWithTitle(printer)
        }
        
    
        selectPrinterWindow.showInView(self.view)
        
    }

    
    @IBAction func checkStatusButtonPressed(sender: UIButton) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("%@ viewDidLoad", TAG);
        setSelfToDelegate(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getCredentialsAndShowWarning()
        updatePDFToWebview()
    }
    
    override func viewDidDisappear(animated: Bool) {
        setSelfToDelegate(nil)
        super.viewDidDisappear(animated)
    }
    
    func setSelfToDelegate(myself : PrintViewController?){
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.printViewController = myself
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
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject!) -> Bool {
        if(identifier != nil && identifier! == "startingPrinting"){
            
            var credentials = getCredentialsAndShowWarning()
            
            var settingsOK = credentials.settingsOK
            var username : String? = credentials.username
            var password : String? = credentials.password
            var server : String? = credentials.server
            
            if(!settingsOK){
                return false
            }
            
            
            if(selectedPrinter == nil || incomingURL == nil){
                showAlert(TEXT_SELECTION_INCOMPLETE_TITLE, TEXT_SELECTION_INCOMPLOTE_MESSAGE, self)
                return false
            } else {
                return true
            }
            
        } else {
            return true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {

        
        var controller : UIViewController = segue.destinationViewController as UIViewController
        
        if(controller.isKindOfClass(PrintingViewController)){
            NSLog("%@ prepareforSegue, going to printing view", TAG)
            var printingController : PrintingViewController = controller as PrintingViewController
            
            var printer : String? = selectedPrinter
            var pagesPerSheet : String = pagesPerSheetSelection.titleForSegmentAtIndex(pagesPerSheetSelection.selectedSegmentIndex)
        
            printingController.printer = selectedPrinter
            printingController.pagesPerSheet = pagesPerSheet
            printingController.filePath = incomingURL
        }
    }
    
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        //As index 0 is reserved for the cancelButton
        var actualSelectedIndex = buttonIndex - 1
        
        if(actualSelectedIndex != -1){
            selectedPrinter = latestPrinterList![actualSelectedIndex]
            selectPrinter.setTitle(selectedPrinter, forState: UIControlState.Normal)
        }
        
        NSLog("%@ Selected Printer %d", TAG, actualSelectedIndex);
    }
    
    func receiveDocumentURL(url : NSURL){
        NSLog("%@ incoming file %@", TAG, url);
        incomingURL = url
    }
    
    
}
