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

    @IBOutlet weak var blenderLabel: UILabel!
    @IBOutlet weak var brightnessLabel: UILabel!
    @IBOutlet weak var contrastLabel: UILabel!
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
    var imageViewSelected: UIImageView?
    var image1: UIImage!
    var image2: UIImage!
    var context: CIContext!
    var brightness: CIFilter!
    var beginImageBackground: CIImage!
    var beginImageForeground: CIImage!
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
        isBackgroundSelected = true
        backgroundButton.setImage(UIImage(named: "number1selected"), forState: .Normal)
        foregroundButton.setImage(UIImage(named: "number2"), forState: .Normal)
    }
    
    @IBAction func foregorundSelected(sender: AnyObject) {
        isBackgroundSelected = false
        backgroundButton.setImage(UIImage(named: "number1"), forState: .Normal)
        foregroundButton.setImage(UIImage(named: "number2selected"), forState: .Normal)
    }

    @IBAction func cancelButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveButton(sender: AnyObject) {

    }
    
    @IBAction func sliderBlenderAction(sender: UISlider) {
        blenderValue = sender.value
        foregroundImage.alpha = CGFloat(blenderValue)
        
    }
    
    @IBAction func slider(sender: UISlider) {
        
        if sender.tag == 1 {
            brightnessValue = sender.value
        } else {
            contrastValue = sender.value
        }
        if isBackgroundSelected == true {
            self.setFilter(backgroundImage, beginImage: beginImageBackground)
        } else {
            self.setFilter(foregroundImage, beginImage: beginImageForeground)
        }
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
        pinchGesture.addTarget(self, action: "pinchedImage:")
        eraser.addTarget(self, action: "eraseImage:")
        foregroundImage.multipleTouchEnabled = true
        
        beginImageBackground = CIImage(CGImage: backgroundImage.image!.CGImage)
        beginImageForeground = CIImage(CGImage: foregroundImage.image!.CGImage)
        
        brightnessValue = 0
        contrastValue = 1
        blenderValue = 0.5
        
        blenderLabel.hidden = true
        brightnessLabel.hidden = true
        contrastLabel.hidden = true
        sliderBlender.hidden = true
        sliderBrightness.hidden = true
        sliderContrast.hidden = true
        
        dictionary = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue, "brightnessValue" : brightnessValue, "contrastValue" : contrastValue]
        images.append(dictionary)

        context = CIContext(options:nil)
    }
    
    func draggedImage(sender: UIPanGestureRecognizer) {
        var translation = sender.translationInView(self.view)
        if (isBackgroundSelected == true) {
            backgroundImage.center = CGPointMake(backgroundImage.center.x + translation.x, backgroundImage.center.y + translation.y)
        } else {
            foregroundImage.center = CGPointMake(foregroundImage.center.x + translation.x, foregroundImage.center.y + translation.y)
        }
        sender.setTranslation(CGPointZero, inView: self.view)
    }
    
    func pinchedImage(sender: UIPinchGestureRecognizer){
        if (isBackgroundSelected == true) {
            backgroundImage.transform = CGAffineTransformScale(backgroundImage.transform, sender.scale, sender.scale)
        } else {
            foregroundImage.transform = CGAffineTransformScale(foregroundImage.transform, sender.scale, sender.scale)
        }
        sender.scale = 1.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        switch (item.tag) {
        case 0:
            self.validateTag(0)
            foregroundImage.addGestureRecognizer(panGesture)
            foregroundImage.addGestureRecognizer(pinchGesture)
            break
        case 1:
            self.validateTag(1)
            foregroundImage.addGestureRecognizer(eraser)
            break
        case 2:
            self.validateTag(2)
            blenderLabel.hidden = false
            brightnessLabel.hidden = false
            contrastLabel.hidden = false
            sliderBlender.hidden = false
            sliderBrightness.hidden = false
            sliderContrast.hidden = false
            break
        case 3:
            self.validateTag(3)
            self.undoImage()
            break
        default:
            break
            
        }
        
    }
    
    func eraseImage(sender: UIPanGestureRecognizer) {
        
        var location = sender.locationInView(foregroundImage)
        self.eraseImageAtPoint(location, imageView: foregroundImage, eraser: foregroundImage.image!)
    }
    
    func setFilter(imageView: UIImageView, beginImage: CIImage) {
        var image = CIImage(CGImage: imageView.image!.CGImage)
        if colorControls == nil {
            colorControls = CIFilter(name:"CIColorControls")
        }
        colorControls!.setValue(beginImage, forKey:kCIInputImageKey)
        colorControls!.setValue(contrastValue, forKey:"inputContrast")
        colorControls!.setValue(brightnessValue, forKey:"inputBrightness")
        
        
        let outputImage = colorControls!.outputImage
        
        let cgimg = context.createCGImage(outputImage, fromRect: outputImage.extent().standardizedRect)
        
        var originalOrientation = imageView.image!.imageOrientation
        var  originalScale = imageView.image!.scale
        let newImage = UIImage(CGImage: cgimg, scale:originalScale, orientation:originalOrientation)
        
        imageView.image = newImage

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
    
    func undoImage() {
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
            
        }
    }
    
    func validateTag(tag: Int) {
        foregroundImage.gestureRecognizers?.removeAll(keepCapacity: false)
        if tag != 2 && tag != 3 {
            blenderLabel.hidden = true
            brightnessLabel.hidden = true
            contrastLabel.hidden = true
            sliderBlender.hidden = true
            sliderBrightness.hidden = true
            sliderContrast.hidden = true
        }
    }
    
//    JUNTANDO DUAS IMAGENS
    
//    var back = backgroundImage.image
//    var fore = foregroundImage.image
//    
//    var newSize : CGSize = CGSizeMake(foregroundImage.frame.size.width, foregroundImage.frame.size.height)
//    UIGraphicsBeginImageContext( newSize )
//    
//    // Use existing opacity as is
//    back!.drawInRect(CGRectMake(0,0,newSize.width,newSize.height))
//    fore!.drawInRect(CGRectMake(0,0,newSize.width,newSize.height), blendMode:kCGBlendModeNormal, alpha:0.5)
//    
//    var newImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    foregroundImage.image = newImage

}
