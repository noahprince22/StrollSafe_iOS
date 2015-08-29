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
import CoreLocation

class LockdownViewController: UIViewController, CLLocationManagerDelegate, PinpadViewDelegate {
    
    let locationManager = CLLocationManager()
    var coordinates: CLLocationCoordinate2D?
    var placemark: CLPlacemark?

    var lockdownDuration: Double!
    var smsRecipients: [String]? = []
    var callRecipient: String?
    var smsBody: String!
    
    var delegate: DismissableViewDelegate! = nil
    
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
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PinpadViewController
            where segue.identifier == "lockdownEmbedPinpad" {
                vc.delegate = self
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
        self.asyncAlertAction = buildAsyncAlertAction()
        asyncAlertAction.run()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "interrupted", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resumed", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        if let navController = self.navigationController {
            navController.navigationBarHidden = true
        }
    }
    
    func interrupted() {
        asyncAlertAction.pause()
    }
    
    func resumed() {
        if self.lock.isLocked() {
            asyncAlertAction.run()
        }
    }
    
    /**
    Configures this view controller with the stored configuration
    
    :param: configurationContext (optional) the managed object context to get the configuration
    */
    func configure(configurationContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!, communicationUtil: CommunicationUtil = CommunicationUtil()) {
        do {
            let conf = try Configuration.get(configurationContext)
            self.lockdownDuration = conf.lockdown_duration as? Double
            
            self.callRecipient = conf.call_recipient
            if let smsRecip = conf.sms_recipients {
                self.smsRecipients = communicationUtil.csvNumbersToArray(smsRecip)
            }
            
            if let body = conf.sms_body {
                self.smsBody = "\(conf.full_name!)\n\(conf.phone_number!):\n\n\(body)"
            }
        } catch let error as NSError {
            print("An error occurred while loading the configuration in the MainViewController, using fallback values")
            print(error.localizedDescription)
            
            self.lockdownDuration = 20
            
            self.smsRecipients = ["8675309"]
            self.callRecipient = "8675309"
            self.smsBody = "This is an alert from StrollSafe"
        }
        
        cacheStoredPass(configurationContext)
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
                    
                    if let smsRecips = self.smsRecipients {
                        var message = self.constructSmsBodyWithLocationInfo()
                        message = message + "\nSent via StrollSafe"
                        communicationUtil.sendSms(smsRecips, body: message)
                    }
                    
                    if let callRecip = self.callRecipient {
                        communicationUtil.sendCall(callRecip)
                    }
                    
                    // Unlock so we don't do any more calls
                    self.lock.locked = false
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.delegate.dismiss(self)
                    })
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
    
    /**
    Appends location info to the end of the class sms body
    
    :returns: The message body
    */
    func constructSmsBodyWithLocationInfo() -> String {
        var message = self.smsBody
        
        let addressUnavailable = "\n\nNearest address unavailable"
        if let _ = self.placemark {
            if let nearestAddr = self.nearestAddress() {
                message = message + "\n\nNearest address: \(nearestAddr))"
            }else {
                message = message + addressUnavailable
            }
        } else {
            message = message + addressUnavailable
        }
        
        if let loc = self.coordinates {
            message = message + "\nCoordinates: \(loc.latitude), \(loc.longitude)" as String!
        } else {
            message = message + "\nCoordinates unavailable"
        }
        
        return message
    }
    

    /**
    Creates a string about the user's location
    
    :returns: the closest address to the current placemark (including possible business name)
    */
    func nearestAddress() -> String? {
        var ret: String?
        
        if let pm = self.placemark {
            if (pm.name != nil || pm.thoroughfare != nil) {
                if let name = pm.name {
                    ret = name
                    if let street = pm.thoroughfare {
                        if let streetNum = pm.subThoroughfare {
                            let address = streetNum + " " + street
                            if (name != address) {
                                ret = ", " + ret! + address
                            }
                        }
                    }
                }
            }
        }
        
        return ret
    }
    
    /**
    The function run for the embedded pinpad view
    
    :param: controller the pinpad view controller that received the passcode
    :param: pass the passcode
    */
    func passEntered(controller: PinpadViewController, pass: String) {
        controller.clear();
        if self.lock.unlock(pass) {
            self.delegate.dismiss(self)
        } else {
            controller.shake();
        }
    }
    
    /**
    Caches the stored passcode in the instance lock
    
    :param: managedObjectContext the context of the stored passcode
    */
    func cacheStoredPass(managedObjectContext: NSManagedObjectContext) {
        do {
            lock.lock(try Configuration.get(managedObjectContext).passcode!)
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            NSLog("Something very bad happened. There was no stored pass when they got to the lockdown view")
        }
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if let location = manager.location {
            self.coordinates = location.coordinate
            
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
                if let er = error {
                    print("Reverse geocoder failed with error" + er.localizedDescription)
                    return
                }
                
                if let pm = placemarks?.first {
                    self.placemark = pm
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
