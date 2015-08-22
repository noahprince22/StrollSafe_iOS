//
//  SetPasscodeViewControllerSpec.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/5/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Stroll_Safe

class SetPasscodeViewControllerSpec: QuickSpec {
    
    override func spec() {
        describe ("the set passcode view") {
            var viewController: Stroll_Safe.SetPasscodeViewController!
            
            beforeEach {                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                viewController =
                    storyboard.instantiateViewControllerWithIdentifier(
                        "SetPasscodeViewController") as! Stroll_Safe.SetPasscodeViewController
                
                viewController.beginAppearanceTransition(true, animated: false)
                viewController.endAppearanceTransition()
            }
            
            describe("pinpad control") {
                class PinpadViewControllerMock: Stroll_Safe.PinpadViewController {
                    var enteredFunction: ((String) throws -> ())!
                    var shaken = false
                    var cleared = false
                    
                    override func setEnteredFunction(fn: (String) throws -> ()) {
                        self.enteredFunction = fn
                    }
                    
                    override func shake() {
                        shaken = true
                    }
                    
                    override func clear() {
                        cleared = true
                    }
                }
                
                var pinpadViewController: PinpadViewControllerMock!
                let managedObjectContext = TestUtils().setUpInMemoryManagedObjectContext()
                
                beforeEach {
                    pinpadViewController = PinpadViewControllerMock()
                    
                    viewController.pinpadViewController = pinpadViewController
                    viewController.setupPinpadViewToStorePasscode(managedObjectContext)
                }
                
                it ("rejects two different passcodes") {
                    try! pinpadViewController.enteredFunction("1234")
                    expect(pinpadViewController.cleared).to(beTrue())
                    expect(pinpadViewController.shaken).to(beFalse())
                    
                    try! pinpadViewController.enteredFunction("5678")
                    expect(pinpadViewController.cleared).to(beTrue())
                    expect(pinpadViewController.shaken).to(beTrue())
                }
                
                it ("accepts two identical passcodes and stores the passcode") {
                    let pass = "1234"
                    
                    try! pinpadViewController.enteredFunction(pass)
                    expect(pinpadViewController.cleared).to(beTrue())
                    expect(pinpadViewController.shaken).to(beFalse())
                    
                    try! pinpadViewController.enteredFunction(pass)
                    expect(pinpadViewController.cleared).to(beTrue())
                    expect(pinpadViewController.shaken).to(beFalse())
                    
                    let storedConf = try! Configuration.get(managedObjectContext)
                    expect(storedConf.passcode).to(equal(pass))
                }
            }
        }
    }
}
