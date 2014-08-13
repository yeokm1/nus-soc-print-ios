//
//  SettingsViewController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 12/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

let RESET_PASSWORD_LINK = "https://mysoc.nus.edu.sg/~myacct/"

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var printerField: UITextField!
    @IBOutlet weak var serverField: UITextField!
    
    @IBAction func saveButtonPress(sender: UIButton) {
    }
    
    @IBAction func forgetButtonPress(sender: UIButton) {
        
        var url  = NSURL.URLWithString(RESET_PASSWORD_LINK)
        UIApplication.sharedApplication().openURL(url)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadAllValuesToUI()
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadAllValuesToUI(){
        var preferences : Storage = Storage.sharedInstance;

        
        var username : String?  = preferences.getUsername()
        usernameField.text = username
        
        var password : String? = preferences.getPassword()
        passwordField.text = password
  
        var printer : String? = preferences.getPrinter()
        printerField.text = printer
        
        var server : String = preferences.getServer()
        serverField.text = server
        
        
    }
    
    
}