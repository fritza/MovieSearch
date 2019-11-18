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

var gManagedObjectContext: NSManagedObjectContext!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
   // var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        gManagedObjectContext = managedObjectContext
        NetworkActivityIndicatorManager.shared.isEnabled = true
        return true
    }
    
    // MARK: - Core Data stack
    
    lazy var mangedObjectModel: NSManagedObjectModel = {
        guard
            let momURL = Bundle.main.url(
                forResource: Constants.momBaseName,
                withExtension: "mom"),
            let retval = NSManagedObjectModel(contentsOf: momURL)
            else { preconditionFailure() }
        return retval
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        do {
            let retval = NSPersistentStoreCoordinator(managedObjectModel: mangedObjectModel)
            try retval.addPersistentStore(
                ofType: NSInMemoryStoreType,
                configurationName: nil, at: nil)
            return retval
        }
        catch {
            preconditionFailure()
        }
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Probably will never need background processing.
        // The store is in-memory.
        return NSManagedObjectContext(
            concurrencyType: .mainQueueConcurrencyType)
    }()
}

