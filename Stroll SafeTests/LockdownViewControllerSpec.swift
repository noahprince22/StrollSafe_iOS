//
//  LockdownViewControllerSpec.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/4/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//
import Foundation
import Quick
import Nimble
@testable import Stroll_Safe

class LockdownViewControllerSpec: QuickSpec {
    
    override func spec() {
        describe ("the lockdown view") {
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
            
            var viewController: Stroll_Safe.LockdownViewController!
            var pinpadViewController: PinpadViewControllerMock!
            
            // Store a pass as "5678"
            let managedObjectContext = TestUtils().setUpInMemoryManagedObjectContext()
            Passcode.set("5678", managedObjectContext: managedObjectContext)
            
            beforeEach {
                MainViewController.test = true
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                viewController =
                    storyboard.instantiateViewControllerWithIdentifier(
                        "LockdownView") as! Stroll_Safe.LockdownViewController
                
                viewController.beginAppearanceTransition(true, animated: false)
                viewController.endAppearanceTransition()
                
                pinpadViewController = PinpadViewControllerMock()
                
                viewController.pinpadViewController = pinpadViewController
                viewController.setupPinpadViewWithStoredPasscode(managedObjectContext)
            }
            
            it ("does not unlock when provided the wrong code") {
                try! pinpadViewController.enteredFunction("2222")
                expect(viewController.lock.isLocked()).to(beTrue())
                expect(pinpadViewController.shaken).to(beTrue())
                expect(pinpadViewController.cleared).to(beTrue())
            }
            
            it ("unlocks when provided the right code") {
                try! pinpadViewController.enteredFunction("5678")
                expect(viewController.lock.isLocked()).to(beFalse());
                expect(pinpadViewController.shaken).to(beFalse())
                expect(pinpadViewController.cleared).to(beTrue())
            }
        }
    }
}