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
    static let SERVER_URL = "https://388c9f8a.ngrok.io"
    static let MESSAGE_URL = "\(CommunicationUtil.SERVER_URL)/message"
    static let FEATURE_URL = "\(CommunicationUtil.SERVER_URL)/feature"
    static let BUG_URL = "\(CommunicationUtil.SERVER_URL)/bug"

    static let UUID = NSUUID().UUIDString
    
    enum PhoneNumberError: ErrorType {
        case TooShort
        case TooLong
        case ContainsInvalidCharacters
        case CannotContact
    }
    
    func getPersonalPhone() -> String {
        var conf: Configuration!
        do {
            conf = try Configuration.get((UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!)
        } catch {
            return ""
        }
        
        if let phoneNumber = conf.phone_number {
            return phoneNumber
        } else {
            return ""
        }
    }
    
    /**
    Sends an sms using twilio by requesting to my twilio server ruby app
    
    :param: recipient the recipient phone number
    :param: body      the body of the text to send
    */
    func sendSms(recipients: [String], body: String) {
        for recipient in recipients {
            let request = Alamofire.request(Method.POST, CommunicationUtil.MESSAGE_URL, parameters: ["phone": getPersonalPhone(), "to": recipient, "body": body, "uuid": CommunicationUtil.UUID])
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
        
        // Finally, check if the number can be dialed (only on non-simulator)
        if (!(SimulatorUtility.isRunningSimulator)) {
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
    Emails me a feature idea with the given subject and description
    
    :param: subject
    :param: body
    */
    func sendFeature(subject: String, body: String) {
        let request = Alamofire.request(Method.POST, CommunicationUtil.FEATURE_URL, parameters: ["phone": getPersonalPhone(), "body": body, "subject": subject, "uuid": CommunicationUtil.UUID])
        request.validate()
        request.response { request, response, data, error in
            print(request)
            print(response)
            print(error)
        }
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
    
    /**
     Emails me a bug report with the given subject and description
    
     :param: subject
     :param: body
     */
    func sendBug(subject: String, body: String) {
        let request = Alamofire.request(Method.POST, CommunicationUtil.BUG_URL, parameters: ["phone": getPersonalPhone(), "body": body, "subject": subject, "uuid": CommunicationUtil.UUID])
        request.validate()
        request.response { request, response, data, error in
            print(request)
            print(response)
            print(error)
        }
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