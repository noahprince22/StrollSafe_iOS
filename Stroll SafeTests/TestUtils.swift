//
//  TestUtils.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/3/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation
import CoreData
@testable import Stroll_Safe

class TestUtils {
    
    /**
    Sets up and returns an in memory managed object context
    
    :returns: the in memory managed object context
    */
    func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        try! persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }
    
    
    /**
    gets a Configuration item and puts it in the managed object context
    
    :param: managedObjectContext
    */
    func getNewConfigurationItem(managedObjectContext: NSManagedObjectContext) -> Configuration {
        return NSEntityDescription.insertNewObjectForEntityForName("Configuration", inManagedObjectContext: managedObjectContext) as! Configuration
    }
    
    /**
    Stores a fake configuration with the given password value in the managed object context
    
    :param: managedObjectContext the managed object context to store this in
    */
    func storeConfWithPass(pass: String, managedObjectContext: NSManagedObjectContext) throws{
        // Store the configuration
        let newItem = getNewConfigurationItem(managedObjectContext)
        newItem.passcode = pass
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            NSLog("Unresolved error while storing password \(error), \(error.userInfo)")
            abort()
        }
    }
}
