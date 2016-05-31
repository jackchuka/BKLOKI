//
//  PhotosViewController.swift
//  BKLoki
//
//  Created by Sara Du on 4/30/16.
//  Copyright © 2016 Masanori Uehara. All rights reserved.
//

import UIKit
import AVFoundation

class PhotosViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate {
    var player : AVAudioPlayer! = nil // will be Optional, must supply initializer

    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    @IBAction func takePicture(sender: UIButton) {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .Camera
                imagePicker.cameraCaptureMode = .Photo
                presentViewController(imagePicker, animated: true, completion: {})
            } else {
                print("Application cannot access the camera.")
            }
        } else {
            print("Camera inaccessable")
        }
        
        /*
        let params = [
            "func" : "timelineid",
            "timeline_id" : self.timeline_id
        ];
        
        Alamofire.request(.GET, url, parameters: params, encoding: ParameterEncoding.URL).responseJSON { (_, _, result) in
            switch result {
            case .Success(let data):
                self.json = JSON(data)
                
                self.displayDetails()
                
            case .Failure(_, let error):
                print("Request failed with error: \(error)")
            }
        }
*/

    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("Got an image")
        if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
            let selectorToCall = Selector("imageWasSavedSuccessfully:didFinishSavingWithError:context:")
            UIImageWriteToSavedPhotosAlbum(pickedImage, self, selectorToCall, nil)
        }
        imagePicker.dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user saves an image
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("User canceled image")
        dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user selects cancel
        })
    }
    @IBAction func testsound(sender: AnyObject) {
            let path = NSBundle.mainBundle().pathForResource("answercellphone", ofType:"wav")
            let fileURL = NSURL(fileURLWithPath: path!)
        do {
            try player = AVAudioPlayer(contentsOfURL: fileURL, fileTypeHint: nil)
        } catch {
            print("Error")
        }

            player.prepareToPlay()
            player.delegate = self
            player.play()
    }
}
