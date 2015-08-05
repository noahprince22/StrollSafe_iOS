//
//  LockdownViewController.swift
//  Stroll Safe
//
//  Created by noah prince on 3/21/15.
//  Copyright (c) 2015 Stroll Safe. All rights reserved.
//

import UIKit
import CoreData


class LockdownViewController: UIViewController {
    
    static let LOCKDOWN_DURATION = 20.0
    
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
            let fractionalProgress = timeElapsed / LockdownViewController.LOCKDOWN_DURATION
            
            if (fractionalProgress <= 1){
                self.progressCircle.progress = fractionalProgress
                
                let timeRemainingText = (LockdownViewController.LOCKDOWN_DURATION - timeElapsed).format("0.1")
                self.progressLabel.text = (timeRemainingText)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timedActionBuilder = TimedActionBuilder{ builder in
            builder.secondsToRun = 20.0
            builder.exitFunction = { _ in
                if self.lock.isLocked() {
                    // Set the progress to zero so it's not displaying some fraction
                    dispatch_async(dispatch_get_main_queue(), {
                        self.progressCircle.progress = 1
                        self.progressLabel.text = ("0")
                    })
                    
                    let url:NSURL = NSURL(string: "tel://2179941016")!
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            builder.recurrentFunction = self.updateProgress
            builder.breakCondition = { _ in
                !self.lock.isLocked()
            }
            builder.accelerationRate = 0.000004
        }
        self.asyncAlertAction = TimedAction(builder: timedActionBuilder)
        
        setupPinpadViewWithStoredPasscode()
        asyncAlertAction.run()
    }
    
    func setupPinpadViewWithStoredPasscode(managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!) {
        lock.lock(try! Passcode.get(managedObjectContext))

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
