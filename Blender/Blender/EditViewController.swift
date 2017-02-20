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
    var orientation: UIImageOrientation = .up
    var currentPoint: CGPoint?
    var lastPoint: CGPoint?
    var colorControls: CIFilter?
    var images = [NSDictionary]()
    var dictionary : [String: AnyObject]!
    var firstUndo : Bool?
    
    @IBAction func backgroundSelected(_ sender: AnyObject) {
        isBackgroundSelected = true
        backgroundButton.setImage(UIImage(named: "number1selected"), for: UIControlState())
        foregroundButton.setImage(UIImage(named: "number2"), for: UIControlState())
        sliderBrightness.setValue(brightnessValueB, animated: true)
        sliderContrast.setValue(contrastValueB, animated: true)
    }
    
    @IBAction func foregorundSelected(_ sender: AnyObject) {
        isBackgroundSelected = false
        backgroundButton.setImage(UIImage(named: "number1"), for: UIControlState())
        foregroundButton.setImage(UIImage(named: "number2selected"), for: UIControlState())
        sliderBrightness.setValue(brightnessValueF, animated: true)
        sliderContrast.setValue(contrastValueF, animated: true)
    }

    @IBAction func cancelButton(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButton(_ sender: AnyObject) {
    
            UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, true, UIScreen.main.scale)
            let offset = scrollView.contentOffset
        
            UIGraphicsGetCurrentContext()?.translateBy(x: -offset.x, y: -offset.y)
            scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
            let image = UIGraphicsGetImageFromCurrentImageContext()
        
            UIGraphicsEndImageContext()
        
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
        
            let alert = UIAlertController(title: "Success", message: "Your image has been saved to your camera roll!", preferredStyle: UIAlertControllerStyle.alert)
        
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            alert.view.tintColor = UIColor(red:1, green:0.41, blue:0.617, alpha:1)
            self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func sliderBlenderAction(_ sender: UISlider) {
        blenderValue = sender.value
        foregroundImage.alpha = CGFloat(blenderValue)
        
    }
    
    @IBAction func slider(_ sender: UISlider) {

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
    
    @IBAction func stopEditing(_ sender: AnyObject) {
        if images.count == 15 {
            images.remove(at: 0)
        }
        let dictionary = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue, "brightnessValueB" : brightnessValueB, "contrastValueB" : contrastValueB, "brightnessValueF" : brightnessValueF, "contrastValueF" : contrastValueF, "frameXB" : frameXB, "frameYB" : frameYB,  "frameHB" : frameHB, "frameWB" : frameWB, "frameXF" : frameXF, "frameYF" : frameYF,  "frameHF" : frameHF, "frameWF" : frameWF] as [String : Any]
        images.append(dictionary as NSDictionary)
        firstUndo = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
        scrollView.delegate = self
        
        isBackgroundSelected = true
        
        backgroundButton.setImage(UIImage(named: "number1selected"), for: UIControlState())
        foregroundButton.setImage(UIImage(named: "number2"), for: UIControlState())
        backgroundImage.isUserInteractionEnabled = true
        foregroundImage.isUserInteractionEnabled = true
        whiteLayer.contentMode = .scaleAspectFill
        backgroundImage.contentMode = .scaleAspectFill
        foregroundImage.contentMode = .scaleAspectFill
        
        backgroundImage.image = image1
        foregroundImage.image = image2
        foregroundImage.alpha = 0.5
        
        self.view.insertSubview(greyView, at: 1)
        
        scrollView.addSubview(whiteLayer)
        scrollView.addSubview(backgroundImage)
        scrollView.addSubview(foregroundImage)
        
        scrollView.contentSize = backgroundImage.image!.size
        scrollView.zoomScale = 1
        
        panGesture.addTarget(self, action: #selector(EditViewController.draggedImage(_:)))
        pinchGesture.addTarget(self, action: #selector(EditViewController.pinchedImage(_:)))
        foregroundImage.isMultipleTouchEnabled = true
        
        beginImageBackground = CIImage(cgImage: backgroundImage.image!.cgImage!)
        beginImageForeground = CIImage(cgImage: foregroundImage.image!.cgImage!)
        
        brightnessValueB = 0
        brightnessValueF = 0
        contrastValueB = 1
        contrastValueF = 1
        blenderValue = 0.5
        
        blenderLabel.isHidden = false
        brightnessLabel.isHidden = false
        contrastLabel.isHidden = false
        sliderBlender.isHidden = false
        sliderBrightness.isHidden = false
        sliderContrast.isHidden = false
    
        firstUndo = true
        
        tabBar.selectedItem = self.tabBar.items![1]

        context = CIContext(options:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        frameXB = backgroundImage.frame.origin.x
        frameYB = backgroundImage.frame.origin.y
        frameHB = backgroundImage.frame.height
        frameWB = backgroundImage.frame.width
        frameXF = foregroundImage.frame.origin.x
        frameYF = foregroundImage.frame.origin.y
        frameHF = foregroundImage.frame.height
        frameWF = foregroundImage.frame.width
        
        dictionary = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue as AnyObject, "brightnessValueB" : brightnessValueB as AnyObject, "contrastValueB" : contrastValueB as AnyObject, "brightnessValueF" : brightnessValueF as AnyObject, "contrastValueF" : contrastValueF as AnyObject, "frameXB" : frameXB as AnyObject, "frameYB" : frameYB as AnyObject,  "frameHB" : frameHB, "frameWB" : frameWB, "frameXF" : frameXF, "frameYF" : frameYF,  "frameHF" : frameHF, "frameWF" : frameWF]
        
        images.append(dictionary as NSDictionary)
    }
    
    func draggedImage(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        if (isBackgroundSelected == true) {
            backgroundImage.center = CGPoint(x: backgroundImage.center.x + translation.x, y: backgroundImage.center.y + translation.y)
            if sender.state == .ended {
                frameXB = backgroundImage.frame.origin.x
                frameYB = backgroundImage.frame.origin.y
                frameHB = backgroundImage.frame.height
                frameWB = backgroundImage.frame.width
                
                dictionary = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue as AnyObject, "brightnessValueB" : brightnessValueB as AnyObject, "contrastValueB" : contrastValueB as AnyObject, "brightnessValueF" : brightnessValueF as AnyObject, "contrastValueF" : contrastValueF as AnyObject, "frameXB" : frameXB as AnyObject, "frameYB" : frameYB as AnyObject,  "frameHB" : frameHB, "frameWB" : frameWB, "frameXF" : frameXF, "frameYF" : frameYF,  "frameHF" : frameHF, "frameWF" : frameWF]
                images.append(dictionary as NSDictionary)
            }
        } else {
            foregroundImage.center = CGPoint(x: foregroundImage.center.x + translation.x, y: foregroundImage.center.y + translation.y)
            if sender.state == .ended {
                frameXF = foregroundImage.frame.origin.x
                frameYF = foregroundImage.frame.origin.y
                frameHF = foregroundImage.frame.height
                frameWF = foregroundImage.frame.width
                
                dictionary = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue as AnyObject, "brightnessValueB" : brightnessValueB as AnyObject, "contrastValueB" : contrastValueB as AnyObject, "brightnessValueF" : brightnessValueF as AnyObject, "contrastValueF" : contrastValueF as AnyObject, "frameXB" : frameXB as AnyObject, "frameYB" : frameYB as AnyObject,  "frameHB" : frameHB, "frameWB" : frameWB, "frameXF" : frameXF, "frameYF" : frameYF,  "frameHF" : frameHF, "frameWF" : frameWF]
                images.append(dictionary as NSDictionary)
            }
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
        firstUndo = true
        
    }
    
    func pinchedImage(_ sender: UIPinchGestureRecognizer){
        
        if (isBackgroundSelected == true) {
            backgroundImage.transform = backgroundImage.transform.scaledBy(x: sender.scale, y: sender.scale)
            if sender.state == .ended {
                frameXB = backgroundImage.frame.origin.x
                frameYB = backgroundImage.frame.origin.y
                frameHB = backgroundImage.frame.height
                frameWB = backgroundImage.frame.width
                
                dictionary = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue as AnyObject, "brightnessValueB" : brightnessValueB as AnyObject, "contrastValueB" : contrastValueB as AnyObject, "brightnessValueF" : brightnessValueF as AnyObject, "contrastValueF" : contrastValueF as AnyObject, "frameXB" : frameXB as AnyObject, "frameYB" : frameYB as AnyObject,  "frameHB" : frameHB, "frameWB" : frameWB, "frameXF" : frameXF, "frameYF" : frameYF,  "frameHF" : frameHF, "frameWF" : frameWF]
                images.append(dictionary as NSDictionary)
            }
        } else {
            foregroundImage.transform = foregroundImage.transform.scaledBy(x: sender.scale, y: sender.scale)
            if sender.state == .ended {
                frameXF = foregroundImage.frame.origin.x
                frameYF = foregroundImage.frame.origin.y
                frameHF = foregroundImage.frame.height
                frameWF = foregroundImage.frame.width
                
                dictionary = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue as AnyObject, "brightnessValueB" : brightnessValueB as AnyObject, "contrastValueB" : contrastValueB as AnyObject, "brightnessValueF" : brightnessValueF as AnyObject, "contrastValueF" : contrastValueF as AnyObject, "frameXB" : frameXB as AnyObject, "frameYB" : frameYB as AnyObject,  "frameHB" : frameHB, "frameWB" : frameWB, "frameXF" : frameXF, "frameYF" : frameYF,  "frameHF" : frameHF, "frameWF" : frameWF]
                images.append(dictionary as NSDictionary)
            }
        }
        sender.scale = 1.0
        firstUndo = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch (item.tag) {
        case 1:
            self.validateTag(1)
            foregroundImage.addGestureRecognizer(panGesture)
            foregroundImage.addGestureRecognizer(pinchGesture)
            break
        case 2:
            self.validateTag(2)
            blenderLabel.isHidden = false
            brightnessLabel.isHidden = false
            contrastLabel.isHidden = false
            sliderBlender.isHidden = false
            sliderBrightness.isHidden = false
            sliderContrast.isHidden = false
            greyView.isHidden = false
            break
        case 3:
            self.validateTag(3)
            self.undoImage()
            break
        default:
            break
            
        }
        
    }

    func setFilter(_ imageView: UIImageView, beginImage: CIImage, contrastValue: Float, brightnessValue: Float) {
        _ = CIImage(cgImage: imageView.image!.cgImage!)
        if colorControls == nil {
            colorControls = CIFilter(name:"CIColorControls")
        }
        colorControls!.setValue(beginImage, forKey:kCIInputImageKey)
        colorControls!.setValue(contrastValue, forKey:"inputContrast")
        colorControls!.setValue(brightnessValue, forKey:"inputBrightness")
        
        
        let outputImage = colorControls!.outputImage
        
        let cgimg = context.createCGImage(outputImage!, from: outputImage!.extent.standardized)
        
        let originalOrientation = imageView.image!.imageOrientation
        let  originalScale = imageView.image!.scale
        let newImage = UIImage(cgImage: cgimg!, scale:originalScale, orientation:originalOrientation)
        
        imageView.image = newImage

    }
    
    func undoImage() {
        if firstUndo == true && images.count > 1 {
            images.removeLast()
        }
        var dictionary : NSDictionary!
        dictionary = images.removeLast()
        
        frameXB = dictionary.value(forKey: "frameXB") as! CGFloat
        frameYB = dictionary.value(forKey: "frameYB") as! CGFloat
        frameHB = dictionary.value(forKey: "frameHB") as! CGFloat
        frameWB = dictionary.value(forKey: "frameWB") as! CGFloat
        frameXF = dictionary.value(forKey: "frameXF") as! CGFloat
        frameYF = dictionary.value(forKey: "frameYF") as! CGFloat
        frameHF = dictionary.value(forKey: "frameHF") as! CGFloat
        frameWF = dictionary.value(forKey: "frameWF") as! CGFloat
        
        backgroundImage.frame = CGRect(x: frameXB, y: frameYB, width: frameWB, height: frameHB)
        foregroundImage.frame = CGRect(x: frameXF, y: frameYF, width: frameWF, height: frameHF)
        backgroundImage.image = dictionary.value(forKey: "background") as? UIImage
        foregroundImage.image = dictionary.value(forKey: "foreground") as? UIImage
        blenderValue = dictionary.value(forKey: "blenderValue") as! Float
        foregroundImage.alpha = CGFloat(blenderValue)
        brightnessValueB = dictionary.value(forKey: "brightnessValueB") as! Float
        brightnessValueF = dictionary.value(forKey: "brightnessValueF") as! Float
        contrastValueB = dictionary.value(forKey: "contrastValueB") as! Float
        contrastValueF = dictionary.value(forKey: "contrastValueF") as! Float
        sliderBlender.setValue(blenderValue, animated: true)
        
        if (isBackgroundSelected == true) {
            sliderBrightness.setValue(brightnessValueB, animated: true)
            sliderContrast.setValue(contrastValueB, animated: true)
        } else {
            sliderBrightness.setValue(brightnessValueF, animated: true)
            sliderContrast.setValue(contrastValueF, animated: true)
        }
        if (images.isEmpty) {
            let newDictionary : [String: AnyObject] = ["background" : backgroundImage.image!, "foreground" : foregroundImage.image!, "blenderValue" : blenderValue as AnyObject, "brightnessValueB" : brightnessValueB as AnyObject, "contrastValueB" : contrastValueB as AnyObject, "brightnessValueF" : brightnessValueF as AnyObject, "contrastValueF" : contrastValueF as AnyObject, "frameXB" : frameXB as AnyObject, "frameYB" : frameYB as AnyObject,  "frameHB" : frameHB, "frameWB" : frameWB, "frameXF" : frameXF, "frameYF" : frameYF,  "frameHF" : frameHF, "frameWF" : frameWF]
            images.append(newDictionary as NSDictionary)
        }
        firstUndo = false
    }
    
    func validateTag(_ tag: Int) {
        foregroundImage.gestureRecognizers?.removeAll(keepingCapacity: false)
        if tag != 2 {
            greyView.isHidden = true
            blenderLabel.isHidden = true
            brightnessLabel.isHidden = true
            contrastLabel.isHidden = true
            sliderBlender.isHidden = true
            sliderBrightness.isHidden = true
            sliderContrast.isHidden = true
        }
    }
    
    


}
