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
    
    let HEADER_TEXT : Array<String> =
    ["Connecting to server"
    ,"Some housekeeping"
    ,"Uploading doc converter"
    ,"Uploading PDF Formatter"
    ,"Formatting PDF"
    ,"Converting to Postscript"
    ,"Sending to printer"]
    
    
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
    
    @IBOutlet weak var progressTable: UITableView!
    
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressTable.dataSource = self
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
    
    
    
    
    
    
    
    
    
    
    
}
