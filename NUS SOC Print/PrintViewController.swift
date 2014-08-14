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
    
    
    @IBOutlet weak var selectPrinter: UIButton!
    @IBAction func selectPrinterPressed(sender: UIButton) {
        var selectPrinterWindow : UIActionSheet = UIActionSheet(title: TEXT_SELECT_PRINTER, delegate: self, cancelButtonTitle: TEXT_CANCEL, destructiveButtonTitle: nil)
        
        
        for printer in PRINTER_LIST {
            selectPrinterWindow.addButtonWithTitle(printer)
        }
        
        
        selectPrinterWindow.showInView(self.view)
        
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
        //As index 0 is reserved for the destructiveButton which I'm not using
        var actualSelectedIndex = buttonIndex - 1
        
        NSLog("%@ Selected Printer %d", TAG, actualSelectedIndex);
    }
    
    
}
