//
//  BoxesViewController.swift
//  
//
//  Created by Sara Du on 4/30/16.
//
//

import UIKit

class BoxesViewController: UICollectionViewController {
    let imagenames = ["emotionicon", "moxtraicon"]
    let seguenames = ["camera", "moxtra"]
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.collectionView!.registerNib(UINib(nibName: "Box", bundle: nil), forCellWithReuseIdentifier: "cell")
        self.collectionView!.backgroundColor = UIColor.whiteColor()
        //self.collectionView!.backgroundColor = UIColor(patternImage: UIImage(named:"clouds")!)
        
  
        
    }
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 2
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell : Box = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! Box
        
        // Configure the cell
        cell.appimage.image = UIImage(named: imagenames[indexPath.row])
        return cell
        
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(seguenames[indexPath.row], sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
    }
    
    
}

