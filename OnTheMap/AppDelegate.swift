//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Nick Adcock on 3/10/16.
//  Copyright © 2016 NEA. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var parse = Parse()
    var userInfo = Udacity()
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

}

