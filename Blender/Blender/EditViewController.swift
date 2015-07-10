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
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var foregroundImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var foregroundButton: UIButton!
    var isBackgroundSelected : Bool?
    var isForegroundSelected : Bool?
    var image1 : UIImage?
    var image2 : UIImage?
    
    @IBAction func backgroundSelected(sender: AnyObject) {
        if isBackgroundSelected == true {
            isBackgroundSelected = false
            backgroundImage.userInteractionEnabled = false
            backgroundButton.setImage(UIImage(named: "number1"), forState: .Normal)
        } else {
            isBackgroundSelected = true
            backgroundImage.userInteractionEnabled = true
            backgroundButton.setImage(UIImage(named: "number1selected"), forState: .Normal)
        }
    }
    
    @IBAction func foregorundSelected(sender: AnyObject) {
        if isForegroundSelected == true {
            isForegroundSelected = false
            foregroundImage.userInteractionEnabled = false
            foregroundButton.setImage(UIImage(named: "number2"), forState: .Normal)
        } else {
            isForegroundSelected = true
            foregroundImage.userInteractionEnabled = true
            foregroundButton.setImage(UIImage(named: "number2selected"), forState: .Normal)
        }
    }

    @IBAction func cancelButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isBackgroundSelected = true
        isForegroundSelected = false
        backgroundButton.setImage(UIImage(named: "number1selected"), forState: .Normal)
        foregroundButton.setImage(UIImage(named: "number2"), forState: .Normal)
        
        scrollView.delegate = self
        
        backgroundImage.userInteractionEnabled = true
        foregroundImage.userInteractionEnabled = false
        
        scrollView.addSubview(backgroundImage)
        
        let image = image1
        
        backgroundImage.image = image
        
        scrollView.contentSize = backgroundImage.image!.size

        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 10
        scrollView.zoomScale = 1

        centerScrollViewContents()
        
    }
    
    func centerScrollViewContents(){
        let boundsSize = scrollView.bounds.size
        
        if isBackgroundSelected == true {
            var contentsFrame = backgroundImage.frame
        
            if contentsFrame.size.width < boundsSize.width{
                contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
            }else{
                contentsFrame.origin.x = 0
            }
        
            if contentsFrame.size.height < boundsSize.height {
            
                contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
            }else{
                contentsFrame.origin.y = 0
            }
        
            backgroundImage.frame = contentsFrame
        }
        
        if isForegroundSelected == true {
            var contentsFrame = foregroundImage.frame
            
            if contentsFrame.size.width < boundsSize.width{
                contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
            }else{
                contentsFrame.origin.x = 0
            }
            
            if contentsFrame.size.height < boundsSize.height {
                
                contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
            }else{
                contentsFrame.origin.y = 0
            }
            
            foregroundImage.frame = contentsFrame
        }
        
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        if (isBackgroundSelected == true) {
            return backgroundImage
        }
        if (isForegroundSelected == true) {
            return foregroundImage
        }
        return nil
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
