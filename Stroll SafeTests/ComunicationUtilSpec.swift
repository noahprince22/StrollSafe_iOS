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
@testable import Stroll_Safe

class CommunicationUtilSpec: QuickSpec {
    
    override func spec() {
        describe ("the communications util") {
            let util = CommunicationUtil()

            describe ("phone number formatting") {
                describe ("invalid phone numbers") {
                    it ("fails on short number imput") {
                        expect { try util.formatNumber("1234567") }.to(throwError())
                    }
                    
                    it ("fails on too long number input") {
                        expect { try util.formatNumber("123 456 7888 999") }.to(throwError())
                    }
                    
                    it ("fails if there are any letters") {
                        expect { try util.formatNumber("abc 123 bbca") }.to(throwError())
                    }
                }
                
                describe ("valid phone numbers") {
                    it ("formats out parenthesis") {
                        expect(try! util.formatNumber("(123)4567891")).to(equal("1234567891"))
                    }
                    
                    it ("formats out dashes") {
                        expect(try! util.formatNumber("1-(123)456-7891")).to(equal("11234567891"))
                    }
                    
                    it ("formats out pluses") {
                        expect(try! util.formatNumber("1+(123)456-7891")).to(equal("11234567891"))
                    }
                    
                    it ("formats out spaces") {
                        expect(try! util.formatNumber("(123) 456-7891")).to(equal("1234567891"))
                    }
                    
                    it ("does nothing to the correct format") {
                        expect(try! util.formatNumber("1234567891")).to(equal("1234567891"))
                    }
                }
            }
        }
    }
}