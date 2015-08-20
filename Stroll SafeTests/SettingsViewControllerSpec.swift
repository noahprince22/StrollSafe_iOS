//
//  SettingsViewControllerSpec.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/18/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation
import Quick
import Nimble
import CoreData
@testable import Stroll_Safe


/**
* Spec to test the settings view controller
*
* Issues disallowed by the UI that are tested in UI tests:
*   Contact Champaign Police checked AND callContact filled
*   Anything keyboard related: IE timers can't have non numeric/decimal typed in
*/
class SettingsViewControllerSpec: QuickSpec {
    
    override func spec() {
        describe ("the settings view") {
            var viewController: Stroll_Safe.SettingsViewController!
            
            class UIAlertViewMock: UIAlertView {
                var shown = false
                
                override func show() {
                    shown = true
                }
            }
            
            // A number that will pass the error mock
            let safeNumber = "5555555555"
            class CommunicationUtilErrorMock: Stroll_Safe.CommunicationUtil {
                var error = PhoneNumberError.TooLong
                
                override func formatNumber(number: String) throws -> String {
                    if (number != "5555555555") {
                        throw error
                    }
                    
                    return number
                }
            }
            
            class CommunicationUtilNonErrorMock: Stroll_Safe.CommunicationUtil {
                override func formatNumber(number: String) throws -> String {
                    return number
                }
            }
            var alertView: UIAlertViewMock!
            
            var managedObjectContext: NSManagedObjectContext!
            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                viewController =
                    storyboard.instantiateViewControllerWithIdentifier(
                        "settings") as! Stroll_Safe.SettingsViewController
                
                viewController.beginAppearanceTransition(true, animated: false)
                viewController.endAppearanceTransition()
                
                alertView = UIAlertViewMock()
                managedObjectContext = TestUtils().setUpInMemoryManagedObjectContext()
            }
            
            describe ("saving the settings") {
//                describe ("good input") {
//                let fullName = "Urist McTest"
//                let phoneNumber = "1234567"
//                
//                beforeEach {
//                    viewController.name.text = fullName
//                    viewController.phonenumber.text = phoneNumber
//                }
//                    var comUtil: CommunicationUtilNonErrorMock!
//                    beforeEach {
//                        comUtil = CommunicationUtilNonErrorMock()
//                    }
//                    
//                    it ("saves the full name and phone number") {
//                        viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
//                        expect(alertView.shown).to(beFalse())
//                        
//                        let storedConf = try! Configuration.get(managedObjectContext)
//                        expect(storedConf.full_name).to(equal(fullName))
//                        expect(storedConf.phone_number).to(equal(phoneNumber))
//                    }
//                    
//                    it ("saves the call contact") {
//                        let callRecipient = "1234567890"
//                        viewController.contactPoliceSwitch.on = false
//                        viewController.callContact.text = callRecipient
//                        
//                        viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
//                        expect(alertView.shown).to(beFalse())
//                        
//                        let storedConf = try! Configuration.get(managedObjectContext)
//                        expect(storedConf.call_recipient).to(equal(callRecipient))
//                    }
//                    
//                    it ("saves the text contact and body") {
//                        let smsRecipient = "15556667788"
//                        let smsBody = "Hello"
//                        viewController.textContact.text = smsRecipient
//                        viewController.textBody.text = smsBody
//                        viewController.textEnabledSwitch.on = true
//                        
//                        viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
//                        expect(alertView.shown).to(beFalse())
//                        
//                        let storedConf = try! Configuration.get(managedObjectContext)
//                        expect(storedConf.sms_recipients).to(equal(smsRecipient))
//                        expect(storedConf.sms_body).to(equal(smsBody))
//                    }
//                    
//                    it ("does not save the text contact and body if text is disabled") {
//                        let smsRecipient = "15556667788"
//                        let smsBody = "Hello"
//                        viewController.textContact.text = smsRecipient
//                        viewController.textBody.text = smsBody
//                        viewController.textEnabledSwitch.on = false
//                        
//                        viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
//                        expect(alertView.shown).to(beFalse())
//                        
//                        let storedConf = try! Configuration.get(managedObjectContext)
//                        expect(storedConf.sms_recipients).toNot(equal(smsRecipient))
//                        expect(storedConf.sms_body).toNot(equal(smsBody))
//                    }
//                    
//                    it ("saves the lockdown timer with decimals") {
//                        let lockdownDuration = ".2"
//                        viewController.lockdownTime.text = lockdownDuration
//                        viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
//                        expect(alertView.shown).to(beFalse())
//                        
//                        let storedConf = try! Configuration.get(managedObjectContext)
//                        expect(storedConf.lockdown_duration) == (lockdownDuration as NSString).doubleValue
//                    }
//                    
//                    it ("saves the lockdown timer with no decimals") {
//                        let lockdownDuration = "826"
//                        viewController.lockdownTime.text = lockdownDuration
//                        viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
//                        expect(alertView.shown).to(beFalse())
//                        
//                        let storedConf = try! Configuration.get(managedObjectContext)
//                        expect(storedConf.lockdown_duration) == (lockdownDuration as NSString).doubleValue
//                    }
//                    
//                    it ("saves the release timer with decimals") {
//                        let releaseDuration = "0.2"
//                        viewController.releaseTime.text = releaseDuration
//                        viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
//                        expect(alertView.shown).to(beFalse())
//                        
//                        let storedConf = try! Configuration.get(managedObjectContext)
//                        expect(storedConf.release_duration) == (releaseDuration as NSString).doubleValue
//                    }
//                    
//                    
//                    it ("saves the release timer with no decimals") {
//                        let releaseDuration = "200"
//                        viewController.releaseTime.text = releaseDuration
//                        viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
//                        expect(alertView.shown).to(beFalse())
//                        
//                        let storedConf = try! Configuration.get(managedObjectContext)
//                        expect(storedConf.release_duration) == (releaseDuration as NSString).doubleValue
//                    }
//                }
                
                describe ("bad input") {
                    var comUtil: CommunicationUtilErrorMock!
                    var comUtilNoError: CommunicationUtilNonErrorMock!
                    
                    beforeEach {
                        comUtil = CommunicationUtilErrorMock()
                        comUtilNoError = CommunicationUtilNonErrorMock()
                    }
                    
                    // Don't need to check for odd characters, keyboard only allows numbers
                    describe ("incorrect phone numbers") {
                        describe ("too short a phone number as input") {
                            beforeEach {
                                comUtil.error = CommunicationUtilErrorMock.PhoneNumberError.TooShort
                                
                                viewController.name.text = "Urist McTest"
                            }
                            
                            it ("personal fails") {
                                viewController.phonenumber.text = "1234567"
                                
                                viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
                                expect(alertView.shown).to(beTrue())
                                expect(alertView.message).to(equal("Personal \(SettingsViewController.PHONE_TOO_SHORT)\n"))
                            }
                            
                            it ("call fails validation") {
                                viewController.phonenumber.text = safeNumber
                                viewController.callContact.text = "1234567"
                                
                                viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
                                expect(alertView.shown).to(beTrue())
                                expect(alertView.message).to(equal("Calling \(SettingsViewController.PHONE_TOO_SHORT)\n"))
                            }
                            
                            it ("text fails validation") {
                                viewController.phonenumber.text = safeNumber
                                viewController.textContact.text = "1234567"
                                
                                viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
                                expect(alertView.shown).to(beTrue())
                                expect(alertView.message).to(equal("Texting \(SettingsViewController.PHONE_TOO_SHORT)\n"))
                            }
                        }
                        
                        describe ("too long phone number as input") {
                            beforeEach {
                                comUtil.error = CommunicationUtilErrorMock.PhoneNumberError.TooLong
                                viewController.name.text = "Urist McTest"
                            }
                            
                            it ("personal fails validation") {
                                viewController.phonenumber.text = "345678910118"
                                
                                viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
                                expect(alertView.shown).to(beTrue())
                                expect(alertView.message).to(equal("Personal \(SettingsViewController.PHONE_TOO_LONG)\n"))
                            }
                            
                            it ("call fails validation") {
                                viewController.phonenumber.text = safeNumber
                                viewController.callContact.text = "345678910118"
                                
                                viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
                                expect(alertView.shown).to(beTrue())
                                expect(alertView.message).to(equal("Calling \(SettingsViewController.PHONE_TOO_LONG)\n"))
                            }
                            
                            it ("text fails validation") {
                                viewController.phonenumber.text = safeNumber
                                viewController.textContact.text = "345678910118"
                                
                                viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
                                expect(alertView.shown).to(beTrue())
                                expect(alertView.message).to(equal("Texting \(SettingsViewController.PHONE_TOO_LONG)\n"))
                            }
                            
                        }
                        
                        describe("911 as input") {
                            beforeEach {
                                viewController.name.text = "Urist McTest"
                            }
                            it ("personal fails validation") {
                                viewController.phonenumber.text = "911"
                                comUtil.error = CommunicationUtilErrorMock.PhoneNumberError.TooShort
                                
                                viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
                                expect(alertView.shown).to(beTrue())
                                expect(alertView.message).to(equal("Personal \(SettingsViewController.PHONE_TOO_SHORT)\n"))
                            }
                            
                            it ("calling fails validation") {
                                viewController.phonenumber.text = safeNumber
                                viewController.callContact.text = "911"
                                
                                viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtil)
                                expect(alertView.shown).to(beTrue())
                                expect(alertView.message).to(equal("\(SettingsViewController.PHONE_911)\n"))
                            }
                            
                            it ("texting fails validation") {
                                viewController.phonenumber.text = safeNumber
                                viewController.textContact.text = "911"
                                
                                viewController.saveSettings(managedObjectContext, alertView: alertView)
                                expect(alertView.shown).to(beTrue())
                                expect(alertView.message).to(equal("\(SettingsViewController.PHONE_911)\n"))
                            }
                        }
                    }
                    
                    it ("requires full name") {
                        viewController.phonenumber.text = "5555555555"
                        
                        viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtilNoError)
                        expect(alertView.shown).to(beTrue())
                        expect(alertView.message).to(equal(SettingsViewController.REQUIRE_FULL_NAME))
                    }
                    
                    it ("requires phone number") {
                        viewController.name.text = "Urist McTest"
                        
                        viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtilNoError)
                        expect(alertView.shown).to(beTrue())
                        expect(alertView.message).to(equal("\(SettingsViewController.REQUIRE_PHONE)\n"))
                    }

                    it ("requires either texting or calling to be enabled") {
                        viewController.name.text = "Urist McTest"
                        viewController.phonenumber.text = "5555555555"
                        viewController.contactPoliceSwitch.on = false
                        viewController.textEnabledSwitch.on = false
                        
                        viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtilNoError)
                        expect(alertView.shown).to(beTrue())
                        expect(alertView.message).to(equal("\(SettingsViewController.REQUIRE_TEXTING_OR_CALLING)\n"))
                    }

                    it ("does not allow multiple decimal places in the lockdown timer") {
                        viewController.name.text = "Urist McTest"
                        viewController.phonenumber.text = "5555555555"
                        viewController.lockdownTime.text = "5..5"
                        
                        viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtilNoError)
                        expect(alertView.shown).to(beTrue())
                        expect(alertView.message).to(equal("\(SettingsViewController.TIMER_MULTIPLE_DECIMALS)\n"))
                    }

                    it ("does not allow multiple decimal places in the release timer") {
                        viewController.name.text = "Urist McTest"
                        viewController.phonenumber.text = "5555555555"
                        viewController.releaseTime.text = ".1."
                        
                        viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtilNoError)
                        expect(alertView.shown).to(beTrue())
                        expect(alertView.message).to(equal("\(SettingsViewController.TIMER_MULTIPLE_DECIMALS)\n"))
                    }

                    it ("does not allow texting to be enabled without a contact phone number") {
                        viewController.name.text = "Urist McTest"
                        viewController.phonenumber.text = "5555555555"
                        viewController.textContact.text = ""
                        viewController.textEnabledSwitch.on = true
                        
                        viewController.saveSettings(managedObjectContext, alertView: alertView, communicationUtil: comUtilNoError)
                        expect(alertView.shown).to(beTrue())
                        expect(alertView.message).to(equal("\(SettingsViewController.TEXT_ENABLED_REQUIRE_CONTACT)\n"))
                    }
                }
            }
        }
    }
}