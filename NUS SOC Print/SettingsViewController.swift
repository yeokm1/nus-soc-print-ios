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

class SettingsViewController: UIViewController, UITextFieldDelegate{
    
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var printerField: UITextField!
    @IBOutlet weak var serverField: UITextField!
    
    @IBAction func saveButtonPress(sender: UIButton) {
        var preferences : Storage = Storage.sharedInstance;
        
        var username = usernameField.text
        var password = passwordField.text
        var printer = printerField.text
        var server = serverField.text
        
        preferences.storeUsername(username)
        preferences.storePassword(password)
        preferences.storePrinter(printer)
        preferences.storeServer(server)
        
    }
    
    @IBAction func forgetButtonPress(sender: UIButton) {
        
        var url  = NSURL.URLWithString(RESET_PASSWORD_LINK)
        UIApplication.sharedApplication().openURL(url)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        usernameField.delegate = self
        passwordField.delegate = self
        printerField.delegate = self
        serverField.delegate = self
        
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
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    
}