//
//  ComunicationUtilSpec.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/6/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation
import Nimble
import Quick
import MessageUI
@testable import Stroll_Safe

class CommunicationUtilSpec: QuickSpec {
    
    override func spec() {
        class MFMessageComposeViewControllerMock: MFMessageComposeViewController {
            var sendMessageCalled = false
            
        }
        
        describe("the communications util") {
            it ("can send a text message") {
                
            }
            
            it ("can initiate a phone call") {
                
            }
        }
    }
    
}