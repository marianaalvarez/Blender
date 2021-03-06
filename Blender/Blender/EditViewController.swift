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

    @IBOutlet weak var greyView: UIView!
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
    var isBackgroundSelected: Bool?
    var image1: UIImage!
    var image2: UIImage!
    var context: CIContext!
    var brightness: CIFilter!
    var beginImageBackground: CIImage!
    var beginImageForeground: CIImage!
    var contrastValueB: Float!
    var contrastValueF: Float!
    var brightnessValueB: Float!
    var brightnessValueF: Float!
    var blenderValue: Float!
    var frameValueB: CGFloat!
    var frameXB: CGFloat!
    var frameYB: CGFloat!
    var frameWB: CGFloat!
    var frameHB: CGFloat!
    var frameXF: CGFloat!
    var frameYF: CGFloat!
    var frameWF: CGFloat!
    var frameHF: CGFloat!
    var orientation: UIImageOrientation = .Up
    var currentPoint: CGPoint?
    var lastPoint: CGPoint?
    var colorControls: CIFilter?
    var images = [NSDictionary]()
    var dictionary : [String: AnyObject]!
    var firstUndo : Bool?
    
    @IBAction func backgroundSelected(sender: AnyObject) {
        isBackgroundSelected = true
        backgroundButton.setImage(UIImage(named: "number1selected"), forState: .Normal)
        foregroundButton.setImage(UIImage(named: "number2"), forState: .Normal)
        sliderBrightness.setValue(brightnessValueB, animated: true)
        sliderContrast.setValue(contrastValueB, animated: true)
    }
    
    @IBAction func foregorundSelected(sender: AnyObject) {
        isBackgroundSelected = false
        backgroundButton.setImage(UIImage(named: "number1"), forState: .Normal)
        foregroundButton.setImage(UIImage(named: "number2selected"), forState: .Normal)
        sliderBrightness.setValue(brightnessValueF, animated: true)
        sliderContrast.setValue(contrastValueF, animated: true)
    }

    @IBAction func cancelButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveButton(sender: AnyObject) {
    
            UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, true, UIScreen.mainScreen().scale)
            let offset = scrollView.contentOffset
        
            CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -offset.x, -offset.y)
            scrollView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
            let image = UIGraphicsGetImageFromCurrentImageContext()
        
            UIGraphicsEndImageContext()
        
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        
            let alert = UIAlertController(title: "Success", message: "Your image has been saved to your camera roll!", preferredStyle: UIAlertControllerStyle.Alert)
        
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            alert.view.tintColor = UIColor(red:1, green:0.41, blue:0.617, alpha:1)
            self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func sliderBlenderAction(sender: UISlider) {
        blenderValue = sender.value
        foregroundImage.alpha = CGFloat(blenderValue)
        
    }
    
    @IBAction func slider(sender: UISlider) {

        if isBackgroundSelected == true {
            if sender.tag == 1 {
                brightnessValueB = sender.value
            } else {
                contrastValueB = sender.value
            }
            self.setFilter(backgroundImage, beginImage: beginImageBackground, contrastValue: contrastValueB, brightnessValue: brightnessValueB)
        } else {
            if sender.tag == 1 {
                brightnessValueF = sender.value
            } else {
                contrastValueF = sender.value
            }
            self.setFilter(foregroundImage, beginImage: beginImageForeground, contrastValue: contrastValueF, brightnessValue: brightnessValueF)
        }
    }
    
    @IBAction func stopEditing(sender: AnyObject) {
        if images.count == 15 {
            images.removeAtIndex(0)
        }
        let dictionary = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue, "brightnessValueB" : brightnessValueB, "contrastValueB" : contrastValueB, "brightnessValueF" : brightnessValueF, "contrastValueF" : contrastValueF, "frameXB" : frameXB, "frameYB" : frameYB,  "frameHB" : frameHB, "frameWB" : frameWB, "frameXF" : frameXF, "frameYF" : frameYF,  "frameHF" : frameHF, "frameWF" : frameWF]
        images.append(dictionary)
        firstUndo = true
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
        
        self.view.insertSubview(greyView, atIndex: 1)
        
        scrollView.addSubview(whiteLayer)
        scrollView.addSubview(backgroundImage)
        scrollView.addSubview(foregroundImage)
        
        scrollView.contentSize = backgroundImage.image!.size
        scrollView.zoomScale = 1
        
        panGesture.addTarget(self, action: "draggedImage:")
        pinchGesture.addTarget(self, action: "pinchedImage:")
        foregroundImage.multipleTouchEnabled = true
        
        beginImageBackground = CIImage(CGImage: backgroundImage.image!.CGImage!)
        beginImageForeground = CIImage(CGImage: foregroundImage.image!.CGImage!)
        
        brightnessValueB = 0
        brightnessValueF = 0
        contrastValueB = 1
        contrastValueF = 1
        blenderValue = 0.5
        
        blenderLabel.hidden = false
        brightnessLabel.hidden = false
        contrastLabel.hidden = false
        sliderBlender.hidden = false
        sliderBrightness.hidden = false
        sliderContrast.hidden = false
    
        firstUndo = true
        
        tabBar.selectedItem = self.tabBar.items![1]

        context = CIContext(options:nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        frameXB = backgroundImage.frame.origin.x
        frameYB = backgroundImage.frame.origin.y
        frameHB = backgroundImage.frame.height
        frameWB = backgroundImage.frame.width
        frameXF = foregroundImage.frame.origin.x
        frameYF = foregroundImage.frame.origin.y
        frameHF = foregroundImage.frame.height
        frameWF = foregroundImage.frame.width
        
        dictionary = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue, "brightnessValueB" : brightnessValueB, "contrastValueB" : contrastValueB, "brightnessValueF" : brightnessValueF, "contrastValueF" : contrastValueF, "frameXB" : frameXB, "frameYB" : frameYB,  "frameHB" : frameHB, "frameWB" : frameWB, "frameXF" : frameXF, "frameYF" : frameYF,  "frameHF" : frameHF, "frameWF" : frameWF]
        
        images.append(dictionary)
    }
    
    func draggedImage(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(self.view)
        if (isBackgroundSelected == true) {
            backgroundImage.center = CGPointMake(backgroundImage.center.x + translation.x, backgroundImage.center.y + translation.y)
            if sender.state == .Ended {
                frameXB = backgroundImage.frame.origin.x
                frameYB = backgroundImage.frame.origin.y
                frameHB = backgroundImage.frame.height
                frameWB = backgroundImage.frame.width
                
                dictionary = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue, "brightnessValueB" : brightnessValueB, "contrastValueB" : contrastValueB, "brightnessValueF" : brightnessValueF, "contrastValueF" : contrastValueF, "frameXB" : frameXB, "frameYB" : frameYB,  "frameHB" : frameHB, "frameWB" : frameWB, "frameXF" : frameXF, "frameYF" : frameYF,  "frameHF" : frameHF, "frameWF" : frameWF]
                images.append(dictionary)
            }
        } else {
            foregroundImage.center = CGPointMake(foregroundImage.center.x + translation.x, foregroundImage.center.y + translation.y)
            if sender.state == .Ended {
                frameXF = foregroundImage.frame.origin.x
                frameYF = foregroundImage.frame.origin.y
                frameHF = foregroundImage.frame.height
                frameWF = foregroundImage.frame.width
                
                dictionary = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue, "brightnessValueB" : brightnessValueB, "contrastValueB" : contrastValueB, "brightnessValueF" : brightnessValueF, "contrastValueF" : contrastValueF, "frameXB" : frameXB, "frameYB" : frameYB,  "frameHB" : frameHB, "frameWB" : frameWB, "frameXF" : frameXF, "frameYF" : frameYF,  "frameHF" : frameHF, "frameWF" : frameWF]
                images.append(dictionary)
            }
        }
        sender.setTranslation(CGPointZero, inView: self.view)
        firstUndo = true
        
    }
    
    func pinchedImage(sender: UIPinchGestureRecognizer){
        
        if (isBackgroundSelected == true) {
            backgroundImage.transform = CGAffineTransformScale(backgroundImage.transform, sender.scale, sender.scale)
            if sender.state == .Ended {
                frameXB = backgroundImage.frame.origin.x
                frameYB = backgroundImage.frame.origin.y
                frameHB = backgroundImage.frame.height
                frameWB = backgroundImage.frame.width
                
                dictionary = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue, "brightnessValueB" : brightnessValueB, "contrastValueB" : contrastValueB, "brightnessValueF" : brightnessValueF, "contrastValueF" : contrastValueF, "frameXB" : frameXB, "frameYB" : frameYB,  "frameHB" : frameHB, "frameWB" : frameWB, "frameXF" : frameXF, "frameYF" : frameYF,  "frameHF" : frameHF, "frameWF" : frameWF]
                images.append(dictionary)
            }
        } else {
            foregroundImage.transform = CGAffineTransformScale(foregroundImage.transform, sender.scale, sender.scale)
            if sender.state == .Ended {
                frameXF = foregroundImage.frame.origin.x
                frameYF = foregroundImage.frame.origin.y
                frameHF = foregroundImage.frame.height
                frameWF = foregroundImage.frame.width
                
                dictionary = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue, "brightnessValueB" : brightnessValueB, "contrastValueB" : contrastValueB, "brightnessValueF" : brightnessValueF, "contrastValueF" : contrastValueF, "frameXB" : frameXB, "frameYB" : frameYB,  "frameHB" : frameHB, "frameWB" : frameWB, "frameXF" : frameXF, "frameYF" : frameYF,  "frameHF" : frameHF, "frameWF" : frameWF]
                images.append(dictionary)
            }
        }
        sender.scale = 1.0
        firstUndo = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        switch (item.tag) {
        case 1:
            self.validateTag(1)
            foregroundImage.addGestureRecognizer(panGesture)
            foregroundImage.addGestureRecognizer(pinchGesture)
            break
        case 2:
            self.validateTag(2)
            blenderLabel.hidden = false
            brightnessLabel.hidden = false
            contrastLabel.hidden = false
            sliderBlender.hidden = false
            sliderBrightness.hidden = false
            sliderContrast.hidden = false
            greyView.hidden = false
            break
        case 3:
            self.validateTag(3)
            self.undoImage()
            break
        default:
            break
            
        }
        
    }

    func setFilter(imageView: UIImageView, beginImage: CIImage, contrastValue: Float, brightnessValue: Float) {
        _ = CIImage(CGImage: imageView.image!.CGImage!)
        if colorControls == nil {
            colorControls = CIFilter(name:"CIColorControls")
        }
        colorControls!.setValue(beginImage, forKey:kCIInputImageKey)
        colorControls!.setValue(contrastValue, forKey:"inputContrast")
        colorControls!.setValue(brightnessValue, forKey:"inputBrightness")
        
        
        let outputImage = colorControls!.outputImage
        
        let cgimg = context.createCGImage(outputImage!, fromRect: outputImage!.extent.standardized)
        
        let originalOrientation = imageView.image!.imageOrientation
        let  originalScale = imageView.image!.scale
        let newImage = UIImage(CGImage: cgimg, scale:originalScale, orientation:originalOrientation)
        
        imageView.image = newImage

    }
    
    func undoImage() {
        if firstUndo == true && images.count > 1 {
            images.removeLast()
        }
        var dictionary : NSDictionary!
        dictionary = images.removeLast()
        
        frameXB = dictionary.valueForKey("frameXB") as! CGFloat
        frameYB = dictionary.valueForKey("frameYB") as! CGFloat
        frameHB = dictionary.valueForKey("frameHB") as! CGFloat
        frameWB = dictionary.valueForKey("frameWB") as! CGFloat
        frameXF = dictionary.valueForKey("frameXF") as! CGFloat
        frameYF = dictionary.valueForKey("frameYF") as! CGFloat
        frameHF = dictionary.valueForKey("frameHF") as! CGFloat
        frameWF = dictionary.valueForKey("frameWF") as! CGFloat
        
        backgroundImage.frame = CGRectMake(frameXB, frameYB, frameWB, frameHB)
        foregroundImage.frame = CGRectMake(frameXF, frameYF, frameWF, frameHF)
        backgroundImage.image = dictionary.valueForKey("background") as? UIImage
        foregroundImage.image = dictionary.valueForKey("foreground") as? UIImage
        blenderValue = dictionary.valueForKey("blenderValue") as! Float
        foregroundImage.alpha = CGFloat(blenderValue)
        brightnessValueB = dictionary.valueForKey("brightnessValueB") as! Float
        brightnessValueF = dictionary.valueForKey("brightnessValueF") as! Float
        contrastValueB = dictionary.valueForKey("contrastValueB") as! Float
        contrastValueF = dictionary.valueForKey("contrastValueF") as! Float
        sliderBlender.setValue(blenderValue, animated: true)
        
        if (isBackgroundSelected == true) {
            sliderBrightness.setValue(brightnessValueB, animated: true)
            sliderContrast.setValue(contrastValueB, animated: true)
        } else {
            sliderBrightness.setValue(brightnessValueF, animated: true)
            sliderContrast.setValue(contrastValueF, animated: true)
        }
        if (images.isEmpty) {
            let newDictionary : [String: AnyObject] = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue, "brightnessValueB" : brightnessValueB, "contrastValueB" : contrastValueB, "brightnessValueF" : brightnessValueF, "contrastValueF" : contrastValueF, "frameXB" : frameXB, "frameYB" : frameYB,  "frameHB" : frameHB, "frameWB" : frameWB, "frameXF" : frameXF, "frameYF" : frameYF,  "frameHF" : frameHF, "frameWF" : frameWF]
            images.append(newDictionary)
        }
        firstUndo = false
    }
    
    func validateTag(tag: Int) {
        foregroundImage.gestureRecognizers?.removeAll(keepCapacity: false)
        if tag != 2 {
            greyView.hidden = true
            blenderLabel.hidden = true
            brightnessLabel.hidden = true
            contrastLabel.hidden = true
            sliderBlender.hidden = true
            sliderBrightness.hidden = true
            sliderContrast.hidden = true
        }
    }
    
    


}
