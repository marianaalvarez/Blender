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
    var image1 : UIImage?
    var image2 : UIImage?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func cancelButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
        scrollView.delegate = self
        backgroundImage.image = image1
        foregroundImage.image = image2
        foregroundImage.alpha = 0.5
        scrollView.bounds = foregroundImage.bounds
        scrollView.addSubview(foregroundImage)
        scrollView.contentSize = foregroundImage.bounds.size
        scrollView.maximumZoomScale = 10
        scrollView.minimumZoomScale = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return foregroundImage
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
        
    }
}
