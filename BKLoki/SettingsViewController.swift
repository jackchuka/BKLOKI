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

class SettingsViewController: UIViewController {
    
    private let central = FirstViewController.central
    
    private var discoveries = [BKDiscovery]()
    private var localName = String!()
    var sound = AVAudioPlayer()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register for notification
        registerLocal(UIViewController)

    }
    
    func callNotification(discoveries: [BKDiscovery]) {
        print("notification method")
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
        
        //sound.play()

        
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 5) // wait for 5 seconds before notifying
        notification.alertBody = name + " is approaching"
        notification.alertAction = "Run away?" // Displayed as "Slide to..."
        //notification.soundName = UILocalNotificationDefaultSoundName
        //notification.userInfo = ["CustomField1": "Sara-Max"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
