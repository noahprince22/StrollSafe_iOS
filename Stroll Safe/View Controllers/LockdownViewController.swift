//
//  LockdownViewController.swift
//  Stroll Safe
//
//  Created by noah prince on 3/21/15.
//  Copyright (c) 2015 Stroll Safe. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class LockdownViewController: UIViewController {

    var lockdownDuration: Double!
    var smsRecipients: [String]!
    var callRecipient: String!
    var smsBody: String!
    
    class Lock {
        var pass: String = ""
        var locked: Bool = false
        
        /**
        Locks this lock with the given password
        
        :param: passwd the password
        */
        func lock(passwd: String) {
            pass = passwd
            locked = true
        }
        
        /**
        Attempts to unlock with the given password.
        
        :param: passwd The unlock password
        
        :returns: True if the pass unlocked it, false if it was an incorrect password
        */
        func unlock(passwd: NSString) -> Bool{
            locked = !(passwd == pass)
            return !locked
        }
        
        func isLocked() -> Bool{
            return locked
        }
    }
    
    let lock = Lock()

    @IBOutlet weak var progressCircle: CircleProgressView!
    @IBOutlet weak var progressLabel: UILabel!    

    var input = -1

    var asyncAlertAction: TimedAction!
    
    weak var pinpadViewController: PinpadViewController!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PinpadViewController
            where segue.identifier == "lockdownEmbedPinpad" {
                
                self.pinpadViewController = vc
        }
    }

    /**
    Updates the status bar with the correct time elapsed
    
    :param: timeElapsed the elapsed time
    */
    func updateProgress(timeElapsed: Double) {
        dispatch_async(dispatch_get_main_queue(), {
            let fractionalProgress:Double = timeElapsed / self.lockdownDuration
            
            if (fractionalProgress <= 1){
                self.progressCircle.progress = fractionalProgress
                
                let timeRemainingText = (self.lockdownDuration - timeElapsed).format("0.1")
                self.progressLabel.text = (timeRemainingText)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupPinpadViewWithStoredPasscode()
        self.asyncAlertAction = buildAsyncAlertAction()
        asyncAlertAction.run()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "interrupted", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resumed", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func interrupted() {
        asyncAlertAction.pause()
    }
    
    func resumed() {
        asyncAlertAction.run()
    }
    
    /**
    Configures this view controller with the stored configuration
    
    :param: configurationContext (optional) the managed object context to get the configuration
    */
    func configure(configurationContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!) {
        do {
            let conf = try Configuration.get(configurationContext)
            self.lockdownDuration = conf.lockdown_duration as? Double
            // Take comma separated values to array of numbers
            self.smsRecipients = conf.sms_recipients!.characters.split {$0 == ","}.map { String($0) }
            self.callRecipient = conf.call_recipient!
            self.smsBody = conf.sms_body!
        } catch let error as NSError {
            print("An error occurred while loading the configuration in the MainViewController, using fallback values")
            print(error.localizedDescription)
            
            self.lockdownDuration = 20
            
            self.smsRecipients = ["8675309"]
            self.callRecipient = "8675309"
            self.smsBody = "This is an alert from StrollSafe"
        }
    }
    
    /**
    Builds the timed action that will eventually contact the emergency contacts
    
    :param: communicationUtil a utility to contact emergency contacts
    
    :returns: the timed action
    */
    func buildAsyncAlertAction(communicationUtil: CommunicationUtil = CommunicationUtil()) -> TimedAction {
        let timedActionBuilder = TimedActionBuilder{ builder in
            builder.secondsToRun = self.lockdownDuration
            builder.exitFunction = { _ in
                if self.lock.isLocked() {
                    // Set the progress to zero so it's not displaying some fraction
                    dispatch_async(dispatch_get_main_queue(), {
                        self.progressCircle.progress = 1
                        self.progressLabel.text = ("0")
                    })
                    
                    communicationUtil.sendSms(self.smsRecipients, body: self.smsBody)
                    communicationUtil.sendCall(self.callRecipient)
                }
            }
            builder.recurrentFunction = self.updateProgress
            builder.breakCondition = { _ in
                !self.lock.isLocked()
            }
            builder.accelerationRate = 0.000004
        }
        return TimedAction(builder: timedActionBuilder)
    }
    
    func setupPinpadViewWithStoredPasscode(managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!) {
        do {
            lock.lock(try Configuration.get(managedObjectContext).passcode!)
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            NSLog("Something very bad happened. There was no stored pass when they got to the lockdown view")
        }

        pinpadViewController.setEnteredFunction({(pass: String) -> () in
            self.pinpadViewController.clear();
            if self.lock.unlock(pass) {
                self.performSegueWithIdentifier("unlockSegue", sender: nil)
            } else {
                self.pinpadViewController.shake();
            }
        })
    }
    
    /**
    When someone touches down on the progress bar to accelerate/call quickly
    
    :param: sender
    */
    @IBAction func timerTouchDown(sender: AnyObject) {
        asyncAlertAction.enableAcceleration()
    }
    
    /**
    When someone releases the progress bar, stop the acceleration
    
    :param: sender
    */
    @IBAction func timerTouchUp(sender: AnyObject) {
        asyncAlertAction.disableAcceleration()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
