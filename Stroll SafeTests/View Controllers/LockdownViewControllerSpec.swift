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
            var viewController: Stroll_Safe.LockdownViewController!
            
            beforeEach {                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                viewController =
                    storyboard.instantiateViewControllerWithIdentifier(
                        "LockdownView") as! Stroll_Safe.LockdownViewController
                
                viewController.beginAppearanceTransition(true, animated: false)
                viewController.endAppearanceTransition()
                viewController.asyncAlertAction.pause()
            }
            
            describe ("pinpad controll") {
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
                
                // Store a pass as "5678"
                let managedObjectContext = TestUtils().setUpInMemoryManagedObjectContext()
                try! TestUtils().storeConfWithPass("5678", managedObjectContext: managedObjectContext)
                
                beforeEach {
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
            
            // makes sure the provided asynch action functions work as expected
            describe ("asynchAction") {
                var conf: Stroll_Safe.Configuration!
                let lockdownDuration: Double = 10
                var action: TimedAction!
                
                let smsRecipient1 = "1234567890"
                let smsRecipient2 = "2222222222"
                let smsRecipients = "\(smsRecipient1),\(smsRecipient2)"
                let callRecipient = "8888888888"
                let smsBody = "body"
                let passcode = "1234"
                
                class CommunicationUtilMock: Stroll_Safe.CommunicationUtil {
                    var smsRecipients: [String]!
                    var callRecipient: String!
                    var smsBody: String!
                    
                    override func sendSms(recipients: [String], body: String) {
                        smsRecipients = recipients
                        smsBody = body
                    }
                    
                    override func sendCall(recipient: String) {
                        callRecipient = recipient
                    }
                }
                
                var communicationUtilMock: CommunicationUtilMock!
                
                beforeEach {
                    communicationUtilMock = CommunicationUtilMock()
                    
                    let moc = TestUtils().setUpInMemoryManagedObjectContext()
                    conf = TestUtils().getNewConfigurationItem(moc)
                    conf.passcode = passcode
                    conf.sms_body = smsBody
                    conf.call_recipient = callRecipient
                    conf.sms_recipients = smsRecipients
                    conf.lockdown_duration = lockdownDuration
                    try! moc.save()
                    
                    viewController.configure(moc)
                    viewController.lock.lock(passcode)
                    action = viewController.buildAsyncAlertAction(communicationUtilMock)
                }
                
                describe("break condition") {
                    it ("does not break when the lock is locked") {
                        viewController.lock.lock(passcode)
                        expect(action.breakCondition(1)).to(beFalse())
                    }
                    
                    it ("breaks when the lock is unlocked") {
                        viewController.lock.lock(passcode)
                        viewController.lock.unlock(passcode)
                        expect(action.breakCondition(1)).to(beTrue())
                    }
                }
                
                describe("recurrent function") {
                    it ("updates the progress bar") {
                        let expectedProgress = viewController.lockdownDuration / 2
                        action.recurrentFunction(expectedProgress)
                        
                        expect(viewController.progressCircle.progress).toEventually(beCloseTo(0.5, within: 0.05), timeout: 1)
                        let expectedProgressString = expectedProgress.format("0.1")
                        expect(viewController.progressLabel.text).toEventually(contain(expectedProgressString), timeout: 0.5)
                    }
                }
                
                it ("sets seconds to run to the configured lockdown duration") {
                    expect(action.secondsToRun).to(equal(lockdownDuration))
                }
                
                describe ("exit function") {
                    describe ("while locked") {
                        beforeEach {
                            action.exitFunction(viewController.lockdownDuration)
                        }
                        
                        it ("calls the configured contacts") {
                            expect(communicationUtilMock.callRecipient).to(equal(callRecipient))
                        }
                        
                        it ("sms messages the configured contacts with the configured body") {
                            expect(communicationUtilMock.smsRecipients).to(contain(smsRecipient1))
                            expect(communicationUtilMock.smsRecipients).to(contain(smsRecipient2))
                            expect(communicationUtilMock.smsBody).to(equal(smsBody))
                        }
                    }
                    
                    describe ("while unlocked") {
                        beforeEach {
                            viewController.lock.unlock(passcode)
                            action.exitFunction(viewController.lockdownDuration)
                        }
                        
                        it ("does not call or text") {
                            expect(communicationUtilMock.smsBody).to(beNil())
                            expect(communicationUtilMock.smsRecipients).to(beNil())
                            expect(communicationUtilMock.callRecipient).to(beNil())
                        }
                    }
                }
            }
        }
    }
}