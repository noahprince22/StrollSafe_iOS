//
//  Configuration.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/9/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation
import CoreData

class Configuration: NSManagedObject {
    
    @NSManaged var passcode: String?
    @NSManaged var lockdown_duration: NSNumber?
    @NSManaged var sms_recipients: String?
    @NSManaged var call_recipient: String?
    @NSManaged var release_duration: NSNumber?

    enum ConfigurationError: ErrorType {
        case NoResultsFound
    }

    /**
    Gets the stored configuration for the given managed object context
    
    :param: managedObjectContext the managed object context
    */
    class func get(managedObjectContext: NSManagedObjectContext) throws -> Configuration {
        let fetchRequest = NSFetchRequest(entityName: "Configuration")
        
        var fetchResults: [Configuration]
        do {
            fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Configuration]
        } catch let fetchError as NSError {
            print("fetch Configuration error: \(fetchError.localizedDescription)")
            throw fetchError
        }
        
        if let result = fetchResults.first {
            return result
        } else {
            throw ConfigurationError.NoResultsFound
        }
    }
}
