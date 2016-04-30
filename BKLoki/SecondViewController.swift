//
//  SecondViewController.swift
//  BKLoki
//
//  Created by Masanori Uehara on 4/30/16.
//  Copyright © 2016 Masanori Uehara. All rights reserved.
//

import UIKit
import BluetoothKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let central = BKCentral()
        do {
            let serviceUUID = NSUUID(UUIDString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")!
            let characteristicUUID = NSUUID(UUIDString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")!
            let configuration = BKConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID: characteristicUUID)
            try central.startWithConfiguration(configuration)
            // You are now ready to discover and connect to peripherals.
            
            print("test")
            
            central.scanContinuouslyWithChangeHandler({ changes, discoveries in
                print("available")
                }, stateHandler: { newState in
                    // Handle newState, BKCentral.ContinuousScanState.
                    // This is where you'd ie. start/stop an activity indicator.
                }, duration: 3, inBetweenDelay: 3, errorHandler: { error in
                    // Handle error.
            })
            
        } catch let error {
            // Handle error.
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

