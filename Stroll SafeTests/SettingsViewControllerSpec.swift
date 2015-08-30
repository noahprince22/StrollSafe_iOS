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
            
            var managedObjectContext: NSManagedObjectContext!
            beforeEach {
                managedObjectContext = TestUtils().setUpInMemoryManagedObjectContext()
                try! TestUtils().storeConfWithPass("1234", managedObjectContext: managedObjectContext)

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                viewController =
                    storyboard.instantiateViewControllerWithIdentifier(
                        "settingsViewController") as! Stroll_Safe.SettingsViewController
                
                viewController.beginAppearanceTransition(true, animated: false)
                viewController.endAppearanceTransition()
                viewController.initSavedValues(managedObjectContext)
            }
            
            describe ("saving the settings") {
                describe ("good input") {
                    let fullName = "Urist McTest"
                    let phoneNumber = "12345678910"
                    
                    var comUtil: CommunicationUtilNonErrorMock!
                    beforeEach {
                        viewController.name.text = fullName
                        viewController.phonenumber.text = phoneNumber
                        comUtil = CommunicationUtilNonErrorMock()
                    }
                    
                    it ("does not populate the text body when using the default values") {
                        expect(viewController.textBody.text).to(equal(""))
                    }
                    
                    it ("does not populate both timers when using default values") {
                        expect(viewController.releaseTime.text).to(equal(""))
                        expect(viewController.lockdownTime.text).to(equal(""))
                    }
                    
                    it ("populates all values with the saved values") {
                        let passcode = "1234"
                        let lockdown_duration = 30
                        let release_duration = 2
                        let sms_recipient = "2222222222"
                        let call_recipient = "1234567890"
                        let sms_body = "body"
                        let full_name = "Noah Prince"
                        let phone_number = "5555555555"
                        
                        let conf = try! Configuration.get(managedObjectContext)
                        conf.passcode = passcode
                        conf.lockdown_duration = lockdown_duration
                        conf.release_duration = release_duration
                        conf.sms_recipients = sms_recipient
                        conf.call_recipient = call_recipient
                        conf.sms_body = sms_body
                        conf.full_name = full_name
                        conf.phone_number = phone_number
                        try! managedObjectContext.save()
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        viewController =
                            storyboard.instantiateViewControllerWithIdentifier(
                                "settingsViewController") as! Stroll_Safe.SettingsViewController
                        
                        viewController.beginAppearanceTransition(true, animated: false)
                        viewController.endAppearanceTransition()
                        viewController.initSavedValues(managedObjectContext)
                        
                        expect(viewController.name.text).to(equal(full_name))
                        expect(viewController.phonenumber.text).to(equal(phone_number))
                        expect(viewController.callContact.text).to(equal(call_recipient))
                        expect(viewController.textContact.text).to(equal(sms_recipient))
                        expect(viewController.textBody.text).to(equal(sms_body))
                        expect(viewController.lockdownTime.text).to(equal("\(lockdown_duration)"))
                        expect(viewController.releaseTime.text).to(equal("\(release_duration)"))
                        expect(viewController.contactPoliceSwitch.on).to(beFalse())
                        expect(viewController.textEnabledSwitch.on).to(beTrue())
                    }
                    
                    
                    it ("leaves the contact police switch off if it was initially off during saving") {
                        let full_name = "Noah Prince"
                        let phone_number = "5555555555"
                        
                        viewController.phonenumber.text = phone_number
                        viewController.name.text = full_name
                        viewController.contactPoliceSwitch.on = false
                        viewController.textContact.text = phone_number
                        viewController.textEnabledSwitch.on = true
                        viewController.saveSettings(managedObjectContext)
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        viewController =
                            storyboard.instantiateViewControllerWithIdentifier(
                                "settingsViewController") as! Stroll_Safe.SettingsViewController
                        
                        viewController.beginAppearanceTransition(true, animated: false)
                        viewController.endAppearanceTransition()
                        viewController.initSavedValues(managedObjectContext)
                        
                        expect(viewController.callContact.text).to(equal(""))
                        expect(viewController.contactPoliceSwitch.on).to(beFalse())
                        expect(viewController.textEnabledSwitch.on).to(beTrue())
                    }
                    
                    it ("leaves the contact police switch on if it was on during saving") {
                        let full_name = "Noah Prince"
                        let phone_number = "5555555555"
                        
                        viewController.phonenumber.text = phone_number
                        viewController.name.text = full_name
                        viewController.saveSettings(managedObjectContext)
                        viewController.contactPoliceSwitch.on = true
                        viewController.saveSettings(managedObjectContext)
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        viewController =
                            storyboard.instantiateViewControllerWithIdentifier(
                                "settingsViewController") as! Stroll_Safe.SettingsViewController
                        
                        viewController.beginAppearanceTransition(true, animated: false)
                        viewController.endAppearanceTransition()
                        viewController.initSavedValues(managedObjectContext)
                        
                        expect(viewController.callContact.text).to(equal(""))
                        expect(viewController.contactPoliceSwitch.on).to(beTrue())
                        expect(viewController.textEnabledSwitch.on).to(beFalse())
                    }
                    
                    it ("saves the full name and phone number") {
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal(""))
                        
                        let storedConf = try! Configuration.get(managedObjectContext)
                        expect(storedConf.full_name).to(equal(fullName))
                        expect(storedConf.phone_number).to(equal(phoneNumber))
                    }
                    
                    it ("saves the call contact") {
                        let callRecipient = "1234567890"
                        viewController.contactPoliceSwitch.on = false
                        viewController.callContact.text = callRecipient
                        
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal(""))
                        
                        let storedConf = try! Configuration.get(managedObjectContext)
                        expect(storedConf.call_recipient).to(equal(callRecipient))
                    }
                    
                    it ("saves the text contact and body") {
                        let smsRecipient = "15556667788"
                        let smsBody = "Hello"
                        viewController.textContact.text = smsRecipient
                        viewController.textBody.text = smsBody
                        viewController.textEnabledSwitch.on = true
                        
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal(""))
                        
                        let storedConf = try! Configuration.get(managedObjectContext)
                        expect(storedConf.sms_recipients).to(equal(smsRecipient))
                        expect(storedConf.sms_body).to(equal(smsBody))
                    }
                    
                    it ("does not save the text contact if text is disabled") {
                        let smsRecipient = "15556667788"
                        let smsBody = "Hello"
                        viewController.textContact.text = smsRecipient
                        viewController.textBody.text = smsBody
                        viewController.textEnabledSwitch.on = false
                        
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal(""))
                        
                        let storedConf = try! Configuration.get(managedObjectContext)
                        expect(storedConf.sms_recipients).to(beNil())
                    }
                    
                    it ("does save the text body if text is disabled") {
                        let smsRecipient = "15556667788"
                        let smsBody = "Hello"
                        viewController.textContact.text = smsRecipient
                        viewController.textBody.text = smsBody
                        viewController.textEnabledSwitch.on = false
                        
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal(""))
                        
                        let storedConf = try! Configuration.get(managedObjectContext)
                        expect(storedConf.sms_recipients).to(beNil())
                        expect(storedConf.sms_body).to(equal(smsBody))
                    }
                    
                    it ("saves the lockdown timer with decimals") {
                        let lockdownDuration = ".2"
                        viewController.lockdownTime.text = lockdownDuration
                        viewController.contactPoliceSwitch.on = false
                        viewController.callContact.text = "5558675309"
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal(""))
                        
                        let storedConf = try! Configuration.get(managedObjectContext)
                        expect(storedConf.lockdown_duration) == 0.2
                    }
                    
                    it ("saves the default lockdown timer when empty") {
                        viewController.lockdownTime.text = ""
                        viewController.contactPoliceSwitch.on = false
                        viewController.callContact.text = "5558675309"
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal(""))
                        
                        let storedConf = try! Configuration.get(managedObjectContext)
                        expect(storedConf.lockdown_duration) == 20
                    }
                    
                    it ("saves the default release timer when empty") {
                        viewController.releaseTime.text = ""
                        viewController.contactPoliceSwitch.on = false
                        viewController.callContact.text = "5558675309"
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal(""))
                        
                        let storedConf = try! Configuration.get(managedObjectContext)
                        expect(storedConf.release_duration) == 1.5
                    }
                    
                    it ("saves the lockdown timer with no decimals") {
                        let lockdownDuration = "826"
                        viewController.lockdownTime.text = lockdownDuration
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal(""))
                        
                        let storedConf = try! Configuration.get(managedObjectContext)
                        expect(storedConf.lockdown_duration) == 826
                    }
                    
                    it ("saves the release timer with decimals") {
                        let releaseDuration = "0.2"
                        viewController.releaseTime.text = releaseDuration
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal(""))
                        
                        let storedConf = try! Configuration.get(managedObjectContext)
                        expect(storedConf.release_duration) == 0.2
                    }
                    
                    
                    it ("saves the release timer with no decimals") {
                        let releaseDuration = "200"
                        viewController.releaseTime.text = releaseDuration
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal(""))
                        
                        let storedConf = try! Configuration.get(managedObjectContext)
                        expect(storedConf.release_duration) == 200
                    }
                    
                    it ("saves the champaign police when contact police switch is on") {
                        viewController.contactPoliceSwitch.on = true
                        viewController.callContact.text = ""
                        
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal(""))
                        
                        let storedConf = try! Configuration.get(managedObjectContext)
                        expect(storedConf.call_recipient).to(equal(SettingsViewController.POLICE_PHONE_NUMBER))
                    }
                    
                    it ("deletes the stored text contact if texting is disabled") {
                        viewController.contactPoliceSwitch.on = true
                        viewController.callContact.text = ""
                        viewController.textContact.text = "5555555555"
                        viewController.textBody.text = "hello"
                        viewController.textEnabledSwitch.on = true
                        
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal(""))
                        
                        // Get another viewcontroller
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        viewController =
                            storyboard.instantiateViewControllerWithIdentifier(
                                "settingsViewController") as! Stroll_Safe.SettingsViewController
                        
                        viewController.beginAppearanceTransition(true, animated: false)
                        viewController.endAppearanceTransition()
                        viewController.initSavedValues(managedObjectContext)
                        
                        viewController.textEnabledSwitch.on = false
                        
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal(""))
                        
                        let storedConf = try! Configuration.get(managedObjectContext)
                        expect(storedConf.sms_recipients).to(beNil())
                        expect(storedConf.sms_body).toNot(beNil())
                    }
                }
                
                describe ("bad input") {
                    var comUtil: CommunicationUtilErrorMock!
                    var comUtilNoError: CommunicationUtilNonErrorMock!
                    
                    beforeEach {
                        comUtil = CommunicationUtilErrorMock()
                        comUtilNoError = CommunicationUtilNonErrorMock()
                    }
                    
                    // Don't need to check for odd characters, keyboard only allows numbers
                    describe ("incorrect phone numbers") {
                        beforeEach {
                            viewController.callContact.text = ""
                            viewController.phonenumber.text = ""
                            viewController.textContact.text = ""
                            viewController.contactPoliceSwitch.on = true
                        }
                        
                        describe ("too short a phone number as input") {
                            beforeEach {
                                comUtil.error = CommunicationUtilErrorMock.PhoneNumberError.TooShort
                                
                                viewController.name.text = "Urist McTest"
                            }
                            
                            it ("personal fails") {
                                viewController.phonenumber.text = "1234567"
                                
                                expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal("- Personal \(SettingsViewController.PHONE_TOO_SHORT)\n"))
                            }
                            
                            it ("call fails validation") {
                                viewController.phonenumber.text = safeNumber
                                viewController.callContact.text = "1234567"
                                
                                expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal("- Calling \(SettingsViewController.PHONE_TOO_SHORT)\n"))
                            }
                            
                            it ("text fails validation") {
                                viewController.phonenumber.text = safeNumber
                                viewController.textContact.text = "1234567"
                                
                                expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal("- Texting \(SettingsViewController.PHONE_TOO_SHORT)\n"))
                            }
                        }
                        
                        describe ("too long phone number as input") {
                            beforeEach {
                                comUtil.error = CommunicationUtilErrorMock.PhoneNumberError.TooLong
                                viewController.name.text = "Urist McTest"
                            }
                            
                            it ("personal fails validation") {
                                viewController.phonenumber.text = "345678910118"
                                
                                expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal("- Personal \(SettingsViewController.PHONE_TOO_LONG)\n"))
                            }
                            
                            it ("call fails validation") {
                                viewController.phonenumber.text = safeNumber
                                viewController.callContact.text = "345678910118"
                                
                                expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal("- Calling \(SettingsViewController.PHONE_TOO_LONG)\n"))
                            }
                            
                            it ("text fails validation") {
                                viewController.phonenumber.text = safeNumber
                                viewController.textContact.text = "345678910118"
                                
                                expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal("- Texting \(SettingsViewController.PHONE_TOO_LONG)\n"))
                            }
                            
                        }
                        
                        describe("911 as input") {
                            beforeEach {
                                viewController.name.text = "Urist McTest"
                            }
                            it ("personal fails validation") {
                                viewController.phonenumber.text = "911"
                                comUtil.error = CommunicationUtilErrorMock.PhoneNumberError.TooShort
                                
                                expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal("- Personal \(SettingsViewController.PHONE_TOO_SHORT)\n"))
                            }
                            
                            it ("calling fails validation") {
                                viewController.phonenumber.text = safeNumber
                                viewController.callContact.text = "911"
                                
                                expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal("- \(SettingsViewController.PHONE_911)\n"))
                            }
                            
                            it ("texting fails validation") {
                                viewController.phonenumber.text = safeNumber
                                viewController.textContact.text = "911"
                                
                                expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtil)).to(equal("- \(SettingsViewController.PHONE_911)\n"))
                            }
                        }
                    }
                    
                    it ("requires full name") {
                        viewController.phonenumber.text = "5555555555"
                        
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtilNoError)).to(equal("- \(SettingsViewController.REQUIRE_FULL_NAME)\n"))
                    }
                    
                    it ("requires phone number") {
                        viewController.name.text = "Urist McTest"
                        
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtilNoError)).to(equal("- \(SettingsViewController.REQUIRE_PHONE)\n"))
                    }

                    it ("requires either texting or calling to be enabled") {
                        viewController.name.text = "Urist McTest"
                        viewController.phonenumber.text = "5555555555"
                        viewController.callContact.text = ""
                        viewController.contactPoliceSwitch.on = false
                        viewController.textEnabledSwitch.on = false
                        
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtilNoError)).to(equal("- \(SettingsViewController.REQUIRE_TEXTING_OR_CALLING)\n"))
                    }

                    it ("does not allow multiple decimal places in the lockdown timer") {
                        viewController.name.text = "Urist McTest"
                        viewController.phonenumber.text = "5555555555"
                        viewController.lockdownTime.text = "10..5"
                        
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtilNoError)).to(equal("- \(SettingsViewController.TIMER_MULTIPLE_DECIMALS)\n"))
                    }

                    it ("does not allow multiple decimal places in the release timer") {
                        viewController.name.text = "Urist McTest"
                        viewController.phonenumber.text = "5555555555"
                        viewController.releaseTime.text = ".1."
                        
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtilNoError)).to(equal("- \(SettingsViewController.TIMER_MULTIPLE_DECIMALS)\n"))
                    }

                    it ("does not allow texting to be enabled without a contact phone number") {
                        viewController.name.text = "Urist McTest"
                        viewController.phonenumber.text = "5555555555"
                        viewController.textContact.text = ""
                        viewController.textEnabledSwitch.on = true
                        
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtilNoError)).to(equal("- \(SettingsViewController.TEXT_ENABLED_REQUIRE_CONTACT)\n"))
                    }
                    
                    it ("cannot contact the police if the lockdown timer is less than 10 seconds") {
                        viewController.name.text = "Urist McTest"
                        viewController.phonenumber.text = "5555555555"
                        viewController.contactPoliceSwitch.on = true
                        viewController.lockdownTime.text = "\(SettingsViewController.POLICE_MINIMUM_LOCKDOWN_TIME_THRESHOLD - 0.1)"
                        
                        expect(viewController.saveSettings(managedObjectContext, communicationUtil: comUtilNoError)).to(equal("- \(SettingsViewController.POLICE_MINIMUM_LOCKDOWN_TIME)\n"))
                    }
                }
            }
        }
    }
}