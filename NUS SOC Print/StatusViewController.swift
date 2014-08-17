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
    
    @IBOutlet weak var statusOutputView: UITextView!
    
    @IBAction func closeButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func refreshButtonPressed(sender: UIButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
