//
//  AppDelegate.swift
//  SDOSKZBootstrap
//
//  Created by Rafael Fernandez Alvarez on 29/05/2018.
//  Copyright © 2018 SDOS. All rights reserved.
//

import UIKit
import SDOSEnvironment

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        var aaa = SDOSEnvironment.environmentKey
        SDOSEnvironment.configure(debug: true)
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard.init(name: "ExampleKZBootstrap", bundle: nil)
        let viewcontroller = storyboard.instantiateInitialViewController()
        
        self.window?.rootViewController = viewcontroller
        self.window?.makeKeyAndVisible()
        
        return true
        
    }
}
