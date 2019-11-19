//
//  AppDelegate.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/13/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//

import UIKit
import CoreData
import AlamofireNetworkActivityIndicator

/*
var gManagedObjectContext: NSManagedObjectContext!
*/

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
   // var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NetworkActivityIndicatorManager.shared.isEnabled = true
        return true
    }
}

