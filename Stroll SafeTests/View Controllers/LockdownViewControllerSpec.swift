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
import CoreData
import CoreLocation
@testable import Stroll_Safe

class LockdownViewControllerSpec: QuickSpec, DismissableViewDelegate {
    var dismissed = false
    func dismiss(controller: UIViewController) {
        dismissed = true
    }
    
    override func spec() {
        describe ("the lockdown view") {
            var viewController: Stroll_Safe.LockdownViewController!
            var conf: Stroll_Safe.Configuration!
            let smsRecipient1 = "1234567890"
            let smsRecipient2 = "2222222222"
            let smsRecipients = "\(smsRecipient1),\(smsRecipient2)"
            let callRecipient = "8888888888"
            let smsBody = "body"
            let passcode = "5678"
            let phonenumber = "8748728374"
            let lockdownDuration: Double = 10
            let fullName = "Urist McTest"
            
            var moc: NSManagedObjectContext!
            
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
                self.dismissed = false
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                viewController =
                    storyboard.instantiateViewControllerWithIdentifier(
                        "LockdownView") as! Stroll_Safe.LockdownViewController
                
                viewController.beginAppearanceTransition(true, animated: false)
                viewController.endAppearanceTransition()
                viewController.asyncAlertAction.pause()
                viewController.delegate = self
                
                communicationUtilMock = CommunicationUtilMock()
                
                moc = TestUtils().setUpInMemoryManagedObjectContext()
                conf = TestUtils().getNewConfigurationItem(moc)
                conf.passcode = passcode
                conf.sms_body = smsBody
                conf.call_recipient = callRecipient
                conf.sms_recipients = smsRecipients
                conf.lockdown_duration = lockdownDuration
                conf.phone_number = phonenumber
                conf.full_name = fullName
                try! moc.save()
                
                viewController.configure(moc)
                viewController.lock.lock(passcode)
            }
            
            describe ("pinpad controll") {
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
                
                beforeEach {
                    pinpadViewController = PinpadViewControllerMock()
                }
                
                it ("does not unlock when provided the wrong code") {
                    viewController.passEntered(pinpadViewController, pass: "2222")
                    expect(viewController.lock.isLocked()).to(beTrue())
                    expect(pinpadViewController.shaken).to(beTrue())
                    expect(pinpadViewController.cleared).to(beTrue())
                }
                
                it ("unlocks when provided the right code") {
                    viewController.passEntered(pinpadViewController, pass: passcode)
                    expect(viewController.lock.isLocked()).to(beFalse());
                    expect(pinpadViewController.shaken).to(beFalse())
                    expect(pinpadViewController.cleared).to(beTrue())
                    expect(self.dismissed).to(beTrue())
                }
            }
            
            describe("interruptions") {
                class TimedActionMock: TimedAction {
                    var pausedMock = false
                    var runMock = false

                    override func pause() {
                        pausedMock = true
                        runMock = false
                    }
                    
                    override func run() {
                        runMock = true
                        pausedMock = false
                    }
                }
                
                var action: TimedActionMock!
                beforeEach {
                    action = TimedActionMock(builder: TimedActionBuilder(buildClosure: { _ in }))
                    viewController.asyncAlertAction = action
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("UIApplicationWillResignActiveNotification", object:self, userInfo:nil);
                }
                
                it ("pauses the timer when interrupted") {
                    expect(action.pausedMock).to(beTrue())
                    expect(action.runMock).to(beFalse())
                }
                
                it ("resumes the timer when resumed") {
                    NSNotificationCenter.defaultCenter().postNotificationName("UIApplicationWillEnterForegroundNotification", object:self, userInfo:nil);
                    expect(action.pausedMock).to(beFalse())
                    expect(action.runMock).to(beTrue())
                }
            }
            
            // makes sure the provided asynch action functions work as expected
            describe ("asynchAction") {
                var action: TimedAction!
                
                beforeEach {
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
                        context("outbound communication") {
                            beforeEach {
                                action.exitFunction(viewController.lockdownDuration)
                            }
                            
                            it ("calls the configured contacts") {
                                expect(communicationUtilMock.callRecipient).to(equal(callRecipient))
                            }
                            
                            it ("sms messages the configured contacts with the configured body") {
                                expect(communicationUtilMock.smsRecipients).to(contain(smsRecipient1))
                                expect(communicationUtilMock.smsRecipients).to(contain(smsRecipient2))
                                expect(communicationUtilMock.smsBody).to(contain(smsBody))
                            }
                            
                            it ("dismisses the view controller") {
                                expect(self.dismissed).to(beTrue())
                            }
                        }
                        
                        context ("sms body") {
                            var coord = CLLocationCoordinate2D()
                            
                            class PlacemarkMock : CLPlacemark {
                                var _name: String?
                                var _thoroughfare: String?
                                var _subThoroughfare: String?
                                
                                override var name: String? {
                                    get {
                                        return self._name
                                    }
                                    
                                    set {
                                        self._name = newValue
                                    }
                                }
                                
                                override var thoroughfare: String? {
                                    get {
                                        return self._thoroughfare
                                    }
                                    
                                    set {
                                        self._thoroughfare = newValue
                                    }
                                }
                                
                                override var subThoroughfare: String? {
                                    get {
                                        return self._subThoroughfare
                                    }
                                    
                                    set {
                                        self._subThoroughfare = newValue
                                    }
                                }
                            }
                            
                            let placemark = PlacemarkMock()

                            beforeEach {
                                coord.latitude = 25
                                coord.longitude = 50
                                viewController.coordinates = coord
                                viewController.placemark = placemark
                            }
                            
                            it ("includes a non nil coord") {
                                action.exitFunction(viewController.lockdownDuration)
                                
                                expect(communicationUtilMock.smsBody).to(contain("\(coord.latitude)"))
                                expect(communicationUtilMock.smsBody).to(contain("\(coord.longitude)"))
                                expect(communicationUtilMock.smsBody).to(contain("Nearest address unavailable"))
                            }
                            
                            it ("does not include a nil coord") {
                                viewController.coordinates = nil
                                
                                action.exitFunction(viewController.lockdownDuration)
                                
                                expect(communicationUtilMock.smsBody).toNot(contain("nil"))
                                expect(communicationUtilMock.smsBody).to(contain("Nearest address unavailable"))
                                expect(communicationUtilMock.smsBody).to(contain("Coordinates unavailable"))
                            }
                            
                            context ("with non nil placemark") {
                                it ("includes a non nil name") {
                                    placemark.name = "Hello"
                                    
                                    action.exitFunction(viewController.lockdownDuration)
                                    
                                    expect(communicationUtilMock.smsBody).to(contain("\(placemark.name!)"))
                                    expect(communicationUtilMock.smsBody).toNot(contain("nil"))
                                    expect(communicationUtilMock.smsBody).toNot(contain("Nearest address unavailable"))
                                }
                                
                                it ("includes a non nil address") {
                                    placemark.thoroughfare = "Example Address St"
                                    placemark.subThoroughfare = "15020"
                                    
                                    action.exitFunction(viewController.lockdownDuration)
                                    
                                    expect(communicationUtilMock.smsBody).to(contain("\(placemark.name!)"))
                                    expect(communicationUtilMock.smsBody).toNot(contain("nil"))
                                    expect(communicationUtilMock.smsBody).toNot(contain("Nearest address unavailable"))
                                }
                            }
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