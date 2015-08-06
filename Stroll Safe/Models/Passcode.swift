//
//  Passcode.swift
//  Stroll Safe
//
//  Created by Noah Prince on 3/25/15.
//  Copyright (c) 2015 Stroll Safe. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class Passcode: NSManagedObject {
    enum PasscodeError: ErrorType {
        case NoResultsFound
    }

    @NSManaged var passcode: String

    /**
    Gets the stored passcode for the given managed object context
    
    :param: managedObjectContext the managed object context
    */
    class func get(managedObjectContext: NSManagedObjectContext) throws -> String {
        let fetchRequest = NSFetchRequest(entityName: "Passcode")
        
        var fetchResults: [Passcode]
        do {
            fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Passcode]
        } catch let fetchError as NSError {
            print("fetch Passcode error: \(fetchError.localizedDescription)")
            throw fetchError
        }
        
        if let result = fetchResults.first {
            return result.passcode
        } else {
            throw PasscodeError.NoResultsFound
        }
    }

    /**
    Sets the stored passcode for the given managed object context
    
    :param: password             the passcode
    :param: managedObjectContext the managed object context
    */
    class func set(passcode: String, managedObjectContext: NSManagedObjectContext) {
        // Store the password
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Passcode", inManagedObjectContext: managedObjectContext) as! Passcode
        newItem.passcode = passcode
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            NSLog("Unresolved error while storing password \(error), \(error.userInfo)")
            abort()
        }
    }
}
