//
//  SettingsViewController.swift
//  BKLoki
//
//  Created by Sara Du on 4/30/16.
//  Copyright © 2016 Masanori Uehara. All rights reserved.
//

import UIKit
import BluetoothKit
import CoreBluetooth
import AVFoundation

class SettingsViewController: UITableViewController, AVAudioPlayerDelegate  {
    
    var userEmailAddress: String!

    @IBOutlet weak var microsoftsigninbutton: UIButton!
    
    private var localName: String!
    var player : AVAudioPlayer! = nil // will be Optional, must supply initializer

    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(defaults.boolForKey("loggedin")){
            microsoftsigninbutton.tintColor = UIColor.grayColor()
        }
        
        //register for notification
        registerLocal(UIViewController)

    }
    
    func callNotification(discoveries: [BKDiscovery]) {
        for device in discoveries {
            //Sending notifications
            let name = (device.localName != nil) ? device.localName! : "Unknown"
            self.scheduleLocal(UIViewController(), name: name)
            print("scheduling the notification")
        }
    
    }
            
    func registerLocal(sender: AnyObject) {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    func scheduleLocal(sender: AnyObject, name: String) {
        guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else { return }
        
        if(UIApplication.sharedApplication().applicationState == UIApplicationState.Active){
            let alertController = UIAlertController(title: name.uppercaseString + " is approaching you", message: "Do you want to see what your choice are?", preferredStyle: .Alert)
            let acceptAction = UIAlertAction(title: "Yes", style: .Default) { (_) -> Void in
                self.performSegueWithIdentifier("boxes", sender: self)
            }
            alertController.addAction(acceptAction)
            alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)

        }
        
        
        // if notification failed to initialize
        if settings.types == .None {
            let ac = UIAlertController(title: "Can't schedule", message: "Either we don't have permission to schedule notifications, or we haven't asked yet.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            return
        }
        
        //play the music
        let path = NSBundle.mainBundle().pathForResource("answercellphone", ofType:"wav")
        let fileURL = NSURL(fileURLWithPath: path!)
        do {
            try player = AVAudioPlayer(contentsOfURL: fileURL, fileTypeHint: nil)
        } catch {
            print("Error")
        }
        player.prepareToPlay()
        player.delegate = self
        player.play()
        
        //notification of who is nearby
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 5) // wait for 5 seconds before notifying
        notification.alertBody = name + " is approaching"
        notification.alertAction = "Run away?" // Displayed as "Slide to..."
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginMicrosoft(sender: AnyObject) {
        AuthenticationManager.sharedInstance?.acquireAuthToken ({
            (result: AuthenticationResult) -> Void in
            
            switch result {
            case .Success:
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alertController = UIAlertController(title: "Congrats!", message: "You've successfully signed in", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
                
            case .Failure(let error):
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    /*
                    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    */
                    print(error)
                })
            }
        })
        userEmailAddress = AuthenticationManager.sharedInstance?.userInformation?.userId
        sendMail(self)

    }
    
    
    // MARK: IBActions
    func sendMail(sender: AnyObject) {
        if let uploadContent = mailContent() {
            sendMailRestWithContent(uploadContent)
        }
        else {
            print("error")
        }
    }
    
    
    
    
    // MARK: Helper methods
    
    /**
    Prepare mail content by loading the files from resources and replacing placeholders with the
    HTML body.
    */
    func mailContent() -> NSData? {
        var emailname = ""
        if(defaults.boolForKey("loggedin")){
            emailname = "Mail"
        }else{
            emailname = "EmailBody"
        }
        if let emailFilePath = NSBundle.mainBundle().pathForResource("EmailPostContent", ofType: "json"),
            emailBodyFilePath = NSBundle.mainBundle().pathForResource(emailname, ofType: "html")
        {
            do {
                // Prepare upload content
                let emailContent = try String(contentsOfFile: emailFilePath, encoding: NSUTF8StringEncoding)
                let emailBodyRaw = try String(contentsOfFile: emailBodyFilePath, encoding: NSUTF8StringEncoding)
                // Request doesn't accept a single quotation mark("), so change it to the acceptable form (\")
                let emailValidBody = emailBodyRaw.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
                
                let emailPostContent = emailContent.stringByReplacingOccurrencesOfString("<EMAIL>", withString: "\(userEmailAddress)")
                    .stringByReplacingOccurrencesOfString("<CONTENTTYPE>", withString: "HTML")
                    .stringByReplacingOccurrencesOfString("<CONTENT>", withString: emailValidBody)
                
                return emailPostContent.dataUsingEncoding(NSUTF8StringEncoding)
            }
            catch {
                // Error handling in case file loading fails.
                return nil
            }
        }
        // Error handling in case files aren't present.
        return nil
    }
    
    func sendMailRestWithContent(content: NSData) {
        // Acquire an access token, if logged in already, this shouldn't bring up an authentication window.
        // However, if the token is expired, user will be asked to sign in again.
        AuthenticationManager.sharedInstance!.acquireAuthToken {
            (result: AuthenticationResult) -> Void in
            
            switch result {
                
            case .Success:
                // Upon success, send mail.
                self.defaults.setBool(true, forKey: "loggedin")
                let request = NSMutableURLRequest(URL: NSURL(string: "https://graph.microsoft.com/v1.0/me/microsoft.graph.sendmail")!)
                request.HTTPMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
                
                request.setValue("Bearer \(AuthenticationManager.sharedInstance!.accessToken!)", forHTTPHeaderField: "Authorization")
                
                request.HTTPBody = content
                
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler:
                    {
                        (data, response, error) -> Void in
                        
                        if let _ = error {
                            print(error)
                            
                            return
                        }
                        
                        let statusCode = (response as! NSHTTPURLResponse).statusCode
                        
                        if statusCode == 202 {
                            
                        }
                        else {
                            print("response: \(response)")
                            print(String(data: data!, encoding: NSUTF8StringEncoding))
                            
                        }
                })
                
                task.resume()
                
            case .Failure(let error):
                // Upon failure, alert and go back.
                self.defaults.setBool(false, forKey: "loggedin")
                print(error)
                
                
                
            }
        }
    }
    
    


}
