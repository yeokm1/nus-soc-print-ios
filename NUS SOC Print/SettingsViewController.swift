//
//  SettingsViewController.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 12/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var printerField: UITextField!
    @IBOutlet weak var serverField: UITextField!
    
    @IBAction func saveButtonPress(sender: UIButton) {
    }
    
    @IBAction func forgetButtonPress(sender: UIButton) {
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

        var username : NSString? = preferences.getUsername()
        var password : NSString? = preferences.getPassword()
        var printer : NSString? = preferences.getPrinter()
        var server : NSString? = preferences.getServer()
        
        
        if(username != nil){
            usernameField.text = username;
        }
        
        
        
    }
    
    
}