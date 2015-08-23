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

class ConfigurationSpec: QuickSpec {
    
    override func spec() {
        describe("The Configuration Model") {
            var managedObjectContext: NSManagedObjectContext!
            
            beforeEach {
                managedObjectContext = TestUtils().setUpInMemoryManagedObjectContext()
            }
            
            it ("throws an error when there is no stored configuration") {
                expect{ try Configuration.get(managedObjectContext) }.to(throwError())
            }
            
            it ("get returns the saved configuration values") {
                let passcode = "1234"
                let lockdown_duration = 30
                let release_duration = 2
                let sms_recipients = "2222222222,2222222222"
                let call_recipient = "1234567890"
                let sms_body = "body"
                let full_name = "Noah Prince"
                let phone_number = "5555555555"
                
                let conf = TestUtils().getNewConfigurationItem(managedObjectContext)
                conf.passcode = passcode
                conf.lockdown_duration = lockdown_duration
                conf.release_duration = release_duration
                conf.sms_recipients = sms_recipients
                conf.call_recipient = call_recipient
                conf.sms_body = sms_body
                conf.full_name = full_name
                conf.phone_number = phone_number
                try! managedObjectContext.save()
                
                let storedConf = try! Configuration.get(managedObjectContext)
                expect(storedConf.passcode).to(equal(passcode))
                expect(storedConf.lockdown_duration).to(equal(lockdown_duration))
                expect(storedConf.release_duration).to(equal(release_duration))
                expect(storedConf.sms_recipients).to(equal(sms_recipients))
                expect(storedConf.call_recipient).to(equal(call_recipient))
                expect(storedConf.sms_body).to(equal(sms_body))
                expect(storedConf.full_name).to(equal(full_name))
                expect(storedConf.phone_number).to(equal(phone_number))
            }
            
            it ("has default values for every core application need, except passcode") {
                TestUtils().getNewConfigurationItem(managedObjectContext).passcode = "1234"
                try! managedObjectContext.save()
                
                let storedConf = try! Configuration.get(managedObjectContext)
                expect(storedConf.lockdown_duration).toNot(beNil())
                expect(storedConf.release_duration).toNot(beNil())
                expect(storedConf.sms_body).toNot(beNil())
                expect(storedConf.call_recipient).to(equal(SettingsViewController.POLICE_PHONE_NUMBER))
                
                expect(storedConf.full_name).to(beNil())
                expect(storedConf.phone_number).to(beNil())
                expect(storedConf.sms_recipients).to(beNil())
            }
        }
    }
}