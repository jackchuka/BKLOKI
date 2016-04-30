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

class SettingsViewController: UIViewController,BKCentralDelegate, BKPeripheralDelegate  {
    private let central = BKCentral()
    private let peripheral = BKPeripheral()
    private var discoveries = [BKDiscovery]()
    private var localName = String!()
    var sound = AVAudioPlayer()

    
    let defaults = NSUserDefaults.standardUserDefaults()
    let serviceUUID = NSUUID(UUIDString: "470275F0-EF0A-4A20-9CEF-D160A4C25BF9")!
    let characteristicUUID = NSUUID(UUIDString: "E9CF5BAD-8D47-4C2E-A3D6-620115807AAD")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let path = NSBundle.mainBundle().pathForResource("answercellphone.wav", ofType:nil)!
        //let url = NSURL(fileURLWithPath: path)
        /*
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
                if(self.defaults.objectForKey("correspondingname") != nil){
                let devicenamearray = self.defaults.objectForKey("correspondingname") as! [String]
                print(devicenamearray)
                let x = devicenamearray.count
                for i in 0...x-1{
                   // if(UUIDarray[i] == device.remotePeripheral.identifier.UUIDString){
                        let name = self.defaults.objectForKey("correspondingname") as! [String]
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
        
        sound.play()

        
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 1) // wait for 5 seconds before notifying
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

}
