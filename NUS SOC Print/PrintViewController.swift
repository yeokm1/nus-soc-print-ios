//
//  PrintViewController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 12/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

class PrintViewController: UIViewController, UIActionSheetDelegate {
    
    let TAG = "PrintViewController"
    let PRINTER_LIST = ["psts", "psts-sx", "pstsb", "pstsb-sx", "pstsc", "pstsc-sx", "psc008", "psc008-sx", "psc011", "psc011-sx", "psc245", "psc245-sx"]
    
    let TEXT_SELECT_PRINTER = "Select Printer"
    let TEXT_CANCEL = "Cancel"
    
    var selectedPrinter = -1
    
    
    @IBOutlet weak var selectPrinter: UIButton!
    @IBOutlet weak var pdfShower: UIWebView!
    
    
    
    @IBAction func selectPrinterPressed(sender: UIButton) {
        var selectPrinterWindow : UIActionSheet = UIActionSheet(title: TEXT_SELECT_PRINTER, delegate: self, cancelButtonTitle: TEXT_CANCEL, destructiveButtonTitle: nil)
        
        
        for printer in PRINTER_LIST {
            selectPrinterWindow.addButtonWithTitle(printer)
        }
        
        
        selectPrinterWindow.showInView(self.view)
        
    }
    
    @IBAction func printButtonPress(sender: UIButton) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        //As index 0 is reserved for the cancelButton
        var actualSelectedIndex = buttonIndex - 1
        
        if(buttonIndex != -1){
            selectedPrinter = actualSelectedIndex
            selectPrinter.setTitle(PRINTER_LIST[actualSelectedIndex], forState: UIControlState.Normal)
        }
        
        NSLog("%@ Selected Printer %d", TAG, actualSelectedIndex);
    }
    
    
}
