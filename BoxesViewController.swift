//
//  BoxesViewController.swift
//  
//
//  Created by Sara Du on 4/30/16.
//
//

import UIKit

class BoxesVC: UICollectionViewController {
    let names = ["welcomebox.png", "generalbox.png", "weatherbox.png", "foodbox.png", "placesbox.png"]
    let seguenames = ["Welcome", "General", "Weather", "Food", "Places"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        WeatherMessageFactory.messageindex = 0
        PlacesMessageFactory.messageindex = 0
        FakeMessageFactory.messageindex = 0
        GeneralMessageFactory.messageindex = 0
        
        self.collectionView!.registerNib(UINib(nibName: "Box", bundle: nil), forCellWithReuseIdentifier: "cell")
        self.collectionView!.backgroundColor = UIColor.whiteColor()
        self.collectionView!.backgroundColor = UIColor(patternImage: UIImage(named:"clouds")!)
        /*
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.collectionView!.bounds
        collectionView!.addSubview(blurView)
        */
    }
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 5
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell : Box = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! Box
        
        // Configure the cell
        cell.appimage.image = UIImage(named: names[indexPath.row])
        return cell
        
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(seguenames[indexPath.row], sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var initialCount = 0
        let pageSize = 50
        
        var dataSource: FakeDataSource!
        if segue.identifier == "Places" {
            initialCount = 1
        }
        else if segue.identifier == "General"{
            initialCount = 1
        }
        else if segue.identifier == "Food" {
            initialCount = 1
        } else if segue.identifier == "Weather" {
            initialCount = 1
        } else if segue.identifier == "Welcome" {
            
        } else {
            assert(false, "segue not handled!")
        }
        
        if(segue.identifier == "Food"){
            let chatController = segue.destinationViewController as! DemoChatViewController
            if dataSource == nil {
                dataSource = FakeDataSource(count: initialCount, pageSize: pageSize, version: "Food")
            }
            chatController.dataSource = dataSource
            chatController.messageSender = dataSource.messageSender
        }else if(segue.identifier == "Weather"){
            let weatherVC = segue.destinationViewController as! WeatherChatVC
            if dataSource == nil {
                dataSource = FakeDataSource(count: initialCount, pageSize: pageSize, version: "Weather")
            }
            weatherVC.dataSource = dataSource
            weatherVC.messageSender = dataSource.messageSender
        }
        else if(segue.identifier == "Places"){
            let VC = segue.destinationViewController as! PlacesChatVC
            if dataSource == nil {
                dataSource = FakeDataSource(count: initialCount, pageSize: pageSize, version: "Places")
            }
            VC.dataSource = dataSource
            VC.messageSender = dataSource.messageSender
        }
        else if(segue.identifier == "General"){
            let VC = segue.destinationViewController as! GeneralChatVC
            if dataSource == nil {
                dataSource = FakeDataSource(count: initialCount, pageSize: pageSize, version: "General")
            }
            VC.dataSource = dataSource
            VC.messageSender = dataSource.messageSender
        }
        else if(segue.identifier == "Welcome"){
            let VC = segue.destinationViewController as! WelcomeVC
            if dataSource == nil {
                dataSource = FakeDataSource(messages: TutorialMessageFactory.createMessages().map { $0 }, pageSize: pageSize)
            }
            VC.dataSource = dataSource
            VC.messageSender = dataSource.messageSender
        }
        
        
    }
    
    
}

