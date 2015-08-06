//
//  PasscodeSpec.swift
//  Stroll Safe
//
//  Created by Lynda Prince on 8/3/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation

import Foundation
import Quick
import Nimble
@testable import Stroll_Safe
import CoreData

class PasscodeSpec: QuickSpec {
    
    override func spec() {
        describe("The Passcode Model") {
            var managedObjectContext: NSManagedObjectContext!
            
            beforeEach {
                managedObjectContext = TestUtils().setUpInMemoryManagedObjectContext()
            }
            
            it ("throws an error when there is no stored passcode") {
                expect{ try Passcode.get(managedObjectContext) }.to(throwError())
            }
            
            it ("get returns the passcode used in set") {
                let passcode = "1234"
                Passcode.set(passcode, managedObjectContext: managedObjectContext)
                expect(try! Passcode.get(managedObjectContext)).to(equal(passcode))
            }
        }
    }
}