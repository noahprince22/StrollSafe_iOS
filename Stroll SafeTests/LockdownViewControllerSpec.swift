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
        describe ("the lock subclass") {
            var lock: Stroll_Safe.LockdownViewController.Lock!

            beforeEach {
                lock = Stroll_Safe.LockdownViewController.Lock()
                lock.lock("1234")
                expect(lock.isLocked()).to(beTrue());
            }
            
            it ("unlocks when provided the right code") {
                expect(lock.unlock("1234")).to(beTrue())
                expect(lock.isLocked()).to(beFalse());
            }
            it ("does not unlock when provided the wrong code") {
                expect(lock.unlock("2222")).to(beFalse())
                expect(lock.isLocked()).to(beTrue());
            }
        }
        
        describe ("the lockdown view") {
            var viewController: Stroll_Safe.LockdownViewController!
            
            beforeEach {
                MainViewController.test = true
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                viewController =
                    storyboard.instantiateViewControllerWithIdentifier(
                        "LockdownView") as! Stroll_Safe.LockdownViewController
                
                viewController.beginAppearanceTransition(true, animated: false)
                viewController.endAppearanceTransition()
            }
        }
    }
}