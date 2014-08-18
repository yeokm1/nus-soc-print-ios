//
//  PrintingViewController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 17/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

class PrintingViewController : UIViewController, UITableViewDataSource {
    
    let CELL_IDENTIFIER = "PrintingViewTableCell"
    
    let PDF_CONVERTER_FILENAME = "nup_pdf.jar"
    let DOC_CONVERTER_FILENAME = "docs-to-pdf-converter-1.7.jar"
    
    let PDF_CONVERTER_MD5 = "C1F8FF3F9DE7B2D2A2B41FBC0085888B"
    let DOC_CONVERTER_MD5 = "1FC140AD8074E333F9082300F4EA38DC"
    
    let DIRECTORY_TO_USE = "socPrint"
    let TEMP_DIRECTORY_TO_USE = "socPrint2"
    
    
    let HEADER_TEXT : Array<String> =
    ["Connecting to server"
    ,"Some housekeeping"
    ,"Uploading DOC converter"
    ,"Uploading PDF Formatter"
    ,"Formatting PDF"
    ,"Converting to Postscript"
    ,"Sending to printer"]
    
    let CLOSE_TEXT = "Close"
    
    
    let PROGRESS_INDETERMINATE : Array<Bool> =
    [true
    ,true
    ,false
    ,false
    ,true
    ,true
    ,true]
    
    
    
    
    let TEXT_INDETERMINATE = "This could take awhile..."
    
    var printer : String!
    var pagesPerSheet : String!
    var filePath : NSURL!
    
    var currentProgress : Int = 0
    
    var operation : PrintingOperation?
    
    @IBOutlet weak var progressTable: UITableView!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    
    
    var uploadDocConverterRequired : Bool = true
    var uploadPDFConverterRequired : Bool = true
    var filename : String!
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        operation?.cancel()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressTable.dataSource = self
        
        
        if(pagesPerSheet == "1"){
            uploadPDFConverterRequired = false
        }
        
        filename = filePath.absoluteString.lastPathComponent
        
        var filenameNS : NSString = filename as NSString
        
        var fileType : String = filenameNS.substringFromIndex(filenameNS.length - 3)
        if("pdf".caseInsensitiveCompare(fileType) == NSComparisonResult.OrderedSame){
            uploadDocConverterRequired = false
        }
        
        
        
        startPrinting()
    }
    
    
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        var cell : PrintingViewTableCell? = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as? PrintingViewTableCell
    

        if (cell == nil) {
            cell = PrintingViewTableCell(style: UITableViewCellStyle.Default, reuseIdentifier: CELL_IDENTIFIER)
        }
        

        processCell(cell!, row: indexPath.row)
        
        return cell;
    }
    
    
    func processCell(cell : PrintingViewTableCell, row : Int){
        cell.header.text = HEADER_TEXT[row]
        cell.smallFooter.text = ""
        
        cell.progressBar.hidden = PROGRESS_INDETERMINATE[row]
        cell.activityIndicator.hidden = true

        //Adjust Tick
        if(row >= currentProgress){
            cell.tick.hidden = true
        } else {
            cell.tick.hidden = false
        }
        
        
        
    }
    
    
    func startPrinting(){
        
        if(operation != nil){
            return
        }
        
        var preferences : Storage = Storage.sharedInstance;
        
        
        var username : String?  = preferences.getUsername()
        var password : String? = preferences.getPassword()
        var hostname : String = preferences.getServer()

        
        if(username == nil || username!.isEmpty || password == nil || password!.isEmpty){
            showAlert(TITLE_STOP, FULL_CREDENTIALS_NOT_SET, self)
        } else {
            
            currentProgress = 0
            
            operation = PrintingOperation(hostname: hostname, username: username!, password: password!, pagesPerSheet : pagesPerSheet, printerName : printer, parent : self)
            
            operation!.completionBlock = {(void) in
                self.operation = nil
                self.cancelButton.setTitle(self.CLOSE_TEXT, forState: UIControlState.Normal)
            }
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {(void) in
                self.operation!.start()
            })
            
            
            
        }
        
        
    }
    
    
    class PrintingOperation : NSOperation {
        
        var connection : SSHConnectivity!
        var username : String!
        var password : String!
        var hostname : String!
        var pagesPerSheet : String!
        var printerName : String!
        var parent : PrintingViewController!
        
        
        init(hostname : String, username : String, password : String, pagesPerSheet : String, printerName : String, parent : PrintingViewController) {
            self.username = username
            self.password = password
            self.hostname = hostname
            self.pagesPerSheet = pagesPerSheet
            self.printerName = printerName
            self.parent = parent
            
        }
        
        override func main() {
            
            //Step 0: Connecting to server
            connection = SSHConnectivity(hostname: hostname!, username: username!, password: password!)
            var connectionStatus = connection.connect()
            
            var serverFound : Bool = connectionStatus.serverFound
            var authorised : Bool = connectionStatus.authorised
            
            if(serverFound){
                if(!authorised){
                    showAlert(TITLE_STOP, CREDENTIALS_WRONG, parent)
                    return
                }
            } else {
                showAlert(TITLE_STOP, SERVER_UNREACHABLE, parent)
                return
            }
            
            //Step 1: Housekeeping, creating socPrint folder if not yet, delete all files except converters
            
            parent.currentProgress++
            updateUI()
            
            connection.createDirectory(parent.DIRECTORY_TO_USE)
            connection.createDirectory(parent.TEMP_DIRECTORY_TO_USE)
            
            //move .jar files in main directory to temp directory
            connection.runCommand("mv " + parent.DIRECTORY_TO_USE + "/*.jar " + parent.TEMP_DIRECTORY_TO_USE)
            
            //Remove main directory
            connection.runCommand("rm -rf " + parent.DIRECTORY_TO_USE)
            
            //Rename temp directory to main directory
            connection.runCommand("mv " + parent.TEMP_DIRECTORY_TO_USE + " " + parent.DIRECTORY_TO_USE)
            

            //Step2
            parent.currentProgress++
            updateUI()
            
            
            
            
            self.connection.disconnect()
            self.connection = nil
            
            
        }
        
        
        
        func updateUI(){
            dispatch_async(dispatch_get_main_queue(), {(void) in
                self.parent.progressTable.reloadData()
            })
        }
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
}
