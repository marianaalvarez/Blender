//
//  ViewController.swift
//  Blender
//
//  Created by Mariana Alvarez on 30/06/15.
//  Copyright (c) 2015 Mariana Alvarez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate {
 
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var foregroundImage: UIImageView!
    @IBOutlet weak var blendButton: UIButton!
    @IBOutlet weak var backgroundLabel: UILabel!
    @IBOutlet weak var foregroundLabel: UILabel!
    let imagePicker = UIImagePickerController()
    var selectedImage: Int?
    var backgroundSet: Bool?
    var foregroundSet: Bool?
    
    @IBAction func addBackground(sender: AnyObject) {
        selectedImage = 1
        self.addImage()
    }
    @IBAction func addForeground(sender: AnyObject) {
        selectedImage = 2
        self.addImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        backgroundLabel.hidden = false
        foregroundLabel.hidden = false
        
        backgroundImage.image = UIImage(named: "photo")
        foregroundImage.image = UIImage(named: "photo")
        
        backgroundSet = false
        foregroundSet = false
        
        blendButton.layer.cornerRadius = 22
        blendButton.layer.borderColor = UIColor.whiteColor().CGColor
        blendButton.layer.borderWidth = 1
        
        blendButton.userInteractionEnabled = false
        blendButton.alpha = 0.5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addImage() {
        imagePicker.allowsEditing = false
        
        let alertController = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "Take a Photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .Camera
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let galleryAction = UIAlertAction(title: "Choose from Library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        alertController.view.tintColor = UIColor(red:1, green:0.41, blue:0.617, alpha:1)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if selectedImage == 1 {
                backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
                backgroundImage.clipsToBounds = true
                backgroundImage.image = pickedImage
                backgroundLabel.hidden = true
                backgroundSet = true
            } else {
                foregroundImage.contentMode = UIViewContentMode.ScaleAspectFill
                foregroundImage.clipsToBounds = true
                foregroundImage.image = pickedImage
                foregroundLabel.hidden = true
                foregroundSet = true
            }
            if (foregroundSet == true && backgroundSet == true) {
                blendButton.alpha = 1
                blendButton.userInteractionEnabled = true
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showEdit") {
            let destinationController = segue.destinationViewController as! EditViewController
            destinationController.image1 = backgroundImage.image!
            destinationController.image2 = foregroundImage.image!
        }
    }

}

