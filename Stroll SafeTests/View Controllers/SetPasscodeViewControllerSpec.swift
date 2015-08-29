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

class SetPasscodeViewControllerSpec: QuickSpec, DismissableViewDelegate {
    var dismissed = false
    func dismiss(controller: UIViewController) {
        dismissed = true
    }
    
    override func spec() {
        describe ("the set passcode view") {
            var viewController: Stroll_Safe.SetPasscodeViewController!
            
            beforeEach {
                self.dismissed = false
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                viewController =
                    storyboard.instantiateViewControllerWithIdentifier(
                        "SetPasscodeViewController") as! Stroll_Safe.SetPasscodeViewController
                
                viewController.beginAppearanceTransition(true, animated: false)
                viewController.endAppearanceTransition()
                viewController.delegate = self
            }
            
            describe("pinpad control") {
                class PinpadViewControllerMock: Stroll_Safe.PinpadViewController {
                    var enteredFunction: ((String) throws -> ())!
                    var shaken = false
                    var cleared = false
                    
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
                }
                
                it ("rejects two different passcodes") {
                    viewController.checkAndStorePass(pinpadViewController, pass: "1234", managedObjectContext: managedObjectContext)
                    expect(pinpadViewController.cleared).to(beTrue())
                    expect(pinpadViewController.shaken).to(beFalse())
                    
                    viewController.checkAndStorePass(pinpadViewController, pass: "5678", managedObjectContext: managedObjectContext)
                    expect(pinpadViewController.cleared).to(beTrue())
                    expect(pinpadViewController.shaken).to(beTrue())
                }
                
                it ("accepts two identical passcodes, stores the passcode, and dismisses") {
                    let pass = "1234"
                    
                    viewController.checkAndStorePass(pinpadViewController, pass: pass, managedObjectContext: managedObjectContext)
                    expect(pinpadViewController.cleared).to(beTrue())
                    expect(pinpadViewController.shaken).to(beFalse())
                    
                    viewController.checkAndStorePass(pinpadViewController, pass: pass, managedObjectContext: managedObjectContext)
                    expect(pinpadViewController.cleared).to(beTrue())
                    expect(pinpadViewController.shaken).to(beFalse())
                    
                    let storedConf = try! Configuration.get(managedObjectContext)
                    expect(storedConf.passcode).to(equal(pass))
                    expect(self.dismissed).to(beTrue())
                }
            }
        }
    }
}
