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

class PrintViewController: GAITrackedViewController, UIActionSheetDelegate, UITextFieldDelegate {
    
    let TAG = "PrintViewController"

    
    let TEXT_SELECT_PRINTER = "Select Printer"
    let TEXT_CANCEL = "---Cancel---"
    
    let TEXT_INSUFFICIENT_DETAILS_TITLE = "Application not set up"
    let TEXT_INSUFFICIENT_DETAILS_TEXT = "Please configure your Unix username, password and/or server in Settings before printing"
    
    
    let TEXT_SELECTION_NO_PRINTER_TITLE = "Printer not selected"
    let TEXT_SELECTION_NO_PRINTER_MESSAGE = "Please choose a printer before continuing"
    
    let TEXT_SELECTION_NO_FILE_TITLE = "No file"
    let TEXT_SELECTION_NO_FILE_MESSAGE = "No file imported. Please import a file before printing"
    
    let TEXT_SELECTION_INVALID_PAGE_RANGE_TITLE = "Invalid page range"
    let TEXT_SELECTION_INVALID_PAGE_RANGE_MESSAGE = "Choose a valid page range before printing"
    
    
    var selectedPrinter : String!
    
    private var latestPrinterList : Array<String>! = nil
    
    
    @IBOutlet weak var selectPrinter: UIButton!
    @IBOutlet weak var pdfShower: UIWebView!
    @IBOutlet weak var pagesPerSheetSelection: UISegmentedControl!
    
    @IBOutlet weak var startPageField: UITextField!
    @IBOutlet weak var endPageField: UITextField!

    @IBOutlet weak var filenameView: UITextView!
    

    @IBOutlet weak var pageRangeChoice: UISegmentedControl!
    @IBOutlet weak var pageRangeViews: UIView!

    @IBAction func selectPrinterPressed(sender: UIButton) {
        
        let storage : Storage = Storage.sharedInstance
        
        latestPrinterList = storage.getPrinterList()
        
        //Cancel button is added separately due to a bug up to iOS 7.1.
        // http://stackoverflow.com/a/6193431
        
        let selectPrinterWindow : UIActionSheet = UIActionSheet(title: TEXT_SELECT_PRINTER, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        
        selectPrinterWindow.addButtonWithTitle(TEXT_CANCEL)
        
        for printer in latestPrinterList! {
            selectPrinterWindow.addButtonWithTitle(printer)
        }
        
    
        selectPrinterWindow.showInView(self.view)
        
    }
    
    @IBAction func pageRangeSelectionChanged(sender: UISegmentedControl) {
        updatePageRangeUI()
    }
    
    func updatePageRangeUI(){
        if(pageRangeChoice.selectedSegmentIndex == 0){
            
            let disabledColour = UIColor(white: 0.9, alpha: 1)
            startPageField.userInteractionEnabled = false
            endPageField.userInteractionEnabled = false
            
            startPageField.backgroundColor = disabledColour
            endPageField.backgroundColor = disabledColour
        } else {
            
            startPageField.userInteractionEnabled = true
            endPageField.userInteractionEnabled = true
            
            startPageField.backgroundColor = UIColor.whiteColor()
            endPageField.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let myCharSet = NSCharacterSet(charactersInString: "0123456789")
        let inString : NSString = string as NSString

        for (var i = 0; i < inString.length; i++) {
            let c : unichar = inString.characterAtIndex(i)
            
            if(!myCharSet.characterIsMember(c)){
                return false;
            }
        }
        
        return true;
    }
    
    //To close number pad keyboard if user tap outside
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        startPageField.resignFirstResponder()
        endPageField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("%@ viewDidLoad", TAG);
        setSelfToDelegate(self)
        updatePageRangeUI()
        
        startPageField.delegate = self
        endPageField.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSLog("%@ viewdidAppear", TAG)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateDocumentToWebview"), name: APP_DID_BECOME_ACTIVE, object: nil)
        getCredentialsAndShowWarning()
        updateDocumentToWebview()
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSLog("%@ viewdidDisappear", TAG)
        setSelfToDelegate(nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: APP_DID_BECOME_ACTIVE, object: nil)
        super.viewDidDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("%@ viewWillAppear", TAG)
         self.screenName = TAG;
    }
    
    func setSelfToDelegate(myself : PrintViewController?){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.printViewController = myself
    }
    
    
    func getCredentialsAndShowWarning() -> (settingsOK : Bool, username : String?, password : String?, server : String){
        let preferences : Storage = Storage.sharedInstance;
        
        let username : String?  = preferences.getUsername()
        let password : String? = preferences.getPassword()
        let server : String = preferences.getServer()
        
        
        if username == nil || username!.isEmpty
            || password == nil || password!.isEmpty
            || server.isEmpty {
                showAlert(TEXT_INSUFFICIENT_DETAILS_TITLE, message: TEXT_INSUFFICIENT_DETAILS_TEXT, viewController: self)
             return (false, username, password, server)
                
        } else {
            return (true, username, password, server)

        }
        
        
    }
    

    func updateDocumentToWebview(){
    
        //iOS8 beta 6 still has this bug of not displaying the PDF and showing "failed to find PDF header: `%PDF' not found." in the log
        
        if(incomingURL != nil){
            let urlRequest : NSURLRequest = NSURLRequest(URL: incomingURL!)
            pdfShower?.loadRequest(urlRequest)
            let filename : String = incomingURL!.lastPathComponent!
            
            filenameView?.text = filename
            
            
        }
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        if(identifier == "startingPrinting"){
            
            let credentials = getCredentialsAndShowWarning()
            
            let settingsOK = credentials.settingsOK
            
            if(!settingsOK){
                return false
            }
            
            
            var isUsingPageRange : Bool
            
            if(pageRangeChoice.selectedSegmentIndex == 0){
                isUsingPageRange = false
            } else {
                isUsingPageRange = true
            }
            
            let startRange : String? = startPageField.text
            let endRange : String? = endPageField.text
            
            
        
            if(selectedPrinter == nil){
                showAlert(TEXT_SELECTION_NO_PRINTER_TITLE, message: TEXT_SELECTION_NO_PRINTER_MESSAGE, viewController: self)
                return false
            } else if(incomingURL == nil){
                showAlert(TEXT_SELECTION_NO_FILE_TITLE, message: TEXT_SELECTION_NO_FILE_MESSAGE, viewController: self)
                return false
            } else if(isUsingPageRange){
                
                if(startRange == nil || endRange == nil){
                    showAlert(TEXT_SELECTION_INVALID_PAGE_RANGE_TITLE, message: TEXT_SELECTION_INVALID_PAGE_RANGE_MESSAGE, viewController: self)
                    return false
                }
                
                let startNumber = Int(startRange!)
                let endNumber = Int(endRange!)
                
                
                if(startNumber == nil || endNumber == nil
                    || startNumber == 0 || endNumber == 0
                    || startNumber > endNumber){
                        
                    showAlert(TEXT_SELECTION_INVALID_PAGE_RANGE_TITLE, message: TEXT_SELECTION_INVALID_PAGE_RANGE_MESSAGE, viewController: self)
                    return false
                } else {
                    return true
                }
                
            } else {
                return true
            }
            

            
        } else {
            return true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {

        
        let controller : UIViewController = segue.destinationViewController 
        
        if(controller.isKindOfClass(PrintingViewController)){
            NSLog("%@ prepareforSegue, going to printing view", TAG)
            let printingController : PrintingViewController = controller as! PrintingViewController
            
            
            let pagesPerSheet : String = pagesPerSheetSelection.titleForSegmentAtIndex(pagesPerSheetSelection.selectedSegmentIndex)!
        
            printingController.printer = selectedPrinter
            printingController.pagesPerSheet = pagesPerSheet
            printingController.filePath = incomingURL
            
            if(pageRangeChoice.selectedSegmentIndex != 0){
                let startRange : String = startPageField.text!
                let endRange : String = endPageField.text!
                let startNumber = Int(startRange)
                let endNumber = Int(endRange)
                
                printingController.startPageRange = startNumber!
                printingController.endPageRange = endNumber!
                
                
            }
            

            
            
            
            
        }
    }
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        //As index 0 is reserved for the cancelButton
        let actualSelectedIndex = buttonIndex - 1
        
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
