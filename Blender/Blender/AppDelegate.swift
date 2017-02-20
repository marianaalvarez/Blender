//
//  AppDelegate.swift
//  Blender
//
//  Created by Mariana Alvarez on 30/06/15.
//  Copyright (c) 2015 Mariana Alvarez. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UITabBar.appearance().tintColor = UIColor(red:1, green:0.41, blue:0.617, alpha:1)
        return true
    }

}

