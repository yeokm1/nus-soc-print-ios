//
//  PrintingViewController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 17/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

class PrintingViewController : GAITrackedViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {
    
    let TAG = "PrintingViewController"
    
    let CELL_IDENTIFIER = "PrintingViewTableCell"
    let CELL_ROW_ZERO_HEIGHT : CGFloat = 0
    let CELL_ROW_HEIGHT : CGFloat = 52
    let FORMAT_UPLOADING = "%@ of %@ (%.1f%%)"
    
    let DIALOG_YES = "Yes"
    let DIALOG_NO = "No"
    let DIALOG_TITLE = "Are you sure you want to cancel this print operation?"
    
    
    
    let HEADER_TEXT : Array<String> =
    ["Connecting to server"
    ,"Some housekeeping"
    ,"Uploading DOC converter"
    ,"Uploading PDF Formatter"
    ,"Uploading %@"
    ,"Converting to PDF"
    ,"Formatting to %@ pages"
    ,"Converting to Postscript"
    ,"Sending to %@"]
    
    let POSITION_CONNECTING = 0
    let POSITION_HOUSEKEEPING = 1
    let POSITION_UPLOADING_DOC_CONVERTER = 2
    let POSITION_UPLOADING_PDF_CONVERTER = 3
    let POSITION_UPLOADING_USER_DOC = 4
    let POSITION_CONVERTING_TO_PDF = 5
    let POSITION_FORMATTING_PDF = 6
    let POSITION_CONVERTING_TO_POSTSCRIPT = 7
    let POSITION_SENDING_TO_PRINTER = 8
    let POSITION_COMPLETED = 9
    
    let CLOSE_TEXT = "Close"
    
    
    let PROGRESS_INDETERMINATE : Array<Bool> =
    [true
    ,true
    ,false
    ,false
    ,false
    ,true
    ,true
    ,true
    ,true]
    
    
    
    
    let TEXT_INDETERMINATE = "This could take awhile..."
    
    var printer : String!
    var pagesPerSheet : String!
    var filePath : NSURL!
    var filePathString : String!
    
    var currentProgress : Int = 0
    
    var operation : PrintingOperation?
    
    @IBOutlet weak var progressTable: UITableView!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    
    
    var docConvSize : Int = 0
    var docConvUploaded : Int = 0
    
    var pdfConvSize : Int = 0
    var pdfConvUploaded : Int = 0
    
    var docToPrintSize : Int = 0
    var docToPrintUploaded : Int = 0
    
    
    
    var uploadDocConverterRequired : Bool = true
    var uploadPDFConverterRequired : Bool = true
    var filename : String!
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        if(operation == nil){
            cancelAndClose()
        } else {
            showOkCancelAlert(DIALOG_TITLE, message: "", viewController: self)
        }
        
        

    }
    
    func cancelAndClose(){
        operation?.cancel()
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if(pagesPerSheet == "1"){
            uploadPDFConverterRequired = false
        }
        
        filename = filePath.lastPathComponent
        filePathString = filePath.path
        
        if(isFileAPdf(filename)){
            uploadDocConverterRequired = false
        }
        
        progressTable.delegate = self
        progressTable.dataSource = self


        startPrinting()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = TAG;
    }
    
    
    func isFileAPdf(filename : String) -> Bool{
        var filenameNS : NSString = filename as NSString
        
        var fileType : String = filenameNS.pathExtension
        
        
        if fileType.rangeOfString("pdf") == nil {
            return false
        } else {
            return true
        }
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        var row : Int = indexPath.row

        if(row == POSITION_UPLOADING_DOC_CONVERTER && !uploadDocConverterRequired
            || row == POSITION_CONVERTING_TO_PDF && !uploadDocConverterRequired
            || row == POSITION_UPLOADING_PDF_CONVERTER && !uploadPDFConverterRequired
            || row == POSITION_FORMATTING_PDF && !uploadPDFConverterRequired){
            return CELL_ROW_ZERO_HEIGHT
        }  else {
            return CELL_ROW_HEIGHT
        }
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return HEADER_TEXT.count
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
        
        cell.clipsToBounds = true
        
        if(row == POSITION_UPLOADING_USER_DOC){
            cell.header.text = String(format:HEADER_TEXT[row], filename)
        } else if(row == POSITION_FORMATTING_PDF){
            cell.header.text = String(format:HEADER_TEXT[row], pagesPerSheet)
        } else if(row == POSITION_SENDING_TO_PRINTER){
            cell.header.text = String(format:HEADER_TEXT[row], printer)
        } else {
            cell.header.text = HEADER_TEXT[row]
        }
        
        
        cell.progressBar.hidden = PROGRESS_INDETERMINATE[row]


        //Adjust Tick
        if(currentProgress > row){
            cell.tick.hidden = false
        } else {
            cell.tick.hidden = true
        }
        
        
        if(row == currentProgress){
            if(operation == nil){
                //Means the operation has ended on the current progress, show a cross to mean an error
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator.hidden = true
                cell.cross.hidden = false
            } else if(!cell.activityIndicator.isAnimating()){
                cell.activityIndicator.hidden = false
                cell.activityIndicator.startAnimating()
            }
        } else {
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.hidden = true
        }
        
        if(row == POSITION_UPLOADING_DOC_CONVERTER){
            
            var progress = generateProgressStringAndProgressFraction(docConvUploaded, totalSize: docConvSize)
  
            cell.smallFooter.text = progress.progressString
            cell.progressBar.progress = progress.progressFraction
            
        }
        
        
        if(row == POSITION_UPLOADING_PDF_CONVERTER){
            
            var progress = generateProgressStringAndProgressFraction(pdfConvUploaded, totalSize: pdfConvSize)
            
            cell.smallFooter.text = progress.progressString
            cell.progressBar.progress = progress.progressFraction
            
        }
        
        
        if(row == POSITION_UPLOADING_USER_DOC){
            var progress = generateProgressStringAndProgressFraction(docToPrintUploaded, totalSize: docToPrintSize)
            
            cell.smallFooter.text = progress.progressString
            cell.progressBar.progress = progress.progressFraction
        }
        
        if(row == POSITION_CONVERTING_TO_PDF || row == POSITION_CONVERTING_TO_POSTSCRIPT){
            cell.smallFooter.text = TEXT_INDETERMINATE
        }

        
        
        
    }
    
    
    
    func generateProgressStringAndProgressFraction(currentSize : Int, totalSize : Int) -> (progressString : String, progressFraction : Float){
        var doubleCurrent = Double(currentSize)
        var doubleTotal = Double(totalSize)
        
        var progressFraction : Float = 0
        
        if(totalSize != 0){
            progressFraction = Float(doubleCurrent / doubleTotal)
        }
        
        var percent = progressFraction * 100
        
        var byteCountFormatter = NSByteCountFormatter()
        byteCountFormatter.zeroPadsFractionDigits = true
        byteCountFormatter.countStyle = NSByteCountFormatterCountStyle.File
        

        var uploadedStr = byteCountFormatter.stringFromByteCount(Int64(currentSize))
        
        var totalStr = byteCountFormatter.stringFromByteCount(Int64(totalSize))

        var formatString = String(format: FORMAT_UPLOADING, uploadedStr, totalStr, percent)
        
        return (formatString, progressFraction)
        
        
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
            
            operation = PrintingOperation(hostname: hostname, username: username!, password: password!, filePath : filePathString, pagesPerSheet : pagesPerSheet, printerName : printer, parent : self)
            
            operation!.completionBlock = {(void) in
                self.operation = nil
                
                dispatch_async(dispatch_get_main_queue(), {(void) in
                    self.cancelButton.setTitle(self.CLOSE_TEXT, forState: UIControlState.Normal)
                })

            }
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {(void) in
                self.operation!.start()
            })
            
            
            
        }
        
        
    }
    
    
    func showOkCancelAlert(title: String, message : String, viewController : UIViewController){
        
        if(isSystemAtLeastiOS8()){
            var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelBlock = {(action: UIAlertAction!) -> Void in
                self.cancelCurrentOperation()
            }
            
            alert.addAction(UIAlertAction(title: DIALOG_YES, style: UIAlertActionStyle.Default, handler: cancelBlock))
            alert.addAction(UIAlertAction(title: DIALOG_NO, style: UIAlertActionStyle.Default, handler: nil))
            
            viewController.presentViewController(alert, animated: true, completion: nil)
        } else {
            
            var alertView : UIAlertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: DIALOG_NO, otherButtonTitles: DIALOG_YES)
                alertView.show()
            
        }
        
    }
    
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        NSLog("%@ alertview clicked %d", TAG, buttonIndex)
        if(buttonIndex == 1){
            cancelCurrentOperation()
        }
    }
    
    func cancelCurrentOperation(){
        NSLog("%@ Cancel current operation", TAG)
        cancelAndClose()
    }
    
    
    class PrintingOperation : NSOperation {
        
        
        let PDF_CONVERTER_NAME = "nup_pdf"
        let PDF_CONVERTER_FILENAME = "nup_pdf.jar"
        let PDF_CONVERTER_FILEPATH = "socPrint/nup_pdf.jar"
        
        //This converter is for 6 pages/sheet as nup_pdf cannot generate such a file
        let PDF_CONVERTER_6PAGE_NAME = "Multivalent"
        let PDF_CONVERTER_6PAGE_FILENAME = "Multivalent.jar"
        let PDF_CONVERTER_6PAGE_FILEPATH = "socPrint/Multivalent.jar"
        
        let DOC_CONVERTER_NAME = "docs-to-pdf-converter-1.7"
        let DOC_CONVERTER_FILENAME = "docs-to-pdf-converter-1.7.jar"
        let DOC_CONVERTER_FILEPATH = "socPrint/docs-to-pdf-converter-1.7.jar"
        
        let PDF_CONVERTER_MD5 = "C1F8FF3F9DE7B2D2A2B41FBC0085888B"
        let PDF_CONVERTER_6PAGE_MD5 = "813BB651A1CC6EA230F28AAC47F78051"
        let DOC_CONVERTER_MD5 = "1FC140AD8074E333F9082300F4EA38DC"
        
        let TEMP_DIRECTORY = "socPrint/"
        
        let UPLOAD_FILEPATH = "socPrint/source." //Add path extension later
        let UPLOAD_SOURCE_PDF_FILEPATH = "socPrint/source.pdf"
        let UPLOAD_PDF_FORMATTED_6PAGE_FILEPATH = "socPrint/source-up.pdf"
        let UPLOAD_PDF_FORMATTED_FILEPATH = "socPrint/formatted.pdf"
        let UPLOAD_PS_FILEPATH = "socPrint/ps-converted.ps"
        
        let DIALOG_UPLOAD_DOC_CONV_FAILED = "Upload of document converter failed"
        let DIALOG_UPLOAD_PDF_FORMATTER_FAILED = "Upload of PDF formatter failed"
        let DIALOG_UPLOAD_DOCUMENT_FAILED = "Upload of your document failed"
        let DIALOG_CONVERT_TO_PDF_FAILED = "Converting your document to PDF failed"
        let DIALOG_PRINT_COMMAND_ERROR = "Printing command error"

        var connection : SSHConnectivity!
        var username : String!
        var password : String!
        var hostname : String!
        var pagesPerSheet : String!
        var printerName : String!
        var parent : PrintingViewController!
        var givenFilePath : String!
        var uploadedFilepath : String!
    
        
        init(hostname : String, username : String, password : String, filePath : String, pagesPerSheet : String, printerName : String, parent : PrintingViewController) {
            self.username = username
            self.password = password
            self.hostname = hostname
            self.givenFilePath = filePath
            self.pagesPerSheet = pagesPerSheet
            self.printerName = printerName
            var fileExtension : String = givenFilePath.pathExtension
            uploadedFilepath = UPLOAD_FILEPATH + fileExtension
            self.parent = parent
            
        }
        
        override func main() {
            
   //Supposed to send usability data but seems to have compile problem
//            var fileType : String = givenFilePath.pathExtension
//            
//            var tracker  = GAI.sharedInstance().defaultTracker
//            
//            var dictPrinterName : NSMutableDictionary = GAIDictionaryBuilder.createEventWithCategory("printing", action: "printer", label: printerName, value: nil).build()
//            var dictPagesPerSheet : NSMutableDictionary =  GAIDictionaryBuilder.createEventWithCategory("printing", action: "pagesPerSheet", label: pagesPerSheet, value: nil).build()
//            var dictFileType : NSMutableDictionary =  GAIDictionaryBuilder.createEventWithCategory("printing", action: "fileType", label: fileType, value: nil).build()
//
//            tracker.send(dictPrinterName)
//            tracker.send(dictPagesPerSheet)
//            tracker.send(dictFileType)
            
            
            
            //Step 0: Connecting to server
            parent.currentProgress = parent.POSITION_CONNECTING
            updateUI()
            
            connection = SSHConnectivity(hostname: hostname!, username: username!, password: password!)
            var connectionStatus = connection.connect()
            
            var serverFound : Bool = connectionStatus.serverFound
            var authorised : Bool = connectionStatus.authorised
            
            if(serverFound){
                if(!authorised){
                    stepFailAndCleanUpOperation(CREDENTIALS_WRONG)
                    return
                }
            } else {
                stepFailAndCleanUpOperation(SERVER_UNREACHABLE)
                return
            }
            
            //Step 1: Housekeeping, creating socPrint folder if not yet, delete all files except converters
            
            if(!cancelled){
                parent.currentProgress = parent.POSITION_HOUSEKEEPING
                updateUI()
            
                connection.createDirectory(TEMP_DIRECTORY)
                
                var houseKeepingCommand = "find " + TEMP_DIRECTORY + " -type f \\( \\! -name '" + PDF_CONVERTER_FILENAME + "' \\) \\( \\! -name '" + DOC_CONVERTER_FILENAME + "' \\)\\( \\! -name '" + PDF_CONVERTER_6PAGE_FILENAME + "' \\) -exec rm '{}' \\;"
                
                connection.runCommand(houseKeepingCommand)
            }

            
            //Step 2 : Uploading DOC converter
            if(parent.uploadDocConverterRequired && !cancelled){
                parent.currentProgress = parent.POSITION_UPLOADING_DOC_CONVERTER
                updateUI()
                
                var needToUpload = doesThisFileNeedToBeUploaded(DOC_CONVERTER_FILEPATH, md5Value: DOC_CONVERTER_MD5)
                
                
                var pathToDocConverter : String = NSBundle.mainBundle().pathForResource(DOC_CONVERTER_NAME, ofType: "jar")!
                var docConvSize : Int = getFileSizeOfFile(pathToDocConverter)
                
                if(needToUpload){
                    var docConvURL : NSURL = NSURL.fileURLWithPath(pathToDocConverter)!
                    let docConvUploadProgressBlock = {(bytesUploaded : UInt) -> Bool in
                        
                        let bytesUploadedInt : Int = Int(bytesUploaded)
                        
                        self.updateUIDocConvUpload(docConvSize, uploadedSize: bytesUploadedInt)
                        if(self.cancelled){
                            return false
                        } else {
                            return true
                        }
                    }
                    
                    var uploadStatus = connection.uploadFile(pathToDocConverter, destinationPath: DOC_CONVERTER_FILEPATH, progress: docConvUploadProgressBlock)
                    
                    if(!uploadStatus){
                        stepFailAndCleanUpOperation(DIALOG_UPLOAD_DOC_CONV_FAILED)
                        return
                    }
                
                } else {
                    
                    //Already exists, just use existing file
                    self.updateUIDocConvUpload(docConvSize, uploadedSize: docConvSize)
                }
                
            }
            
            
            //Step 3 : Uploading PDF converter
            if(parent.uploadPDFConverterRequired && !cancelled){
                parent.currentProgress = parent.POSITION_UPLOADING_PDF_CONVERTER
                updateUI()
                
                
                
                var actualFilePath : String!
                var actualMD5 : String!
                var actualName : String!

                
                
                if(pagesPerSheet == "6"){
                    actualFilePath = PDF_CONVERTER_6PAGE_FILEPATH
                    actualMD5 = PDF_CONVERTER_6PAGE_MD5
                    actualName = PDF_CONVERTER_6PAGE_NAME
                } else {
                    actualFilePath = PDF_CONVERTER_FILEPATH
                    actualMD5 = PDF_CONVERTER_MD5
                    actualName = PDF_CONVERTER_NAME
                }
                
                
                var needToUpload = doesThisFileNeedToBeUploaded(actualFilePath, md5Value: actualMD5)
                
                
                var pathToPdfConverter : String = NSBundle.mainBundle().pathForResource(actualName, ofType: "jar")!
                var pdfConvSize : Int = getFileSizeOfFile(pathToPdfConverter)
                
                if(needToUpload){
                    var pdfConvURL : NSURL = NSURL.fileURLWithPath(pathToPdfConverter)!
                    let pdfConvUploadProgressBlock = {(bytesUploaded : UInt) -> Bool in
                        
                        let bytesUploadedInt : Int = Int(bytesUploaded)
                        
                        self.updateUIPDFConvUpload(pdfConvSize, uploadedSize: bytesUploadedInt)
                        if(self.cancelled){
                            return false
                        } else {
                            return true
                        }
                    }
                    
                    var uploadStatus = connection.uploadFile(pathToPdfConverter, destinationPath: actualFilePath, progress: pdfConvUploadProgressBlock)
                    
                    if(!uploadStatus){
                        stepFailAndCleanUpOperation(DIALOG_UPLOAD_PDF_FORMATTER_FAILED)
                        return
                    }
                    
                } else {
                    
                    //Already exists, just use existing file
                    self.updateUIPDFConvUpload(pdfConvSize, uploadedSize: pdfConvSize)
                }
                
            }
            
            //Step 4 : Uploading document
            
            if(!cancelled){
                parent.currentProgress = parent.POSITION_UPLOADING_USER_DOC
                updateUI()
            
                var documentSize : Int = getFileSizeOfFile(givenFilePath)
            
                
                let documentUploadProgressBlock = {(bytesUploaded : UInt) -> Bool in
                    
                    let bytesUploadedInt : Int = Int(bytesUploaded)
                    
                    self.updateUIDocToPrintUpload(documentSize, uploadedSize: bytesUploadedInt)
                    if(self.cancelled){
                        return false
                    } else {
                        return true
                    }
                }
                
                var uploadStatus = connection.uploadFile(givenFilePath, destinationPath: uploadedFilepath, progress: documentUploadProgressBlock)
                
                
                if(!uploadStatus){
                    stepFailAndCleanUpOperation(DIALOG_UPLOAD_DOCUMENT_FAILED)
                    return
                }
                
            }
            
            //Step 5 : Convert document to PDF if necessary
            if(parent.uploadDocConverterRequired && !cancelled){
                parent.currentProgress = parent.POSITION_CONVERTING_TO_PDF
                updateUI()

                
                var conversionCommand : String = "java -jar " + DOC_CONVERTER_FILEPATH + " -i " + uploadedFilepath + " -o " + UPLOAD_SOURCE_PDF_FILEPATH;
                
                var reply : String = connection.runCommand(conversionCommand)
                if(reply.utf16Count != 0){
                    stepFailAndCleanUpOperation(DIALOG_CONVERT_TO_PDF_FAILED, messageToShow : reply)
                    return
                }
                
                
            }
            
            
            //Step 6 : Format PDF to required pages per sheet if required
            var pdfFilepathToConvertToPS : String!

            if(!cancelled){
                
                if(parent.uploadPDFConverterRequired){
                    parent.currentProgress = parent.POSITION_FORMATTING_PDF
                    updateUI()
                    
                    var formattingCommand : String!;
                    if(pagesPerSheet == "6"){
                        formattingCommand = "java -classpath " + PDF_CONVERTER_6PAGE_FILEPATH + " tool.pdf.Impose -paper a4 -nup 6 " + UPLOAD_SOURCE_PDF_FILEPATH;
                        pdfFilepathToConvertToPS = UPLOAD_PDF_FORMATTED_6PAGE_FILEPATH
                    } else {
                        formattingCommand = "java -jar " + PDF_CONVERTER_FILEPATH + " " + UPLOAD_SOURCE_PDF_FILEPATH + " " + UPLOAD_PDF_FORMATTED_FILEPATH + " " + pagesPerSheet
                        pdfFilepathToConvertToPS = UPLOAD_PDF_FORMATTED_FILEPATH
                    }
                    
                    connection.runCommand(formattingCommand)
                    
                    
                } else {
                    pdfFilepathToConvertToPS = UPLOAD_SOURCE_PDF_FILEPATH
                }
    
            }
            
            
            //Step 7 : Converting to postscript
            if(!cancelled){
                parent.currentProgress = parent.POSITION_CONVERTING_TO_POSTSCRIPT
                updateUI()
                
                var conversionCommand : String = "pdftops " + pdfFilepathToConvertToPS + " " + UPLOAD_PS_FILEPATH
                connection.runCommand(conversionCommand)
            }
            
            
            //Final Step 8 : Send to printer
            
            if(!cancelled){
                parent.currentProgress = parent.POSITION_SENDING_TO_PRINTER
                updateUI()
                
                var printingCommand : String = "lpr -P " + printerName + " " + UPLOAD_PS_FILEPATH
                var output = connection.runCommand(printingCommand)
                if(output.utf16Count != 0){
                    stepFailAndCleanUpOperation(DIALOG_PRINT_COMMAND_ERROR, messageToShow: output)
                    return
                }
                
            }
            
            parent.currentProgress = parent.POSITION_COMPLETED
            updateUI()

        
            
        
            self.connection.disconnect()
            self.connection = nil
            
            
        }
        
        func stepFailAndCleanUpOperation(messageToShow : String){
            stepFailAndCleanUpOperation(TITLE_STOP, messageToShow: messageToShow)
        }
        
        
        func stepFailAndCleanUpOperation(title : String, messageToShow : String){
            showAlertInUIThread(title, messageToShow, parent)
            self.connection.disconnect()
            self.connection = nil
            
            dispatch_async(dispatch_get_main_queue(), {(void) in
                self.parent.progressTable.reloadData()
            })
        }
        
        func doesThisFileNeedToBeUploaded(filepath : String, md5Value : String) -> Bool{
            var command = "md5 " + filepath
            var commandOutput = self.connection.runCommand(command)
            
            if(commandOutput.hasPrefix(md5Value)){
                return false
            } else {
                return true
            }
            
        }
        
        func updateUIDocToPrintUpload(totalSize : Int, uploadedSize : Int){
            
            dispatch_async(dispatch_get_main_queue(), {(void) in
                
                self.parent.docToPrintSize = totalSize
                self.parent.docToPrintUploaded = uploadedSize
                self.parent.progressTable.reloadData()
                
            })
        }
        
        
        func updateUIPDFConvUpload(totalSize : Int, uploadedSize : Int){
            
            dispatch_async(dispatch_get_main_queue(), {(void) in
                
                self.parent.pdfConvSize = totalSize
                self.parent.pdfConvUploaded = uploadedSize
                self.parent.progressTable.reloadData()
                
            })
        }
        
        func updateUIDocConvUpload(totalSize : Int, uploadedSize : Int){
            
            dispatch_async(dispatch_get_main_queue(), {(void) in
                
                self.parent.docConvSize = totalSize
                self.parent.docConvUploaded = uploadedSize
                self.parent.progressTable.reloadData()
                
            })
        }
        
        
        func getFileSizeOfFile(path : String) -> Int {
            var attributes : NSDictionary = NSFileManager.defaultManager().attributesOfItemAtPath(path, error: nil)!
            var size : Int = attributes.objectForKey(NSFileSize)!.longValue
            return size
        }
        
        
        func updateUI(){
            dispatch_async(dispatch_get_main_queue(), {(void) in
                self.parent.progressTable.reloadData()
            })
        }
        
        
        
        
        
    }
    
    

    
    
    
    
    
    
    
    
}
