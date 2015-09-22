//
//  AppDelegate.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 28/7/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    let TAG = "Appdelegate"
    var window: UIWindow?
    
    var printViewController : PrintViewController?

    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        NSLog("%@ incoming file %@", TAG, url);
        
        
        let filemgr : NSFileManager = NSFileManager.defaultManager()
        
        let tempDirectory : NSString = NSTemporaryDirectory() as NSString
        
        //Remove existing files in temporary directory
        let directoryContents : Array = try! filemgr.contentsOfDirectoryAtPath(NSTemporaryDirectory())
        
        for path in directoryContents {
            

            let fullPath = tempDirectory.stringByAppendingPathComponent(path )
            
            
            do {
                try filemgr.removeItemAtPath(fullPath)
            } catch _ {
            }
        }

        
        
    
        //Move file to tmp directory
        let newURLPath : NSURL = NSURL(fileURLWithPath: tempDirectory.stringByAppendingPathComponent(url.lastPathComponent!))
        
        do {
            try filemgr.moveItemAtURL(url, toURL: newURLPath)
        } catch _ {
        }
        
        
        //Remove stuff from /Document/Inbox directory
        
        let searchDirectories : NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory : NSString = searchDirectories.objectAtIndex(0) as! NSString
        let inboxDirectory : String = documentsDirectory.stringByAppendingPathComponent("Inbox")
        
        let filesInInbox : NSArray = try! filemgr.contentsOfDirectoryAtPath(inboxDirectory)
        
        for filePath in filesInInbox{
            let fullPath : String = (inboxDirectory as NSString).stringByAppendingPathComponent(filePath as! String)
            do {
                try filemgr.removeItemAtPath(fullPath)
            } catch _ {
            }
        }
        

        
        if(printViewController == nil){
            NSLog("%@ openURL printController is nil",TAG)
            incomingURL = newURLPath
        } else {
            NSLog("%@ openURL printController is set",TAG)
            printViewController!.receiveDocumentURL(newURLPath)
            printViewController!.updateDocumentToWebview()
        }
        

        
        
        return true
    }
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // Optional: automatically send uncaught exceptions to Google Analytics.
        GAI.sharedInstance().trackUncaughtExceptions = true
        
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        GAI.sharedInstance().dispatchInterval = 20
        
        // Optional: set Logger to VERBOSE for debug information. Can't work in swift
        //GAI.sharedInstance().logger.logLevel = kGAILogLevelVerbose
        
        // Initialize tracker. Replace with your tracking ID.
        GAI.sharedInstance().trackerWithTrackingId("UA-46031707-2")
        
        return true
    }


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSLog("%@ applicationDidBecomeActive", TAG)

        NSNotificationCenter.defaultCenter().postNotificationName(APP_DID_BECOME_ACTIVE, object: nil)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    

}

