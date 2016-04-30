//
//  AddContactViewController.swift
//  BKLoki
//
//  Created by Sara Du on 4/30/16.
//  Copyright © 2016 Masanori Uehara. All rights reserved.
//

import UIKit

class AddContactViewController: UIViewController, UITextFieldDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var textField: TitledTextField!
    @IBOutlet weak var friendorenemy: TitledTextField!
    
    var newname: String!
    var friend: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        newname = textField.text
        
        //corresponding names to UUIDs
        if(defaults.objectForKey("correspondingNames") == nil){
            defaults.setObject([newname], forKey: "correspondingNames")
        }else{
            var arr = defaults.arrayForKey("correspondingNames")
            arr?.append(newname)
            defaults.setObject(arr, forKey: "correspondingNames")
        }
        
        //friend or enemy
        friend = friendorenemy.text
        if(friend.lowercaseString == "friend"){
            if defaults.objectForKey("friend") != nil{
                var booleanarray = defaults.objectForKey("friend") as! [String]
                booleanarray.append(newname)
                defaults.setObject(booleanarray, forKey: "friend")
            }else{
                defaults.setObject([newname], forKey: "friend")
            }
        }else{
            if(defaults.objectForKey("enemy") != nil){
                var booleanarray = defaults.objectForKey("enemy") as! [String]
                booleanarray.append(newname)
                defaults.setObject(booleanarray, forKey: "enemy")
            }
            else{
                defaults.setObject([newname], forKey: "enemy")
            }
        }
        
        
        var namearray = defaults.objectForKey("namearray") as! [String]
        namearray.append(newname)
        defaults.setObject(namearray, forKey: "namearray")
        
    }
   

}
