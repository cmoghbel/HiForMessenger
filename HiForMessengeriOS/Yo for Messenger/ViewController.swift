//
//  ViewController.swift
//  Yo for Messenger
//
//  Created by Chris Moghbel on 4/9/15.
//  Copyright (c) 2015 Chris Moghbel. All rights reserved.
//

import UIKit
import Parse
import RestEssentials
import FBSDKCoreKit
import PermissionScope

class ViewController: UIViewController, UITextFieldDelegate {
    
    var emotions = ["Hello", "Happy", "Love", "LOL", "Facepalm", "Uncool", "Celebrate", "Tired", "Hello", "Hello"]
    var colors = [
        UIColor(red: 91 / 255.0,  green: 192 / 255.0, blue: 235 / 255.0, alpha: 1.0), // Light Blue
        UIColor(red: 253 / 255.0, green: 231 / 255.0, blue: 76 / 255.0,  alpha: 1.0), // Yellow
        UIColor(red: 155 / 255.0, green: 197 / 255.0, blue: 61 / 255.0,  alpha: 1.0), // Green
        UIColor(red: 229 / 255.0, green: 89 / 255.0,  blue: 52 / 255.0,  alpha: 1.0), // Red-Orange
        UIColor(red: 250 / 255.0, green: 121 / 255.0, blue: 33 / 255.0,  alpha: 1.0), // Orange
        UIColor(red: 232 / 255.0, green: 63 / 255.0,  blue: 111 / 255.0, alpha: 1.0), // Pink
        UIColor(red: 34 / 255.0,  green: 116 / 255.0, blue: 165 / 255.0, alpha: 1.0), // Blue
        UIColor(red: 150 / 255.0,  green: 63 / 255.0,  blue: 135 / 255.0,  alpha: 1.0), // Purple
        UIColor(red: 91 / 255.0,  green: 192 / 255.0, blue: 235 / 255.0, alpha: 1.0), // Darker Green
        UIColor(red: 91 / 255.0, green: 192 / 255.0, blue: 235 / 255.0,   alpha: 1.0) // Yellow-Orange
    ]
    var searchBox : UITextField!;
    let pscope = PermissionScope()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        pscope.addPermission(NotificationsPermission(notificationCategories: nil),
            message: "We use this to tell you about updates to the app and send you occasional reminders.")
        pscope.show({ (finished, results) -> Void in
                print("got results \(results)")
            }, cancelled: { (results) -> Void in
                print("thing was cancelled")
        })
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        emotions = defaults.objectForKey("emotions") as! [String]
        let colorDicts : [[String:Int]] = defaults.objectForKey("colors") as! [[String:Int]]
        colors = []
        for colorDict in colorDicts {
            colors.append(UIColor(red: CGFloat(colorDict["red"]!) / 255.0, green: CGFloat(colorDict["green"]!) / 255.0, blue: CGFloat(colorDict["blue"]!) / 255.0, alpha: 1.0))
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        searchBox.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        searchBox.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("Called delegate")
        let button = UIButton()
        button.tag = -1
        self.sendYo(button)
        searchBox.resignFirstResponder()
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let window = self.view.window {
            let frame = window.frame
            let padding : CGFloat = 20.0
            
            // Header
            
            let searchButton: UIButton = FBSDKMessengerShareButton.circularButtonWithStyle(FBSDKMessengerShareButtonStyle.Blue)
            searchButton.tag = -1
            searchButton.frame = CGRectMake(0, 0, 40, 40)
            searchButton.addTarget(self, action: "sendYo:", forControlEvents: UIControlEvents.TouchUpInside)
            
            searchBox = UITextField(frame: CGRectMake(padding / 2, padding + 10, frame.width - padding - searchButton.frame.width - 5, 30))
            searchBox.borderStyle = UITextBorderStyle.RoundedRect
            searchBox.placeholder = "Send Custom Emotion, e.g. Silly..."
            searchBox.delegate = self
            
            searchButton.frame = CGRectMake(searchBox.frame.origin.x + searchBox.frame.size.width + 5, padding, searchButton.frame.width, searchButton.frame.height)
            
            self.view.addSubview(searchButton)
            self.view.addSubview(searchBox)
            
            let headerHeight = searchButton.frame.height + padding
            
            // Footer
            
            let shareSheetButton = UIButton(frame: CGRectMake(0, 0, 64, 64))
            shareSheetButton.addTarget(self, action: "shareSheet", forControlEvents: UIControlEvents.TouchUpInside)
            shareSheetButton.setImage(UIImage(named: "share.png"), forState: UIControlState.Normal)
            shareSheetButton.setImage(UIImage(named: "share.png"), forState: UIControlState.Highlighted)
            self.view.addSubview(shareSheetButton)
            
            let giphyAttrImage : UIImage! = UIImage(named: "giphy_attr.png")
            
            let hasAlpha = false
            let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
            let sizeChange: CGSize = CGSize(width: 641 / 6.0, height: 71 / 6.0)
            
            UIGraphicsBeginImageContextWithOptions(sizeChange, hasAlpha, scale)
            giphyAttrImage!.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
            let scaledImage : UIImage! = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let giphyAttr: UIImageView! = UIImageView(image: scaledImage)
            giphyAttr.sizeToFit()
            self.view.addSubview(giphyAttr)
            
            let giphyAttrSize = giphyAttr.image!.size
            giphyAttr.frame = CGRectMake(frame.width / 2 - (giphyAttrSize.width / 2), frame.height - giphyAttrSize.height - (padding / 4), giphyAttrSize.width, giphyAttrSize.height)
            
            let shareButtonSize = shareSheetButton.frame.size
            let footerHeight = shareButtonSize.height + padding / 2
            
            shareSheetButton.frame = CGRectMake(frame.width / 2 - (shareButtonSize.width / 2), frame.height - footerHeight - 5, 64, 64)
            
            // Body
            
            let bodyHeight = frame.height - headerHeight - footerHeight + padding
            var heightRemaining = bodyHeight
            var numRows : CGFloat = 0
            var rowHeight : CGFloat = 0.0
            
            repeat {
                
                let emotionNum1 = Int(2 * numRows) % emotions.count
                let emotionNum2 = (Int(2 * numRows) + 1) % emotions.count
                
                let label: UILabel = UILabel()
                label.text = emotions[emotionNum1]
                label.font = UIFont (name: "HelveticaNeue-Bold", size: 20.0)
                label.sizeToFit()
                
                let label2: UILabel = UILabel()
                label2.text = emotions[emotionNum2]
                label2.font = UIFont (name: "HelveticaNeue-Bold", size: 20.0)
                label2.sizeToFit()
                
                let button: UIButton = FBSDKMessengerShareButton.circularButtonWithStyle(FBSDKMessengerShareButtonStyle.Blue)
                button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.width / 2, button.frame.height / 2)
                button.tag = emotionNum1
                button.addTarget(self, action: "sendYo:", forControlEvents: UIControlEvents.TouchUpInside)
                
                let button2: UIButton = FBSDKMessengerShareButton.circularButtonWithStyle(FBSDKMessengerShareButtonStyle.Blue)
                button2.frame = CGRectMake(button2.frame.origin.x, button2.frame.origin.y, button2.frame.width / 2, button2.frame.height / 2)
                button2.tag = emotionNum2
                button2.addTarget(self, action: "sendYo:", forControlEvents: UIControlEvents.TouchUpInside)
                
                var labelSize = label.frame.size
                var buttonSize = button.frame.size
                
                rowHeight = labelSize.height + buttonSize.height + padding + 5
                let rowYStart = headerHeight + (rowHeight * numRows) + (padding / 2)
                
                // Row - left
                
                label.frame = CGRectMake(frame.width / 4 - (labelSize.width / 2), rowYStart, labelSize.width, labelSize.height)
                
                button.frame = CGRectMake(frame.width / 4 - (buttonSize.width / 2), rowYStart + labelSize.height, buttonSize.width, buttonSize.height)
                
                let background = UIView(frame: CGRectMake(padding / 2, rowYStart, (frame.width / 2) - (padding), rowHeight - padding))
                background.layer.cornerRadius = 8.0
                background.clipsToBounds = true
                background.backgroundColor = colors[emotionNum1]

                self.view.addSubview(background)
                self.view.addSubview(label)
                self.view.addSubview(button)
                
                // Row - right
                
                labelSize = label2.frame.size
                label2.frame = CGRectMake(3*(frame.width / 4) - (labelSize.width / 2), rowYStart, labelSize.width, labelSize.height)
                
                buttonSize = button2.frame.size
                button2.frame = CGRectMake(3*(frame.width / 4) - (buttonSize.width / 2), rowYStart + labelSize.height, buttonSize.width, buttonSize.height)
                
                let background2 = UIView(frame: CGRectMake((frame.width / 2) + (padding / 2), rowYStart, (frame.width / 2) - (padding), rowHeight - padding))
                background2.layer.cornerRadius = 8.0
                background2.clipsToBounds = true
                background2.backgroundColor = colors[emotionNum2]
                
                self.view.addSubview(background2)
                self.view.addSubview(label2)
                self.view.addSubview(button2)
                
                numRows += 1
                heightRemaining = heightRemaining - rowHeight
                
            } while (heightRemaining > rowHeight)
   
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getGifData(urlString: String) -> NSData? {
        // If locally cached, grab that first?
        let gifData = NSData(contentsOfURL: NSURL(string: urlString)!)
        // Save gifData somewhere to grab later?
        return gifData
    }
    
    @objc func sendYo(sender: UIButton) {
        
        searchBox.resignFirstResponder()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        var emotion: String!;
        
        if (sender.tag == -1) {
            if ((searchBox.text) != nil) {
                emotion = searchBox.text
            }
            else {
                emotion = "Hi";
            }
        }
        else {
            emotion = emotions[sender.tag]
        }
        
        let unescaped_url = "http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" + emotion;
        let escaped_url = unescaped_url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        guard let rest = RestController.createFromURLString(escaped_url) else {
            print("Bad URL")
            return
        }
        
        rest.get() { result in
            do {
                let json = try result.value()
                let gifUrl = json["data"]?["image_url"]?.stringValue
                print(gifUrl)
                let options : FBSDKMessengerShareOptions = FBSDKMessengerShareOptions()
                options.metadata = "{ \"gif\" : \"randomNumberString\" }"
                options.contextOverride = self.getContextForShareMode()
                
                let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.shareMode = MessengerShareMode.Send
                
                let gifData = self.getGifData(gifUrl!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    // code here
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    FBSDKAppEvents.logEvent("sentGif", parameters: ["emotion": emotion])
                    FBSDKMessengerSharer.shareAnimatedGIF(gifData, withOptions: options)
                })
                
            } catch {
                print("Error performing GET: \(error)")
            }
        }
    }

    func getContextForShareMode() -> FBSDKMessengerContext {
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        switch appDelegate.shareMode {
        case .Send:
            return FBSDKMessengerBroadcastContext()
        case .Composer:
            return appDelegate.composerContext!
        case .Reply:
            return appDelegate.replyContext!
            
        }
    }
    
    func shareSheet() {
        
        guard let rest = RestController.createFromURLString("http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC") else {
            print("Bad URL")
            return
        }
        
        rest.get() { result in
            do {
                let json = try result.value()
                let gifUrl = json["data"]?["image_url"]?.stringValue
                print(gifUrl)
                let options : FBSDKMessengerShareOptions = FBSDKMessengerShareOptions()
                options.metadata = "{ \"gif\" : \"randomNumberString\" }"
                options.contextOverride = self.getContextForShareMode()
                
                let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.shareMode = MessengerShareMode.Send
                
                if let gifData = self.getGifData(gifUrl!) {
                    let activityViewController : UIActivityViewController = UIActivityViewController(
                        activityItems: ["Yo", gifData], applicationActivities: nil)
                    
                    activityViewController.excludedActivityTypes = [
                        UIActivityTypePostToWeibo,
                        UIActivityTypePrint,
                        UIActivityTypeAssignToContact,
                        UIActivityTypeAddToReadingList,
                        UIActivityTypePostToFlickr,
                        UIActivityTypePostToVimeo,
                        UIActivityTypePostToTencentWeibo,
                        UIActivityTypeMessage,
                        UIActivityTypePostToFacebook,
                        UIActivityTypeAirDrop,
                        UIActivityTypePostToTwitter,
                        UIActivityTypeMail
                    ]
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        // code here
                        self.presentViewController(activityViewController, animated: true, completion: nil)
                    })

                }
            } catch {
                print("Error performing GET: \(error)")
            }

        }
    }

}

