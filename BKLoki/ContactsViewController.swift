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
    
    var enemyimages = ["enemy", "devil", "angry", "enemy4", "enemy5", "enemy6"]
    var friendimages = ["friend1", "friend2", "friend3", "friend4", "friend5", "friend6"]
    
    var friends = [String]()
    var enemies = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // uncomment to clear data for testing!!
        //self.clearDefaults()
        
        tableView.delegate = self
        self.tableView.registerNib(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.tableView.reloadData()
    }
    
    func clearDefaults() {
        let appDomain = NSBundle.mainBundle().bundleIdentifier!
        defaults.removePersistentDomainForName(appDomain)
    }
    
    override func viewDidAppear(animated: Bool) {
        enemies = (defaults.objectForKey("enemy") != nil) ? defaults.objectForKey("enemy") as! [String] : [String]()
        friends = (defaults.objectForKey("friend") != nil) ? defaults.objectForKey("friend") as! [String] : [String]()
        print("\(friends)")
        print("\(enemies)")
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        
        if(indexPath.section == 0){
            let rand = randRange(0, upper: friendimages.count-1)
            cell.name.text = friends[indexPath.row]
            cell.imageofcell?.image = UIImage(named: friendimages[rand])
            
            if(random() % 3 == 0){
                cell.descrip.text = "is approaching you."
            }else if(random() % 2 == 0){
                cell.descrip.text = "is leaving your range, say goodbye!"
            }else{
                cell.descrip.text = "is very close, how about you say hi"
            }
        }else{
            let rand = randRange(0, upper: enemyimages.count-1)
            cell.name.text = enemies[indexPath.row]
            cell.imageofcell.image = UIImage(named:enemyimages[rand])
            if(random() % 3 == 0){
                cell.descrip.text = "is approaching you; maybe you should run away"
            }else if(random() % 2 == 0){
                cell.descrip.text = "is leaving your range, you can calm down now"
            }else{
                cell.descrip.text = "is very close! Get away fast!"
            }
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

