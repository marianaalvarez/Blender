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
    
    @IBAction func addBackground(_ sender: AnyObject) {
        selectedImage = 1
        self.addImage()
    }
    @IBAction func addForeground(_ sender: AnyObject) {
        selectedImage = 2
        self.addImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        backgroundLabel.isHidden = false
        foregroundLabel.isHidden = false
        
        backgroundImage.image = UIImage(named: "photo")
        foregroundImage.image = UIImage(named: "photo")
        
        backgroundSet = false
        foregroundSet = false
        
        blendButton.layer.cornerRadius = 22
        blendButton.layer.borderColor = UIColor.white.cgColor
        blendButton.layer.borderWidth = 1
        
        blendButton.isUserInteractionEnabled = false
        blendButton.alpha = 0.5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addImage() {
        imagePicker.allowsEditing = false
        
        let alertController = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Take a Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let galleryAction = UIAlertAction(title: "Choose from Library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        alertController.view.tintColor = UIColor(red:1, green:0.41, blue:0.617, alpha:1)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if selectedImage == 1 {
                backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
                backgroundImage.clipsToBounds = true
                backgroundImage.image = pickedImage
                backgroundLabel.isHidden = true
                backgroundSet = true
            } else {
                foregroundImage.contentMode = UIViewContentMode.scaleAspectFill
                foregroundImage.clipsToBounds = true
                foregroundImage.image = pickedImage
                foregroundLabel.isHidden = true
                foregroundSet = true
            }
            if (foregroundSet == true && backgroundSet == true) {
                blendButton.alpha = 1
                blendButton.isUserInteractionEnabled = true
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showEdit") {
            let destinationController = segue.destination as! EditViewController
            destinationController.image1 = backgroundImage.image!
            destinationController.image2 = foregroundImage.image!
        }
    }

}

