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

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BKRemotePeripheralDelegate, BKCentralDelegate, BKPeripheralDelegate {
    
    private let central = BKCentral()
    private let peripheral = BKPeripheral()
    private var discoveries = [BKDiscovery]()
    private var UUID = String()
    private var localName = String()
    
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
        scan()
    }
    
    internal override func viewWillDisappear(animated: Bool) {
        //central.interrupScan()
    }
    
    
    func scan() {
        
        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
            
            let indexPathsToRemove = changes.filter({ $0 == .Remove(discovery: nil) }).map({ NSIndexPath(forRow: self.discoveries.indexOf($0.discovery)!, inSection: 0) })
            let past = self.discoveries
            self.discoveries = discoveries
            let indexPathsToInsert = changes.filter({ $0 == .Insert(discovery: nil) }).map({ NSIndexPath(forRow: self.discoveries.indexOf($0.discovery)!, inSection: 0) })
            if !indexPathsToRemove.isEmpty {
                self.tableView.deleteRowsAtIndexPaths(indexPathsToRemove, withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            if !indexPathsToInsert.isEmpty {
                self.tableView.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            var incoming = [BKDiscovery]()
            var outgoing = [BKDiscovery]()
            for device in discoveries {
                if !past.contains(device) {
                    incoming.append(device)
                }
            }
            for device in past {
                if !discoveries.contains(device) {
                    outgoing.append(device)
                }
            }
            SettingsViewController().callNotification(incoming)
            SettingsViewController().callNotification(outgoing)
            
            }, stateHandler: { newState in
                if newState == .Scanning {
                    return
                } else if newState == .Stopped {
                    self.discoveries.removeAll()
                    self.tableView.reloadData()
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
            
            localName = UIDevice.currentDevice().name
            UUID = UIDevice.currentDevice().identifierForVendor!.UUIDString
            
            let configuration = BKPeripheralConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID: characteristicUUID, localName: localName)
            try peripheral.startWithConfiguration(configuration)
            // You are now ready for incoming connections
            
            print("Initialized peripheral")
            
        } catch let error {
            // Handle error.
            print("Peripheral init failed \(error)")
        }
    }
    
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveries.count + 1
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        }
        
        if (indexPath.row == discoveries.count) {
            cell.textLabel?.text = "MY UUID: \((UIDevice.currentDevice().identifierForVendor?.UUIDString)!)"
            cell.accessoryType = .None
            return cell
        }
        
        let discovery = discoveries[indexPath.row]

        cell.textLabel?.text = discovery.localName != nil ? discovery.localName : discovery.remotePeripheral.name
        cell.accessoryType = .None
        
        return cell
        
    }
    
    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row != discoveries.count) {
            central.connect(remotePeripheral: discoveries[indexPath.row].remotePeripheral) { remotePeripheral, error in
                print("remote: \(remotePeripheral.identifier)")
            }
            
            for remoteCentral in peripheral.connectedRemoteCentrals {
                let data = "Hello beloved central!".dataUsingEncoding(NSUTF8StringEncoding)
                print("Sending to \(remoteCentral)")
                peripheral.sendData(data!, toRemoteCentral: remoteCentral) { data, remoteCentral, error in
                    guard error == nil else {
                        print("Failed sending to \(remoteCentral)")
                        return
                    }
                    print("Sent to \(remoteCentral)")
                }
            }
            self.performSegueWithIdentifier("add", sender: self)
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
   
    
    // MARK: BKRemotePeripheralDelegate
    internal func remotePeripheral(remotePeripheral: BKRemotePeripheral, didUpdateName name: String) {
        print("Name change: \(name)")
    }
    
    internal func remotePeripheral(remotePeripheral: BKRemotePeripheral, didSendArbitraryData data: NSData) {
        print("Received data of length: \(data.length) with hash: \(data)")
    }
    

}

