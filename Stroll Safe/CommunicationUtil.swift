//
//  CommunicationsUtil.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/6/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation
import Alamofire

class CommunicationUtil {
    static let MESSAGE_URL = "https://697c8438.ngrok.io/message"
    
    enum PhoneNumberError: ErrorType {
        case TooShort
        case TooLong
        case ContainsInvalidCharacters
        case CannotContact
    }
    
    /**
    Sends an sms using twilio by requesting to my twilio server ruby app
    
    :param: recipient the recipient phone number
    :param: body      the body of the text to send
    */
    func sendSms(recipients: [String], body: String) {
        for recipient in recipients {
            let request = Alamofire.request(.POST, CommunicationUtil.MESSAGE_URL, parameters: ["to": recipient, "body": body])
            request.validate()
            request.response { request, response, data, error in
                print(request)
                print(response)
                print(error)
            }
        }
    }
    
    /**
    Initiates a phone call to the recipient number
    
    :param: recipient the recipient phone number
    */
    func sendCall(recipient: String) {
        let url:NSURL = NSURL(string: "tel://\(recipient)")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    /**
    Formats a phone number to be all numbers, no spaces
    raises exceptions if it's in invalid number
    
    :param: number the phone number
    */
    func formatNumber(number: String) throws -> String {
        let strippedPhoneNumber = "".join(number.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))
        
        if (containsInvalidCharacters(strippedPhoneNumber)) {
            throw PhoneNumberError.ContainsInvalidCharacters
        }
        
        if (strippedPhoneNumber.characters.count < 10) {
            throw PhoneNumberError.TooShort
        }
        
        // Allow optional 1+ before number
        if (strippedPhoneNumber.characters.count > 11) {
            throw PhoneNumberError.TooLong
        }
        
        // Finally, check if the number can be dialed
        if (!testing) {
            if let phoneCallURL:NSURL = NSURL(string:"tel://"+"\(strippedPhoneNumber)") {
                let application:UIApplication = UIApplication.sharedApplication()
                if (!application.canOpenURL(phoneCallURL)) {
                    throw PhoneNumberError.CannotContact
                }
            }
        }
        
        return strippedPhoneNumber
    }
    
    /**
    Splits comma separated numbers into an array of strings
    "5555555555,2222222222" -> ["5555555555", "2222222222"]
    
    :param: numbers the phone numbers
    
    :returns: an array of the phone numbers
    */
    func csvNumbersToArray(numbers: String) -> [String] {
        return numbers.characters.split {$0 == ","}.map { String($0) }
    }
    
    func containsInvalidCharacters(input: String) -> Bool {
        for chr in input.characters {
            if (!(chr >= "0" && chr <= "9")) {
                return true
            }
        }
        
        return false
    }
}