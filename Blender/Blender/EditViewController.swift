//
//  EditViewController.swift
//  Blender
//
//  Created by Mariana Alvarez on 02/07/15.
//  Copyright (c) 2015 Mariana Alvarez. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UITabBarDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var whiteLayer: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var foregroundImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var foregroundButton: UIButton!
    let panGesture = UIPanGestureRecognizer()
    let pinchGesture = UIPinchGestureRecognizer()
    var isBackgroundSelected : Bool?
    var isForegroundSelected : Bool?
    var image1 : UIImage?
    var image2 : UIImage?
    
    @IBAction func backgroundSelected(sender: AnyObject) {
        if isBackgroundSelected == true {
            isBackgroundSelected = false
            //backgroundImage.userInteractionEnabled = false
            backgroundButton.setImage(UIImage(named: "number1"), forState: .Normal)
        } else {
            isBackgroundSelected = true
            //backgroundImage.userInteractionEnabled = true
            backgroundButton.setImage(UIImage(named: "number1selected"), forState: .Normal)
        }
    }
    
    @IBAction func foregorundSelected(sender: AnyObject) {
        if isForegroundSelected == true {
            isForegroundSelected = false
            //foregroundImage.userInteractionEnabled = false
            foregroundButton.setImage(UIImage(named: "number2"), forState: .Normal)
        } else {
            isForegroundSelected = true
            //foregroundImage.userInteractionEnabled = true
            foregroundButton.setImage(UIImage(named: "number2selected"), forState: .Normal)
        }
    }

    @IBAction func cancelButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        isBackgroundSelected = true
        isForegroundSelected = false
        
        backgroundButton.setImage(UIImage(named: "number1selected"), forState: .Normal)
        foregroundButton.setImage(UIImage(named: "number2"), forState: .Normal)
        backgroundImage.userInteractionEnabled = true
        foregroundImage.userInteractionEnabled = true
        whiteLayer.contentMode = .ScaleAspectFill
        backgroundImage.contentMode = .ScaleAspectFill
        foregroundImage.contentMode = .ScaleAspectFill
        
        backgroundImage.image = image1
        foregroundImage.image = image2
        foregroundImage.alpha = 0.5
        
        scrollView.addSubview(whiteLayer)
        scrollView.addSubview(backgroundImage)
        scrollView.addSubview(foregroundImage)
        
        scrollView.contentSize = backgroundImage.image!.size
        scrollView.zoomScale = 1
        
        panGesture.addTarget(self, action: "draggedImage:")
        foregroundImage.addGestureRecognizer(panGesture)
        
        pinchGesture.addTarget(self, action: "pinchedImage:")
        foregroundImage.addGestureRecognizer(pinchGesture)
        foregroundImage.multipleTouchEnabled = true
        
    }
    
    func draggedImage(sender: UIPanGestureRecognizer) {
        var translation = sender.translationInView(self.view)
        if (isBackgroundSelected == true) {
            backgroundImage.center = CGPointMake(backgroundImage.center.x + translation.x, backgroundImage.center.y + translation.y)
        }
        if (isForegroundSelected == true) {
            foregroundImage.center = CGPointMake(foregroundImage.center.x + translation.x, foregroundImage.center.y + translation.y)
        }
        sender.setTranslation(CGPointZero, inView: self.view)
    }
    
    func pinchedImage(sender: UIPinchGestureRecognizer){
        if (isBackgroundSelected == true) {
            backgroundImage.transform = CGAffineTransformScale(backgroundImage.transform, sender.scale, sender.scale)
        }
        if (isForegroundSelected == true) {
            foregroundImage.transform = CGAffineTransformScale(foregroundImage.transform, sender.scale, sender.scale)
        }
        sender.scale = 1.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        if (item.tag == 0) {
            println("zero")
        }
        if (item.tag == 1) {
            println("um")
        }
        if (item.tag == 2) {
            println("dois")
        }
    }
    
}
