//
//  EditViewController.swift
//  Blender
//
//  Created by Mariana Alvarez on 02/07/15.
//  Copyright (c) 2015 Mariana Alvarez. All rights reserved.
//

import UIKit
import CoreImage
import CoreGraphics
import Foundation


class EditViewController: UIViewController, UITabBarDelegate, UIScrollViewDelegate  {

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var whiteLayer: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var foregroundImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var foregroundButton: UIButton!
    @IBOutlet weak var sliderBlender: UISlider!
    @IBOutlet weak var sliderBrightness: UISlider!
    @IBOutlet weak var sliderContrast: UISlider!
    
    let panGesture = UIPanGestureRecognizer()
    let pinchGesture = UIPinchGestureRecognizer()
    let eraser = UIPanGestureRecognizer()
    var isBackgroundSelected: Bool?
    var isForegroundSelected: Bool?
    var image1: UIImage!
    var image2: UIImage!
    var context: CIContext!
    var brightness: CIFilter!
    var beginImage: CIImage!
    var contrastImage: CIImage!
    var brightnessImage: CIImage!
    var contrastValue: Float!
    var brightnessValue: Float!
    var blenderValue: Float!
    var orientation: UIImageOrientation = .Up
    var currentPoint: CGPoint?
    var lastPoint: CGPoint?
    var colorControls: CIFilter?
    var images = [NSDictionary]()
    var dictionary : [String: AnyObject]!
    
    @IBAction func backgroundSelected(sender: AnyObject) {
        if isBackgroundSelected == true {
            self.backgroundOn(false)
            self.foregroundOn(true)
        } else {
            self.backgroundOn(true)
            self.foregroundOn(false)
        }
    }
    
    @IBAction func foregorundSelected(sender: AnyObject) {
        if isForegroundSelected == true {
            self.backgroundOn(true)
            self.foregroundOn(false)
        } else {
            self.backgroundOn(false)
            self.foregroundOn(true)
        }
    }
    
    func backgroundOn(state: Bool) {
        if state == true {
            isBackgroundSelected = true
            backgroundButton.setImage(UIImage(named: "number1selected"), forState: .Normal)
        } else {
            isBackgroundSelected = false
            backgroundButton.setImage(UIImage(named: "number1"), forState: .Normal)
        }
    }
    
    func foregroundOn(state: Bool) {
        if state == true {
            isForegroundSelected = true
            foregroundButton.setImage(UIImage(named: "number2selected"), forState: .Normal)
        } else {
            isForegroundSelected = false
            foregroundButton.setImage(UIImage(named: "number2"), forState: .Normal)
        }
    }
    

    @IBAction func cancelButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func sliderBlenderAction(sender: UISlider) {
        blenderValue = sender.value
        foregroundImage.image = self.imageByApplyingAlpha(CGFloat(blenderValue))
        
    }
    
    @IBAction func slider(sender: UISlider) {
        if sender.tag == 1 {
            brightnessValue = sender.value
        } else {
            contrastValue = sender.value
        }
        
        var image = CIImage(CGImage: backgroundImage.image!.CGImage)
        if colorControls == nil {
            colorControls = CIFilter(name:"CIColorControls")
        }
        colorControls!.setValue(beginImage, forKey:kCIInputImageKey)
        colorControls!.setValue(contrastValue, forKey:"inputContrast")
        colorControls!.setValue(brightnessValue, forKey:"inputBrightness")
        
        
        let outputImage = colorControls!.outputImage
        
        let cgimg = context.createCGImage(outputImage, fromRect: outputImage.extent().standardizedRect)
        
        var originalOrientation = backgroundImage.image!.imageOrientation
        var  originalScale = backgroundImage.image!.scale
        let newImage = UIImage(CGImage: cgimg, scale:originalScale, orientation:originalOrientation)
        
        backgroundImage.image = newImage
        
    }
    
    @IBAction func stopEditing(sender: AnyObject) {
        println("\(images.count)")
        if (images.first == nil) {
            println("primeiro nulo")
        }
        if images.count == 10 {
            images.removeAtIndex(0)
            println("10")
        }
        var dictionary : [String: AnyObject] = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue, "brightnessValue" : brightnessValue, "contrastValue" : contrastValue]
        images.append(dictionary)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
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
        foregroundImage.image = self.imageByApplyingAlpha(0.5)
        
        scrollView.addSubview(whiteLayer)
        scrollView.addSubview(backgroundImage)
        scrollView.addSubview(foregroundImage)
        
        scrollView.contentSize = backgroundImage.image!.size
        scrollView.zoomScale = 1
        
        panGesture.addTarget(self, action: "draggedImage:")
        pinchGesture.addTarget(self, action: "pinchedImage:")
        eraser.addTarget(self, action: "eraseImage:")
        foregroundImage.multipleTouchEnabled = true
        
        beginImage = CIImage(CGImage: backgroundImage.image!.CGImage)
        contrastImage = CIImage(CGImage: backgroundImage.image!.CGImage)
        brightnessImage = CIImage(CGImage: backgroundImage.image!.CGImage)
        
        brightnessValue = 0
        contrastValue = 1
        blenderValue = 0.5
        
        dictionary = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue, "brightnessValue" : brightnessValue, "contrastValue" : contrastValue]
        images.append(dictionary)

        context = CIContext(options:nil)
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
            foregroundImage.addGestureRecognizer(panGesture)
            foregroundImage.addGestureRecognizer(pinchGesture)
        }
        if (item.tag == 1) {
            println("um")
            foregroundImage.gestureRecognizers?.removeAll(keepCapacity: false)
            foregroundImage.addGestureRecognizer(eraser)
        }
        if (item.tag == 2) {
            println("dois")
        }
        if (item.tag == 3) {
            println("tres")
            println("\(images.count)")
            if (images.first == nil) {
                println("primeiro nulo")
            }
            if images.count > 1 {
                var dictionary = images.removeLast()
                backgroundImage.image = dictionary.valueForKey("background") as? UIImage
                foregroundImage.image = dictionary.valueForKey("foreground") as? UIImage
                sliderBlender.setValue(dictionary.valueForKey("blenderValue") as! Float, animated: true)
                sliderBrightness.setValue(dictionary.valueForKey("brightnessValue") as! Float, animated: true)
                sliderContrast.setValue(dictionary.valueForKey("contrastValue") as! Float, animated: true)
            } else {
                var dictionary = images.last
                backgroundImage.image = dictionary!.valueForKey("background") as? UIImage
                foregroundImage.image = dictionary!.valueForKey("foreground") as? UIImage
                sliderBlender.setValue(dictionary!.valueForKey("blenderValue") as! Float, animated: true)
                sliderBrightness.setValue(dictionary!.valueForKey("brightnessValue") as! Float, animated: true)
                sliderContrast.setValue(dictionary!.valueForKey("contrastValue") as! Float, animated: true)
            }
        }
    }
    
    func eraseImage(sender: UIPanGestureRecognizer) {
        
        var location = sender.locationInView(foregroundImage)
        self.eraseImageAtPoint(location, imageView: foregroundImage, eraser: foregroundImage.image!)
    }
    
    func eraseImageAtPoint(point: CGPoint, imageView: UIImageView, eraser: UIImage) {
        
        if lastPoint == nil {
            lastPoint = point
        }
        
        currentPoint = point
        
        UIGraphicsBeginImageContext(imageView.frame.size)
        imageView.image!.drawInRect(CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height))
        
        CGContextSaveGState(UIGraphicsGetCurrentContext());
        CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), true);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 25.0);
        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, 0), 50, UIColor.whiteColor().CGColor);

        
        var path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, point.x, point.y);
        CGPathAddLineToPoint(path, nil, currentPoint!.x, currentPoint!.y);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
        CGContextAddPath(UIGraphicsGetCurrentContext(), path);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        
        //eraser.drawAtPoint(point, blendMode: kCGBlendModeDestinationOut, alpha: 0.5)
        imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        CGContextRestoreGState(UIGraphicsGetCurrentContext());
        UIGraphicsEndImageContext();
        
        lastPoint = currentPoint
    }

    
    func imageByApplyingAlpha(alpha:CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(foregroundImage.image!.size, false, foregroundImage.image!.scale)
        var ctx = UIGraphicsGetCurrentContext()
        var area = CGRectMake(0, 0, foregroundImage.image!.size.width, foregroundImage.image!.size.height)
    
        CGContextScaleCTM(ctx, 1, -1)
        CGContextTranslateCTM(ctx, 0, -area.size.height)
    
        CGContextSetBlendMode(ctx, kCGBlendModeMultiply)
    
        CGContextSetAlpha(ctx, alpha)
    
        CGContextDrawImage(ctx, area, foregroundImage.image!.CGImage)
    
        var outputImage = UIGraphicsGetImageFromCurrentImageContext()
        
        var originalOrientation = foregroundImage.image!.imageOrientation
        var  originalScale = foregroundImage.image!.scale
        var image = UIImage(CGImage: outputImage.CGImage, scale:originalScale, orientation:originalOrientation)
    
        
        UIGraphicsEndImageContext()
    
        return image!
    }

}
