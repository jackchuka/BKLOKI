//
//  SecondViewController.swift
//  BKLoki
//
//  Created by Masanori Uehara on 4/30/16.
//  Copyright © 2016 Masanori Uehara. All rights reserved.
//

import UIKit
import BluetoothKit

class ContactsViewController: UIViewController, UITableViewDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    private let central = BKCentral()
    var users = [String]()
    var images = [String]()
    var friends = [String]()
    var enemies = [String]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        self.tableView.registerNib(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "cell")
        if(defaults.objectForKey("namearray") == nil){
            users = ["Charlotte", "Billy", "Charlie", "Sammy"]
            defaults.setObject(users, forKey: "namearray")
        }
        if(defaults.objectForKey("imagearray") == nil){
            images = ["blah", "blah", "blah", "blah"]
            defaults.setObject(images, forKey: "imagearray")

        }
        if(defaults.objectForKey("enemy") == nil){
            enemies = ["Charlotte", "Charlie"]
            defaults.setObject(enemies, forKey: "enemy")
            
        }
        if(defaults.objectForKey("friend") == nil){
            friends = ["Billy", "Sammy"]
            defaults.setObject(friends, forKey: "friend")
            
        }
        users = defaults.objectForKey("namearray") as! [String]
        images = defaults.objectForKey("imagearray") as! [String]
        enemies = defaults.objectForKey("enemy") as! [String]
        friends = defaults.objectForKey("friend") as! [String]
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(section == 0){
            return friends.count
        }else{
            return enemies.count
        }
    }
    
    func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String {
        switch(section) {
        case 1:return "Enemies"
        default :return "Friends"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : ContactCell = tableView.dequeueReusableCellWithIdentifier("cell") as! ContactCell
        // Configure the cell...
        
        if(indexPath.section == 0){
            cell.name.text = friends[indexPath.row]
        }else{
            cell.name.text = enemies[indexPath.row]
        }
        return cell

        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }
    
}

