//
//  AppDelegate.swift
//  Yo for Messenger
//
//  Created by Chris Moghbel on 4/9/15.
//  Copyright (c) 2015 Chris Moghbel. All rights reserved.
//

import UIKit
import Parse
import Bolts
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FBSDKMessengerURLHandlerDelegate {

    var window: UIWindow?
    var messengerUrlHandler : FBSDKMessengerURLHandler = FBSDKMessengerURLHandler()
    var composerContext : FBSDKMessengerURLHandlerOpenFromComposerContext?
    var replyContext : FBSDKMessengerURLHandlerReplyContext?
    var shareMode : MessengerShareMode = MessengerShareMode.Send


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        messengerUrlHandler.delegate = self
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let addedDefaults = defaults.boolForKey("addedDefaults")
        if (!addedDefaults) {
            let defaultEmotions = ["Hello", "Happy", "Love", "LOL", "Facepalm", "Uncool", "Celebrate", "Tired", "Confused", " Hello"]
            defaults.setObject(defaultEmotions, forKey: "emotions")
            let defaultColors = [
                [
                    "blue": 235,
                    "green": 192,
                    "red": 91
                ],
                [
                    "blue": 76,
                    "green": 231,
                    "red": 253,
                ],
                [
                    "blue": 61,
                    "green": 197,
                    "red": 155,
                ],
                [
                    "blue": 52,
                    "green": 89,
                    "red": 229,
                ],
                [
                    "blue": 33,
                    "green": 121,
                    "red": 250,
                ],
                [
                    "blue": 111,
                    "green": 63,
                    "red": 232,
                ],
                [
                    "blue": 165,
                    "green": 116,
                    "red": 34,
                ],
                [
                    "blue": 135,
                    "green": 63,
                    "red": 150,
                ],
                [
                    "blue": 111,
                    "green": 147,
                    "red": 50,
                ],
                [
                    "blue": 235,
                    "green": 192,
                    "red": 91
                ]
            ]
            defaults.setObject(defaultColors, forKey: "colors")
            defaults.setBool(false, forKey: "fetchedServerDefaultsOnce")
            print("Added default values")
            defaults.setBool(true, forKey: "addedDefaults")
        }
        
        // Download emotions and colors from server
        Parse.setApplicationId("9fkaq9d9twRyTtZzrozQ9Qq4MpBFfXxkOI8m6Fc1", clientKey: "L6t8sZHuGd5gj9IXNPikJHJiOlm3IM7Qzvlf7O02")

        if (defaults.boolForKey("fetchedServerDefaultsOnce")) {
            print("Fetched defaults from server at some point in past, trying with refresh with non-blocking call")
            PFCloud.callFunctionInBackground("defaults", withParameters: nil, block: { (serverDefaults, error) -> Void in
                if (error == nil) {
                    self.saveServerDefaults(serverDefaults as! [String: AnyObject])
                } else {
                    print("ERROR: Something went wrong downloading emotions from server")
                    print(error)
                }
            })
        } else {
            do {
                print("Never fetched defaults from server, trying with blocking call")
                let serverDefaults = try PFCloud.callFunction("defaults", withParameters: nil)
                self.saveServerDefaults(serverDefaults as! [String : AnyObject])
                defaults.setBool(true, forKey: "fetchedServerDefaultsOnce")
            } catch {}
        }
        
        return true
    }
    
    func saveServerDefaults(serverDefaults: [String:AnyObject]) {
        let defaults = NSUserDefaults.standardUserDefaults()
        print("Succesfully downloaded defaults from server")
        print(serverDefaults)
        let emotions = serverDefaults["emotions"]
        let colors = serverDefaults["colors"]
        defaults.setObject(emotions, forKey: "emotions")
        defaults.setObject(colors, forKey: "colors")
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.shareMode = MessengerShareMode.Send
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.shareMode = MessengerShareMode.Send
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp();
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        if (messengerUrlHandler.canOpenURL(url, sourceApplication: sourceApplication)) {
            messengerUrlHandler.openURL(url, sourceApplication: sourceApplication)
        }
        
        return true
    }
    
    func messengerURLHandler(messengerURLHandler: FBSDKMessengerURLHandler!, didHandleOpenFromComposerWithContext context: FBSDKMessengerURLHandlerOpenFromComposerContext!) {
        composerContext = context
        shareMode = MessengerShareMode.Composer
    }
    
    func messengerURLHandler(messengerURLHandler: FBSDKMessengerURLHandler!, didHandleReplyWithContext context: FBSDKMessengerURLHandlerReplyContext!) {
        replyContext = context
        shareMode = MessengerShareMode.Reply
    }


}

