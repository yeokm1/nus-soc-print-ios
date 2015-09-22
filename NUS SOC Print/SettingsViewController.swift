//
//  SettingsViewController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 12/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit


class SettingsViewController: GAITrackedViewController, UITextFieldDelegate{
    
    let TAG = "SettingsViewController"
    
    let RESET_PASSWORD_LINK = "https://mysoc.nus.edu.sg/~myacct/"
    
    let DIALOG_SAVE_TITLE = "Saved!"
    let DIALOG_SAVE_TEXT = "All fields saved!"
    
    let DIALOG_EMPTY_FIELDS_TITLE = "Empty Fields"
    let DIALOG_EMPTY_FIELDS_TEXT = "Username/Password/Server fields are empty. This app will not work without your Unix credentials or a server setting."

    
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var printerField: UITextField!
    @IBOutlet weak var serverField: UITextField!
    
    @IBAction func saveButtonPress(sender: UIButton) {
        saveStuff()
    }
    
    
    @IBAction func forgetButtonPress(sender: UIButton) {
        
        let url : NSURL = NSURL(string: RESET_PASSWORD_LINK)!
        UIApplication.sharedApplication().openURL(url)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        usernameField.delegate = self
        passwordField.delegate = self
        printerField.delegate = self
        serverField.delegate = self
        
        loadAllValuesToUI()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = TAG;
    }
    
    func saveStuff(){
        let preferences : Storage = Storage.sharedInstance;
        
        let username : String? = usernameField.text
        let password : String? = passwordField.text
        let printer : String? = printerField.text
        let server : String? = serverField.text
        
        if username == nil || password == nil || printer == nil || server == nil
            || username!.isEmpty || password!.isEmpty || server!.isEmpty {
            showAlert(DIALOG_EMPTY_FIELDS_TITLE, message: DIALOG_EMPTY_FIELDS_TEXT, viewController: self)
        } else {
            preferences.storeUsername(username!)
            preferences.storePassword(password!)
            preferences.storePrinter(printer!)
            preferences.storeServer(server!)
            closeKeyboard()
            showAlert(DIALOG_SAVE_TITLE, message: DIALOG_SAVE_TEXT, viewController: self)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        usernameField.text = nil
        passwordField.text = nil
        printerField.text = nil
        serverField.text = nil
    }

    
    func loadAllValuesToUI(){
        let preferences : Storage = Storage.sharedInstance;

        
        let username : String?  = preferences.getUsername()
        usernameField.text = username
        
        let password : String? = preferences.getPassword()
        passwordField.text = password
  
        let printer : String? = preferences.getPrinter()
        printerField.text = printer
        
        let server : String = preferences.getServer()
        serverField.text = server
    }
    

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    //To close keyboard if user tap outside
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        closeKeyboard()
    }

    func closeKeyboard(){
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        printerField.resignFirstResponder()
        serverField.resignFirstResponder()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
}