//
//  FirstViewController.swift
//  BKLoki
//
//  Created by Masanori Uehara on 4/30/16.
//  Copyright © 2016 Masanori Uehara. All rights reserved.
//

import UIKit
import BluetoothKit

class FirstViewController: UIViewController {
    
    private let peripheral = BKPeripheral()
    private let central = BKCentral()
    
    let serviceUUID = NSUUID(UUIDString: "470275F0-EF0A-4A20-9CEF-D160A4C25BF9")!
    let characteristicUUID = NSUUID(UUIDString: "E9CF5BAD-8D47-4C2E-A3D6-620115807AAD")!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initPeripheral()
        self.initCentral()
        
    }
    
    func initCentral() {
        do {
            let configuration = BKConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID: characteristicUUID)
            try central.startWithConfiguration(configuration)
            // You are now ready to discover and connect to peripherals.
            
            print("test")
            
            central.scanWithDuration(3, progressHandler: { newDiscoveries in
                // Handle newDiscoveries, [BKDiscovery].
                for device in newDiscoveries {
                    print(device.localName)
                }
                }, completionHandler: { result, error in
                    print(error.debugDescription)
                    // Handle error.
                    // If no error, handle result, [BKDiscovery].
            })
            
        } catch let error {
            // Handle error.
            print("Central init failed")
        }
    }
    
    func initPeripheral() {
        do {
            let localName = "My Cool Peripheral"
            let configuration = BKPeripheralConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID:  characteristicUUID, localName: localName)
            try peripheral.startWithConfiguration(configuration)
            // You are now ready for incoming connections
            
        } catch let error {
            // Handle error.
            print("Peripheral init failed")
        }
    }
    
    @IBAction func btnSendPressed(sender: AnyObject) {
        let data = "Hello beloved central!".dataUsingEncoding(NSUTF8StringEncoding)
        print(peripheral.connectedRemoteCentrals.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

