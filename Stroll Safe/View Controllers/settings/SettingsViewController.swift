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
    static let REQUIRE_FULL_NAME = "Full Name is required"
    static let REQUIRE_PHONE = "Phone Number is required"
    static let REQUIRE_TEXTING_OR_CALLING = "One of texting or calling must be enabled"
    static let TEXT_ENABLED_REQUIRE_CONTACT = "Texting cannot be enabled without a phone number to contact"
    static let TIMER_MULTIPLE_DECIMALS = "Timer values cannot have multiple decimals"
    static let POLICE_MINIMUM_LOCKDOWN_TIME_THRESHOLD = 10.0
    static let POLICE_MINIMUM_LOCKDOWN_TIME = "Lockdown to Contact duration must be greater than \(SettingsViewController.POLICE_MINIMUM_LOCKDOWN_TIME_THRESHOLD) seconds when contacting the police. This is to prevent accidental calling of the police as much as possible"
    static let REQUIRE_RELEASE = "The release to lockdown duration is required"
    static let REQUIRE_LOCKDOWN = "The lockdown to contact duration is required"
    static let POLICE_PHONE_NUMBER = "4444444466"
    
    @IBOutlet weak var contactPoliceSwitch: UISwitch!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var lockdownTime: UITextField!
    @IBOutlet weak var releaseTime: UITextField!
    @IBOutlet weak var phonenumber: UITextField!
    @IBOutlet weak var textContact: UITextField!
    @IBOutlet weak var callContact: UITextField!
    @IBOutlet weak var textBody: UITextField!
    var contactSearchVC: ContactSearchViewController!
    @IBOutlet weak var textEnabledSwitch: UISwitch!
        
    @IBAction func callContactDidChange(sender: UITextField) {
        contactPoliceSwitch.on = false
    }
    
    @IBAction func textContactDidChange(sender: UITextField) {
        if (sender.text == "") {
            self.textEnabledSwitch.on = false
        } else {
            self.textEnabledSwitch.on = true
        }
    }
    

    /**
    Attempts to save all settings
    
    :param: managedObjectContext the managed object context to save to
    :param: alertView            the alert view to present issues
    :param: communicationUtil    the communication utility used to format phone numbers
    
    :returns: whether or not the save was successful
    */
    func saveSettings(managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!, alertView: UIAlertView = UIAlertView(), communicationUtil: CommunicationUtil = CommunicationUtil()) -> Bool {
        alertView.title = "Oops!"
        alertView.message = ""
        alertView.addButtonWithTitle("Ok")
        
        var formattedCallContact = ""
        var formattedTextContact = ""
        var formattedPersonalContact = ""
        
        // The person's own phone number should be valid and present
        if let personalContact = self.phonenumber.text {
            if (personalContact != "") {
                let personalValidation = validatePhoneNumber(personalContact, communicationUtil: communicationUtil)
                if let error = personalValidation.1 {
                    alertView.message! += alertItem("Personal \(error)")
                } else {
                    formattedPersonalContact = personalValidation.0
                }
            } else {
                alertView.message! += alertItem(SettingsViewController.REQUIRE_PHONE)
            }
        } else {
            alertView.message! += alertItem(SettingsViewController.REQUIRE_PHONE)
        }
        
        // Require full name
        if let fullName = self.name.text {
            if (fullName == "") {
                alertView.message! += alertItem(SettingsViewController.REQUIRE_FULL_NAME)
            }
        } else {
            alertView.message! += alertItem(SettingsViewController.REQUIRE_FULL_NAME)
        }

        // Test that all phone numbers are valid (ie not too long, too short, unreachable, 911)
        if (self.callContact.text == "911") {
            alertView.message! += alertItem(SettingsViewController.PHONE_911)
        }
        else if let callContact = self.callContact.text {
            if (callContact != "") {
                let callValidation = validatePhoneNumber(callContact, communicationUtil: communicationUtil)
                if let error = callValidation.1 {
                    alertView.message! += alertItem("Calling \(error)")
                } else {
                    formattedCallContact = callValidation.0
                }
            }
        }
        
        if (self.textContact.text == "911") {
            alertView.message! += alertItem(SettingsViewController.PHONE_911)
        }
        else if let textContact = self.textContact.text {
            if (textContact != "") {
                let textValidation = validatePhoneNumber(textContact, communicationUtil: communicationUtil)
                if let error = textValidation.1 {
                    alertView.message! += alertItem("Texting \(error)")
                } else {
                    formattedTextContact = textValidation.0
                }
            }
        }
        
        // Texting requires a contact phone number
        if (self.textEnabledSwitch.on && formattedTextContact == "") {
            alertView.message! += alertItem(SettingsViewController.TEXT_ENABLED_REQUIRE_CONTACT)
        }
        
        // Either texting or calling should be enabled
        if (!self.textEnabledSwitch.on && !self.contactPoliceSwitch.on && formattedCallContact == "") {
            alertView.message! += alertItem(SettingsViewController.REQUIRE_TEXTING_OR_CALLING)
        }
        
        // Validate that the timers have values and don't have multiple decimals or something weird
        if let lockdown = self.lockdownTime.text {
            if (lockdown != "") {
                if (countOccurencesOfCharInWord(lockdown, char: ".") > 1) {
                    alertView.message! += alertItem(SettingsViewController.TIMER_MULTIPLE_DECIMALS)
                }
                
                // Lockdown duration cannot be greater than a certain threshold when contacting police
                //   this is to prevent false calls
                if ((self.lockdownTime.text! as NSString).doubleValue < SettingsViewController.POLICE_MINIMUM_LOCKDOWN_TIME_THRESHOLD && self.contactPoliceSwitch.on) {
                    alertView.message! += alertItem(SettingsViewController.POLICE_MINIMUM_LOCKDOWN_TIME)
                }
            } else {
                alertView.message! += alertItem(SettingsViewController.REQUIRE_LOCKDOWN)
            }
        } else {
            alertView.message! += alertItem(SettingsViewController.REQUIRE_LOCKDOWN)
        }
        
        if let release = self.releaseTime.text {
            if (release != "") {
                if (countOccurencesOfCharInWord(release, char: ".") > 1) {
                    alertView.message! += alertItem(SettingsViewController.TIMER_MULTIPLE_DECIMALS)
                }
            } else {
                alertView.message! += alertItem(SettingsViewController.REQUIRE_RELEASE)
            }
        } else {
            alertView.message! += alertItem(SettingsViewController.REQUIRE_RELEASE)
        }
        
        // Save everything if there was no error
        if (alertView.message == "") {
            let conf = try! Configuration.get(managedObjectContext)
            
            conf.full_name = self.name.text
            conf.phone_number = formattedPersonalContact
            
            if (formattedCallContact == "") {
                conf.call_recipient = SettingsViewController.POLICE_PHONE_NUMBER
            } else {
                conf.call_recipient = formattedCallContact
            }
            
            if (self.textEnabledSwitch.on) {
                conf.sms_recipients = formattedTextContact
                conf.sms_body = self.textBody.text
            }
            
            conf.lockdown_duration = (self.lockdownTime.text! as NSString).doubleValue
            conf.release_duration = (self.releaseTime.text! as NSString).doubleValue
            
            do {
                try managedObjectContext.save()
                return true
            } catch let error as NSError {
                NSLog("Unresolved error while storing configuration \(error), \(error.userInfo)")
                abort()
            }
        } else {
            alertView.show()
            return false
        }
    }
    
    /**
    Formats a string for display in the Oops! alert
    
    :param: item the string to display
    
    :returns: the string formatted for display in the alert box
    */
    func alertItem(item: String) -> String {
        return "- \(item)\n"
    }
    
    /**
    Counts the occurences of a given character in the word
    
    :param: word the word
    :param: char the character to count for
    
    :returns: the number of the specified character in the word
    */
    func countOccurencesOfCharInWord(word: String, char: String) -> Int {
        var count = 0
        for character: Character in word.characters {
            if ("\(character)" == char) {
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
        if (saveSettings()) {
            self.performSegueWithIdentifier("resetPassSegue", sender: self)
        }
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
                do {
                    self.textContact.text = try CommunicationUtil().formatNumber(selectedNumber)
                } catch let error as NSError {
                    NSLog("This shouldn't happen, but is recoverable")
                    NSLog(error.localizedDescription)
                }
            }
            
            self.textEnabledSwitch.on = true
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
        
        initSavedValues()
    }
    
    
    /**
    Initializes the settings view with current saved values for all fields
    
    :param: managedObjectContext the managed object context that the conf is stored in
    */
    func initSavedValues(managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!, communicationUtil: CommunicationUtil = CommunicationUtil()) {
        var conf: Configuration!
        do {
            conf = try Configuration.get(managedObjectContext)
        } catch Configuration.ConfigurationError.NoResultsFound {
            // This case only really happens in testing. Will fail later, if not
            return
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            abort()
        }

        if let name = conf.full_name {
            self.name.text = name
        }
        
        if let phone = conf.phone_number {
            self.phonenumber.text = phone
        }
        
        // Enable the contact police switch only if the saved number is the police
        //   otherwise display the value the user is using
        if let callContact = conf.call_recipient {
            if (callContact == SettingsViewController.POLICE_PHONE_NUMBER) {
                self.contactPoliceSwitch.on = true
            } else {
                self.callContact.text = callContact
                self.contactPoliceSwitch.on = false
            }
        }
        
        // Get the first text contact. TODO: support multiple texting
        if let textContacts = conf.sms_recipients {
            self.textContact.text = communicationUtil.csvNumbersToArray(textContacts)[0]
        }
        
        if let body = conf.sms_body {
            self.textBody.text = body
        }
        
        if let lockdown = conf.lockdown_duration {
            self.lockdownTime.text = "\(lockdown)"
        }
        
        if let release = conf.release_duration {
            self.releaseTime.text = "\(release)"
        }
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
