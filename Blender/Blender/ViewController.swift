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
    let imagePicker = UIImagePickerController()
    
    @IBAction func addImage(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "Take a Photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            println("Take Photo")
        })
        let galleryAction = UIAlertAction(title: "Choose from Library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            println("Gallery")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        alertController.view.tintColor = UIColor(red:1, green:0.41, blue:0.617, alpha:1)
        
        presentViewController(alertController, animated: true, completion: nil)
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        //presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            backgroundImage.contentMode = .ScaleAspectFit
            backgroundImage.image = pickedImage
        }
        
//        UIImagePickerControllerMediaType
//        UIImagePickerControllerOriginalImage
//        UIImagePickerControllerEditedImage
//        UIImagePickerControllerCropRect
//        UIImagePickerControllerMediaURL
//        UIImagePickerControllerReferenceURL
//        UIImagePickerControllerMediaMetadata
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func willPresentActionSheet(actionSheet: UIActionSheet) {
        for subview in actionSheet.subviews {
            if (subview.isKindOfClass(UIButton)) {
                var button = subview as! UIButton
                button.setTitleColor(UIColor(red:1, green:0.41, blue:0.617, alpha:1), forState: .Normal)
            }
        }
    }

}

