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
    
    var enemyimages = ["enemy", "devil", "angry", "enemy4", "enemy5", "enemy6"]
    var friendimages = ["friend1", "friend2", "friend3", "friend4", "friend5", "friend6"]
    
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
        if(defaults.objectForKey("enemy") == nil){
            enemies = ["Charlotte", "Charlie"]
            defaults.setObject(enemies, forKey: "enemy")
            
        }
        if(defaults.objectForKey("friend") == nil){
            friends = ["Billy", "Sammy"]
            defaults.setObject(friends, forKey: "friend")
            
        }
        users = defaults.objectForKey("namearray") as! [String]
        enemies = defaults.objectForKey("enemy") as! [String]
        friends = defaults.objectForKey("friend") as! [String]
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
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
    
    func randRange (lower: Int , upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : ContactCell = tableView.dequeueReusableCellWithIdentifier("cell") as! ContactCell
        // Configure the cell...
        
        
        if(indexPath.section == 0){
            let rand = randRange(0, upper: friendimages.count-1)
            cell.name.text = friends[indexPath.row]
            cell.imageofcell?.image = UIImage(named: friendimages[rand])
        }else{
            let rand = randRange(0, upper: enemyimages.count-1)
            cell.name.text = enemies[indexPath.row]
            cell.imageofcell.image = UIImage(named:enemyimages[rand])
        }
        return cell
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if(indexPath.section == 0){
                friends.removeAtIndex(indexPath.row)
                var x = defaults.arrayForKey("friend")
                x?.removeAtIndex(indexPath.row)
                defaults.setObject(x, forKey: "friend")

                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }else{
                enemies.removeAtIndex(indexPath.row)
                var x = defaults.arrayForKey("enemy")
                x?.removeAtIndex(indexPath.row)
                defaults.setObject(x, forKey: "enemy")
                
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
}

