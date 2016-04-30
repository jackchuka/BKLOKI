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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let peripheral = BKPeripheral()
//        
//        do {
//            let serviceUUID = NSUUID(UUIDString: "470275F0-EF0A-4A20-9CEF-D160A4C25BF9")!
//            let characteristicUUID = NSUUID(UUIDString: "E9CF5BAD-8D47-4C2E-A3D6-620115807AAD")!
//            let localName = "My Cool Peripheral"
//            let configuration = BKPeripheralConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID:  characteristicUUID, localName: localName)
//            try peripheral.startWithConfiguration(configuration)
//            // You are now ready for incoming connections
//            
//            
//            
//        } catch let error {
//            // Handle error.
//        }
        
    }
    
    @IBAction func btnSendPressed(sender: AnyObject) {
        let data = "Hello beloved central!".dataUsingEncoding(NSUTF8StringEncoding)
        let remoteCentral = peripheral.connectedRemoteCentrals.first! // Don't do this in the real world :]
        peripheral.sendData(data!, toRemoteCentral: remoteCentral) { data, remoteCentral, error in
            // Handle error.
            // If no error, the data was all sent!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

