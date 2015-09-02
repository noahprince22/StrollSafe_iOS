//
//  TermsViewControllerSpec.swift
//  Stroll Safe
//
//  Created by Noah Prince on 9/1/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation
import Quick
import Nimble
import DigitsKit
import Crashlytics
@testable import Stroll_Safe

class TermsViewControllerSpec: QuickSpec {
    
    override func spec() {
        describe ("the terms view") {
            var viewController: Stroll_Safe.TermsViewController!
            
            class DGTSessionMock: DGTSession {
                var _phoneNumber: String!
                override var phoneNumber:String {
                    get {
                        return _phoneNumber
                    }
                    set {
                        self._phoneNumber = newValue
                    }
                }
                
                var _userId: String!
                override var userID:String {
                    get {
                        return _userId
                    }
                    set {
                        self._userId = newValue
                    }
                }
            }
            
            class CrashlyticsMock: Crashlytics {
                override func setUserIdentifier(identifier: String?) {
                    // do nothing
                }
            }
            
            class DigitsMock: Digits {
                var error: NSError?
                var completionFinished = false
                
                override func authenticateWithTitle(title: String!, completion: DGTAuthenticationCompletion!) {
                    let session = DGTSessionMock()
                    session.phoneNumber = "5555555555"
                    session.userID = "hello"
                    completion(session, error)
                    completionFinished = true
                }
            }
            
            var digits: DigitsMock!
            var crashlytics: CrashlyticsMock!
            var moc: NSManagedObjectContext!
            var navViewController: UINavigationController!
            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                navViewController = UINavigationController()
                
                viewController =
                    storyboard.instantiateViewControllerWithIdentifier(
                        "TermsViewController") as! Stroll_Safe.TermsViewController
                
                navViewController.pushViewController(viewController, animated: true)
                
                digits = DigitsMock()
                crashlytics = CrashlyticsMock()
                crashlytics.setUserIdentifier("")
                moc = TestUtils().setUpInMemoryManagedObjectContext()
            }
            
            describe ("dismissing view controllers") {
                it ("places root after settings") {
                    let settings = SettingsNavigatorViewController()
                    navViewController.pushViewController(settings, animated: true)
                    expect(navViewController.viewControllers.last).toEventually(beAnInstanceOf(SettingsNavigatorViewController))
                    viewController.dismiss(settings)
                    
                    expect(navViewController.viewControllers.last).toEventually(beAnInstanceOf(TermsViewController), timeout: 2)
                }
                
                it ("places settings after tutorial") {
                    let tutorial = TutorialViewController()
                    navViewController.pushViewController(tutorial, animated: true)
                    expect(navViewController.viewControllers.last).toEventually(beAnInstanceOf(TutorialViewController))
                    viewController.dismiss(tutorial)
                    
                    expect(navViewController.viewControllers.last).toEventually(beAnInstanceOf(SettingsNavigatorViewController))
                }
                
                it ("places tutorial after set passcode") {
                    let setPasscode = SetPasscodeViewController()
                    navViewController.pushViewController(setPasscode, animated: true)
                    expect(navViewController.viewControllers.last).toEventually(beAnInstanceOf(SetPasscodeViewController))
                    viewController.dismiss(setPasscode)
                    
                    expect(navViewController.viewControllers.last).toEventually(beAnInstanceOf(TutorialViewController))
                }
            }
            
            describe("accept button") {
                context("no digits errors") {
                    beforeEach {
                        viewController.accept(digits, crashlytics: crashlytics, managedObjectContext: moc)
                        expect(digits.completionFinished).toEventually(beTrue())
                    }
                    
                    it ("pushes the set passcode controller") {
                        expect(viewController.navigationController?.viewControllers.last).to(beAnInstanceOf(SetPasscodeViewController))
                    }
                    
                    // it's impossible (for some unknown reason) to mock crashlytics. It just doesn't
                    // call the setUserIdentifier function. Don't waste time on this
//                    it ("sets the user id for crashlytics using digits") {
//                        expect(crashlytics.userId).to(equal("hello"))
//                    }
                    
                    it ("stores the phone number provided by digits in the managed object context") {
                        var conf: Stroll_Safe.Configuration?
                        do {
                            conf = try Configuration.get(moc)
                        } catch {
                            // do nothing
                        }
                        
                        expect(conf!.phone_number!).to(equal("5555555555"))
                    }
                }

                context("with digit error") {
                    beforeEach {
                        digits.error = NSError(domain: "somedomain", code: 123, userInfo: nil)

                        viewController.accept(digits, crashlytics: crashlytics, managedObjectContext: moc)
                    }
                    
                    it ("does nothing") {
                        expect(viewController.navigationController?.viewControllers.first).to(beAnInstanceOf(TermsViewController))
                        expect { try Configuration.get(moc) }.to(throwError())
                    }
                }
            }
        }
    }
}