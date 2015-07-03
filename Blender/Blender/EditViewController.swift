//
//  EditViewController.swift
//  Blender
//
//  Created by Mariana Alvarez on 02/07/15.
//  Copyright (c) 2015 Mariana Alvarez. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
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
}
