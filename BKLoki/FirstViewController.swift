//
//  FirstViewController.swift
//  BKLoki
//
//  Created by Masanori Uehara on 4/30/16.
//  Copyright © 2016 Masanori Uehara. All rights reserved.
//

import UIKit
import BluetoothKit
import CoreBluetooth

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BKCentralDelegate, BKPeripheralDelegate {
    
    private let central = BKCentral()
    private let peripheral = BKPeripheral()
    private var discoveries = [BKDiscovery]()
    
    
    @IBOutlet weak var tableView: UITableView!
    let defaults = NSUserDefaults.standardUserDefaults()
    let serviceUUID = NSUUID(UUIDString: "470275F0-EF0A-4A20-9CEF-D160A4C25BF9")!
    let characteristicUUID = NSUUID(UUIDString: "E9CF5BAD-8D47-4C2E-A3D6-620115807AAD")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initCentral()
        self.initPeripheral()
        tableView.delegate = self
    }
    
    internal override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("appear")
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
            for device in discoveries {
                print(device.localName)
            }
            let indexPathsToRemove = changes.filter({ $0 == .Remove(discovery: nil) }).map({ NSIndexPath(forRow: self.discoveries.indexOf($0.discovery)!, inSection: 0) })
            self.discoveries = discoveries
            let indexPathsToInsert = changes.filter({ $0 == .Insert(discovery: nil) }).map({ NSIndexPath(forRow: self.discoveries.indexOf($0.discovery)!, inSection: 0) })
            if !indexPathsToRemove.isEmpty {
                self.tableView.deleteRowsAtIndexPaths(indexPathsToRemove, withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            if !indexPathsToInsert.isEmpty {
                self.tableView.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: UITableViewRowAnimation.Automatic)
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
            
            
            let localName = UIDevice.currentDevice().identifierForVendor?.UUIDString

//            var arrayofUUID = defaults.objectForKey("arrayofUUID") as! [String]
//            arrayofUUID.append(localName!)
//            defaults.setObject(arrayofUUID, forKey: "arrayofUUID")
            //
            
            
            let configuration = BKPeripheralConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID:  characteristicUUID, localName: localName)
            try peripheral.startWithConfiguration(configuration)
            // You are now ready for incoming connections
            
            print("Initialized peripheral")
            
        } catch let error {
            // Handle error.
            print("Peripheral init failed \(error)")
        }
    }
    
    
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveries.count
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        }
        let discovery = discoveries[indexPath.row]

        cell.textLabel?.text = discovery.localName != nil ? discovery.localName : discovery.remotePeripheral.name
       // cell.accessoryType = .None
        
        
        
        return cell
        
    }
    
    
    @IBAction func btnSendPressed(sender: AnyObject) {
        let data = "Hello beloved central!".dataUsingEncoding(NSUTF8StringEncoding)
        print("discovered devices: \(discoveries.count)")
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

