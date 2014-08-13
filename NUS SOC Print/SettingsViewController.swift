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

let DIALOG_TITLE = "Empty Fields"
let DIALOG_TEXT = "Username/Password/Server fields are empty. This app will not work without your Unix credentials or a server setting."
let DIALOG_OK = "OK"

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
        
        if username.isEmpty || password.isEmpty || server.isEmpty {
            showAlert()
        }
        
    }
    
    @IBAction func forgetButtonPress(sender: UIButton) {
        
        var url  = NSURL.URLWithString(RESET_PASSWORD_LINK)
        UIApplication.sharedApplication().openURL(url)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        printerField.delegate = self
        serverField.delegate = self
        
        loadAllValuesToUI()
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
    
    func showAlert(){
        var alert = UIAlertController(title: DIALOG_TITLE, message: DIALOG_TEXT, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: DIALOG_OK, style: UIAlertActionStyle.Default, handler: nil))

        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
}