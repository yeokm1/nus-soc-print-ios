//
//  SSHConnectivity.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 17/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation

class SSHConnectivity{
    
    let TAG = "SSHConnectivity"
    
    var session : NMSSHSession?
    var username : String?
    var password : String?
    var hostname : String?
    
    init(hostname : String, username : String, password : String){
        self.username = username
        self.password = password
        self.hostname = hostname
    }
    
    
    func connect() -> (serverFound : Bool, authorised : Bool){
        if(session != nil){
            session?.disconnect()
        }
        
        session = NMSSHSession(host: hostname, andUsername: username)
        session?.connect()
        
        if (session!.connected) {
            NSLog("%@ session connected", TAG)
            
            session?.authenticateByPassword(password)
            
        
            if (session!.authorized) {
                NSLog("%@ session authorised", TAG)
                
                return (true, true)
            } else {
                NSLog("%@ session not authorised", TAG)
                session?.disconnect()
                
                return (true, false)
            }
        } else {
            NSLog("%@ session failed to connect", TAG)
            session?.disconnect()
            
            return (false, false)
        }
    }
    
    func runCommand(command : String) -> String{

        if(session == nil){
            return "Nil"
        }

        var commandOutput : String? =  try? session!.channel.execute(command)

    
        if(commandOutput == nil){
            commandOutput = "Nil"
        }
        
        NSLog("%@ runCommand:%@, output:%@ ", TAG, command, commandOutput!)
        
        return commandOutput!

    }
    
    func createDirectory(toBeCreated : String){
        runCommand("mkdir " + toBeCreated)
    }
    
    
    func uploadFilePathURL(sourceURL : NSURL, destinationPath : String, progress: ((UInt) -> Bool)) -> Bool{
        let filePath : String = sourceURL.absoluteString
        return uploadFile(filePath, destinationPath: destinationPath, progress: progress)
    }
    
    func uploadFile(sourcePath : String, destinationPath : String, progress: ((UInt) -> Bool)) -> Bool{
        NSLog("%@ uploading file from %@ to %@", TAG, sourcePath, destinationPath)
        return session!.channel.uploadFile(sourcePath, to: destinationPath, progress: progress)
    }
    
    
    func disconnect(){
        session?.disconnect()
        session = nil
    }
    
 
    
}
