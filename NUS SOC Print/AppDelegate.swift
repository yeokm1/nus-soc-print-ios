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

    
    func application(application: UIApplication!, openURL url: NSURL!, sourceApplication: String!, annotation: AnyObject!) -> Bool {
        NSLog("%@ incoming file %@", TAG, url);
        
        
        var filemgr : NSFileManager = NSFileManager.defaultManager()
        
        
        
        //Remove existing files in temporary directory
        var directoryContents : Array = filemgr.contentsOfDirectoryAtPath(NSTemporaryDirectory(), error: nil)!
        
        for path in directoryContents {
            var fullPath = NSTemporaryDirectory().stringByAppendingPathComponent(path as String)
            filemgr.removeItemAtPath(fullPath, error: nil)
        }

        
        
    
        //Move file to tmp directory
        var newURLPath = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent(url.lastPathComponent))
        
        filemgr.moveItemAtURL(url, toURL: newURLPath, error: nil)
        
        
        //Remove stuff from /Document/Inbox directory
        
        var searchDirectories : NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var documentsDirectory : NSString = searchDirectories.objectAtIndex(0) as NSString
        var inboxDirectory = documentsDirectory.stringByAppendingPathComponent("Inbox")
        
        var filesInInbox : NSArray = filemgr.contentsOfDirectoryAtPath(inboxDirectory, error: nil)!
        
        for filePath in filesInInbox{
            var fullPath : String = inboxDirectory.stringByAppendingPathComponent(filePath as String)
            filemgr.removeItemAtPath(fullPath, error: nil)
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
    

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
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

    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSLog("%@ applicationDidBecomeActive", TAG)

        
        if(printViewController == nil){

            let delay = 2 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
   
        
            dispatch_after(time, dispatch_get_main_queue(), {(void) in
                if(self.printViewController == nil){
                    NSLog("%@ after waiting printController still nil", self.TAG)
                    var printController = self.getPrintController()
                    printController.updateDocumentToWebview()
                
                } else {
                    NSLog("%@ after waiting printController is set", self.TAG)
                    
                    self.printViewController!.updateDocumentToWebview()
                }
                
            });
        } else {
            NSLog("%@ app become active update printcontroller", TAG)
            printViewController!.updateDocumentToWebview()
        }
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func getPrintController() -> PrintViewController {
        var storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var vc : PrintViewController = storyboard.instantiateViewControllerWithIdentifier("printID") as PrintViewController;
        return vc
    }


}

