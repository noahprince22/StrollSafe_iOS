//
//  SettingsViewController.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/10/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UITableViewController, UITextFieldDelegate, UISearchBarDelegate{
    
    static let PHONE_TOO_LONG = "phone number was too long. Phone numbers must be 10-11 characters."
    static let PHONE_TOO_SHORT = "phone number was too short. Phone numbers must be 10-11 characters."
    static let PHONE_911 = "Use the 'Contact Police' switch to contact university police, an app calling '911' directly is not supported on iOS"
    static let PHONE_CANNOT_CONTACT = "cannot contact the number provided"
    static let PHONE_INVALID_CHARS = "had invalid characters"
    static let REQUIRE_FULL_NAME = "Full Name was empty"
    static let REQUIRE_PHONE = "Phone Number was emptry"
    static let REQUIRE_TEXTING_OR_CALLING = "One of texting or calling must be enabled"
    static let TEXT_ENABLED_REQUIRE_CONTACT = "Texting cannot be enabled without a phone number to contact"
    static let TIMER_MULTIPLE_DECIMALS = "Timer values cannot have multiple decimals"
    
    @IBOutlet weak var contactPoliceSwitch: UISwitch!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phonenumber: UITextField!
    @IBOutlet weak var lockdownTime: UITextField!
    @IBOutlet weak var textContact: UITextField!
    @IBOutlet weak var callContact: UITextField!
    @IBOutlet weak var releaseTime: UITextField!
    @IBOutlet weak var done: UIBarButtonItem!
    @IBOutlet weak var textBody: UITextField!
    var contactSearchVC: ContactSearchViewController!
    @IBOutlet weak var textEnabledSwitch: UISwitch!
    
    @IBAction func donePress(sender: UIBarButtonItem) {
        saveSettings()
        self.performSegueWithIdentifier("settingsToMainSegue", sender: nil)
    }
    
    @IBAction func callContactDidChange(sender: UITextField) {
        contactPoliceSwitch.on = false
    }

    func saveSettings(managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!, alertView: UIAlertView = UIAlertView(), communicationUtil: CommunicationUtil = CommunicationUtil()) {
        alertView.title = "Error"
        alertView.message = ""
        alertView.addButtonWithTitle("Ok")
        
        var formattedCallContact = ""
        var formattedTextContact = ""
        var formattedPersonalContact = ""
        
        

        // Test that all phone numbers are valid (ie not too long, too short, unreachable, 911)
        if (self.callContact.text == "911") {
            alertView.message! += "\(SettingsViewController.PHONE_911)\n"
        }
        else if let callContact = self.callContact.text {
            if (callContact != "") {
                let callValidation = validatePhoneNumber(callContact, communicationUtil: communicationUtil)
                if let error = callValidation.1 {
                    alertView.message! += "Calling \(error)\n"
                    formattedCallContact = callValidation.0
                }
            }
        }
        
        if (self.textContact.text == "911") {
            alertView.message! += "\(SettingsViewController.PHONE_911)\n"
        }
        else if let textContact = self.textContact.text {
            if (textContact != "") {
                let textValidation = validatePhoneNumber(textContact, communicationUtil: communicationUtil)
                if let error = textValidation.1 {
                    alertView.message! += "Texting \(error)\n"
                    formattedTextContact = textValidation.0
                }
            }
        }
        
        // The person's own phone number should be valid and present
        if let personalContact = self.phonenumber.text {
            if (personalContact != "") {
                let personalValidation = validatePhoneNumber(personalContact, communicationUtil: communicationUtil)
                if let error = personalValidation.1 {
                    alertView.message! += "Personal \(error)\n"
                    formattedPersonalContact = personalValidation.0
                }
            } else {
                alertView.message! += "\(SettingsViewController.REQUIRE_PHONE)\n"
            }
        } else {
            alertView.message! += "\(SettingsViewController.REQUIRE_PHONE)\n"
        }
    
        // Require full name
        if let fullName = self.name.text {
            if (fullName == "") {
                alertView.message! += SettingsViewController.REQUIRE_FULL_NAME
            }
        } else {
            alertView.message! += SettingsViewController.REQUIRE_FULL_NAME
        }
        
        // Either texting or calling should be enabled
        if (!self.textEnabledSwitch.on && !self.contactPoliceSwitch.on && formattedCallContact == "") {
            alertView.message! += "\(SettingsViewController.REQUIRE_TEXTING_OR_CALLING)\n"
        }
        
        // Validate that the timers don't have multiple decimals or something weird
        if (countOccurencesOfCharInWord(self.lockdownTime.text!, char: ".") > 1 || countOccurencesOfCharInWord(self.releaseTime.text!, char: ".") > 1) {
            alertView.message! += "\(SettingsViewController.TIMER_MULTIPLE_DECIMALS)\n"
        }
        
        // Texting requires a contact phone number
        if (self.textEnabledSwitch.on && formattedTextContact == "") {
            alertView.message! += "\(SettingsViewController.TEXT_ENABLED_REQUIRE_CONTACT)\n"
        }
        
        alertView.show()
    }
    
    func countOccurencesOfCharInWord(word: String, char: String) -> Int {
        var count = 0
        for char in word.characters {
            if (char == char) {
                count += 1
            }
        }
        
        return count
    }

    /**
    Validates a given phone number and returns the formatted number and 
       any errors
    
    :param: number the phone number
    :param: communicationUtil the communicationUtil to formatNumber with
    
    :returns: a tuple, first being the formatted number, second being any error messages
    */
    func validatePhoneNumber(number: String, communicationUtil: CommunicationUtil) -> (String, String?) {
        var formattedNumber = ""
        var error: String?
        
        do {
            formattedNumber = try communicationUtil.formatNumber(number)
        } catch CommunicationUtil.PhoneNumberError.TooLong {
            error = SettingsViewController.PHONE_TOO_LONG
        } catch CommunicationUtil.PhoneNumberError.TooShort {
            error = SettingsViewController.PHONE_TOO_SHORT
        } catch CommunicationUtil.PhoneNumberError.ContainsInvalidCharacters {
            error = SettingsViewController.PHONE_INVALID_CHARS
        } catch CommunicationUtil.PhoneNumberError.CannotContact {
            error = SettingsViewController.PHONE_CANNOT_CONTACT
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            abort()
        }
        
        return (formattedNumber, error)
    }
    
    @IBAction func resetPasscode(sender: UIButton) {
        self.performSegueWithIdentifier("resetPassSegue", sender: self)
    }
    
    @IBAction func callAddressBook(sender: UIButton) {
        let contactSearchVC = self.storyboard?.instantiateViewControllerWithIdentifier("ContactSearchViewController") as! ContactSearchViewController
        contactSearchVC.setCompletion({ selectedNumber in
            if (selectedNumber != "") {
                do {
                    self.callContact.text = try CommunicationUtil().formatNumber(selectedNumber)
                } catch let error as NSError {
                    NSLog("This shouldn't happen, but is recoverable")
                    NSLog(error.localizedDescription)
                }
                
                self.contactPoliceSwitch.on = false
            }
        })
        
        self.presentViewController(contactSearchVC, animated: true, completion: nil)
    }
    
    @IBAction func textAddressBook(sender: UIButton) {
        let contactSearchVC = self.storyboard?.instantiateViewControllerWithIdentifier("ContactSearchViewController") as! ContactSearchViewController
        contactSearchVC.setCompletion({ selectedNumber in
            if (selectedNumber != "") {
                self.textContact.text = selectedNumber
            }
        })
        
        self.presentViewController(contactSearchVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.name.delegate = self
        self.phonenumber.delegate = self
        //self.callContact.delegate = self
        //self.textContact.delegate = self
        self.textBody.delegate = self
        self.lockdownTime.delegate = self
        self.releaseTime.delegate = self
        
        //self.callContact.delegate = ContactSearchDelegate( { _ in
            //println("hello")        })
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func contactPoliceSwitch(sender: AnyObject) {
        self.callContact.text = ""
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        switch section {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 2
        case 3:
            return 2
        case 4:
            return 1
        default:
            return 0
        }
    }
    
    /**
     Will make text fields close on return
    
    :param: userText <#userText description#>
    
    :returns: <#return value description#>
    */
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }
}
