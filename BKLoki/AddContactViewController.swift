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
    var newname: String!
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
        var namearray = defaults.objectForKey("namearray") as! [String]
        namearray.append(newname)
        var imagearray = defaults.objectForKey("imagearray") as! [String]
        namearray.append("")
        defaults.setObject(namearray, forKey: "namearray")
    }
   

}