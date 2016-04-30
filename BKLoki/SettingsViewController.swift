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

class SettingsViewController: UITableViewController,BKCentralDelegate, BKPeripheralDelegate, AVAudioPlayerDelegate  {
    
    var userEmailAddress: String!

    @IBOutlet weak var microsoftsigninbutton: UIButton!
    
    private let central = BKCentral()
    private let peripheral = BKPeripheral()
    private var discoveries = [BKDiscovery]()
    private var localName = String!()
    var player : AVAudioPlayer! = nil // will be Optional, must supply initializer

    
    let defaults = NSUserDefaults.standardUserDefaults()
    let serviceUUID = NSUUID(UUIDString: "470275F0-EF0A-4A20-9CEF-D160A4C25BF9")!
    let characteristicUUID = NSUUID(UUIDString: "E9CF5BAD-8D47-4C2E-A3D6-620115807AAD")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(defaults.boolForKey("loggedin")){
            microsoftsigninbutton.tintColor = UIColor.grayColor()
        }
        /*
        let path = NSBundle.mainBundle().pathForResource("answercellphone.wav", ofType:nil)!
        let url = NSURL(fileURLWithPath: path)
        
        do {
            sound = try AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Error")
        }
        */
        self.initCentral()
        self.initPeripheral()
        
        //register for notification
        registerLocal(UIViewController)

    }
    
    internal override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("View did appear")
        scan()
    }
    
    internal override func viewWillDisappear(animated: Bool) {
        central.interrupScan()
    }
    
    func scan() {
        
        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
            // Handle changes to "availabile" discoveries, [BKDiscoveriesChange].
            // Handle current "available" discoveries, [BKDiscovery].
            // This is where you'd ie. update a table view.
            let indexPathsToRemove = changes.filter({ $0 == .Remove(discovery: nil) }).map({ NSIndexPath(forRow: self.discoveries.indexOf($0.discovery)!, inSection: 0) })
            self.discoveries = discoveries
            let indexPathsToInsert = changes.filter({ $0 == .Insert(discovery: nil) }).map({ NSIndexPath(forRow: self.discoveries.indexOf($0.discovery)!, inSection: 0) })
            
            for device in discoveries {
                print("-----------------------------")
                print("\(device.localName): \(device.remotePeripheral.identifier.UUIDString)")
                
                
                //Sending notifications
                print(self.defaults.objectForKey("correspondingNames"))
                if(self.defaults.objectForKey("correspondingNames") != nil){
                let devicenamearray = self.defaults.objectForKey("correspondingNames") as! [String]
                print(devicenamearray)
                let x = devicenamearray.count
                for i in 0...x-1{
                   // if(UUIDarray[i] == device.remotePeripheral.identifier.UUIDString){
                        let name = self.defaults.objectForKey("correspondingNames") as! [String]
                        self.scheduleLocal(UIViewController(), name: name[i])
                    print("scheduling the notification")
                    //}
                }
                }
                
            }
            
            }, stateHandler: { newState in
                if newState == .Scanning {
                    print("scanning")
                    return
                } else if newState == .Stopped {
                    self.discoveries.removeAll()
                    print("stopped")
                }
            }, errorHandler: { error in
                // Handle error.
                print(error)
        })
        
    }
    func registerLocal(sender: AnyObject) {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    func scheduleLocal(sender: AnyObject, name: String) {
        guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else { return }
        
        // if notification failed to initialize
        if settings.types == .None {
            let ac = UIAlertController(title: "Can't schedule", message: "Either we don't have permission to schedule notifications, or we haven't asked yet.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            return
        }
        
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
        
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 5) // wait for 5 seconds before notifying
        notification.alertBody = name + " is approaching"
        notification.alertAction = "Run away?" // Displayed as "Slide to..."
        //notification.soundName = UILocalNotificationDefaultSoundName
        //notification.userInfo = ["CustomField1": "Sara-Max"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    

    
    func initCentral() {
        do {
            central.delegate = self
            let configuration = BKConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID: characteristicUUID)
            try central.startWithConfiguration(configuration)
            // You are now ready to discover and connect to peripherals.
            
            print("init central")
            
        } catch let error {
            // Handle error.
            print("Central init failed \(error)")
        }
    }
    
    func initPeripheral() {
        do {
            peripheral.delegate = self
            
            
            localName = UIDevice.currentDevice().name
            
            //            var arrayofUUID = defaults.objectForKey("arrayofUUID") as! [String]
            //            arrayofUUID.append(localName!)
            //            defaults.setObject(arrayofUUID, forKey: "arrayofUUID")
            
            
            
            let configuration = BKPeripheralConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID:  characteristicUUID, localName: localName)
            try peripheral.startWithConfiguration(configuration)
            // You are now ready for incoming connections
            
            print("Initialized peripheral")
            
        } catch let error {
            // Handle error.
            print("Peripheral init failed \(error)")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    internal func central(central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        print("Remote peripheral did disconnect: \(remotePeripheral)")
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    
    
    internal func peripheral(peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
        print("Remote central did connect: \(remoteCentral)")
    }
    
    internal func peripheral(peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        print("Remote central did disconnect: \(remoteCentral)")
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
