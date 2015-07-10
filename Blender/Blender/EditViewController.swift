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
    var image1 : UIImage?
    var image2 : UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func cancelButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        imageView.userInteractionEnabled = true
        
        scrollView.addSubview(imageView)
        
        let image = image2
        
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        //imageView.frame = CGRectMake(0, 0, image!.size.width, image!.size.height)
        
        scrollView.contentSize = imageView.image!.size

        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleHeight, scaleWidth)

        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 10
        scrollView.zoomScale = 1

        centerScrollViewContents()
        
    }
    
    func centerScrollViewContents(){
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
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
        
        imageView.frame = contentsFrame
        
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
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
