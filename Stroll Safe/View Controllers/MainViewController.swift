//
//  ViewController.swift
//  Stroll Safe
//
//  Created by Noah Prince on 3/21/15.
//  Copyright (c) 2015 Stroll Safe. All rights reserved.
//

import UIKit
import CoreData
import MessageUI
import AudioToolbox
import Darwin
import CoreLocation


// Lets the time display as 2.00 and not 2
extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}

class MainViewController: UIViewController, DismissableViewDelegate {
    
    static var MEMORY_CLEARED = false
    
    static var MAIN_TITLE = "Stroll Safe"
    static var MAIN_TITLE_SUB = "Keeping You Safe on Your Late Night Strolls"
    
    static var THUMB_TITLE = "Armed"
    static var THUMB_TITLE_SUB = "Release Finger to Enter Lockdown"
    static var THUMB_SHAKE_DESC = "Slide and Release Here to Enter Shake Mode"
    
    static var RELEASE_TITLE = "Thumb Released"
    static var RELEASE_TITLE_SUB = "Press and Hold Button to Cancel"
    
    static var SHAKE_TITLE = "Shake Mode"
    static var SHAKE_TITLE_SUB = "Shake Phone to Enter Lockdown"
    static var SHAKE_SHAKE_DESC =  "Press and Hold to Exit Shake Mode"
    
    let locationManager = CLLocationManager()

    enum state {
        case START, THUMB, RELEASE,SHAKE
    }
    var mode = state.START;
    
    var releaseDuration: Double!
    
    @IBOutlet weak var titleMain: UILabel!
    @IBOutlet weak var titleSub: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var thumb: UIButton!
    @IBOutlet weak var shake: UIButton!
    @IBOutlet weak var shakeDesc: UILabel!
    @IBOutlet weak var thumbDesc: UILabel!
    @IBOutlet weak var settings: UIButton!
    @IBOutlet weak var help: UIButton!
    
    func dismiss(controller: UIViewController) {
        if (controller is SettingsNavigatorViewController) {
            let nav = self.navigationController!
            nav.viewControllers.removeAtIndex(0)
            nav.pushViewController(self, animated: true)
            nav.viewControllers.removeAtIndex(0)
        } else {
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func settingsClicked(sender: UIButton) {
        displaySettings()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "mainToSettingsSegue") {
            (segue.destinationViewController as! SettingsNavigatorViewController).delegate = self
        } else if (segue.identifier == "mainToInfoSegue") {
            (segue.destinationViewController as! InfoNavigatorViewController).delegate = self
        } else if (segue.identifier == "mainToLockdownSegue") {
            (segue.destinationViewController as! LockdownViewController).delegate = self
        }
    }
    
    @IBAction func helpClicked(sender: UIButton) {
        self.performSegueWithIdentifier("mainToInfoSegue", sender: self)
    }
    
    /**
    Should execute before displaying any view
    For now decides which view to start at, set password or main
    TODO: Move this to a place that actually executes before the main view loads
    
    :params: The managed object context to check for the passcode
    :returns: <#return value description#>
    */
    func initializeApp(managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!) {
        // If we're on a simulator, we're testing. Always clear the data.
        if (SimulatorUtility.isRunningSimulator && !MainViewController.MEMORY_CLEARED) {
            let request = NSFetchRequest(entityName: "Configuration")
            
            var configs = try! managedObjectContext.executeFetchRequest(request)
            
            for config: AnyObject in configs
            {
                managedObjectContext.deleteObject(config as! NSManagedObject)
            }
            
            configs.removeAll(keepCapacity: false)
            try! managedObjectContext.save()
            
            MainViewController.MEMORY_CLEARED = true
        }
        
        do {
            try Configuration.get(managedObjectContext)
        } catch Configuration.ConfigurationError.NoResultsFound {
            firstTimeUser()
            return
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            abort()
        }
    }
    
    func firstTimeUser() {
        self.performSegueWithIdentifier("firstTimeUserSegue", sender: self)
    }
    
    func displaySettings() {
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("mainToSettingsSegue", sender: self)
        })
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake && mode == state.SHAKE {
            lockdown()
        }
    }

    @IBAction func shakeLongPress(sender: AnyObject) {
        if sender.state == UIGestureRecognizerState.Began
        {
            enterStartState()
        }
    }
    
    var passcode: String = ""
        
    @IBAction func thumbDown(sender: UIButton) {
        enterThumbState()
    }
    
   @IBAction func thumbUpInside(sender: UIButton) {
        enterReleaseState()
    }
    
    @IBAction func thumbUpOutside(sender: AnyObject, forEvent event: UIEvent) {
        
        let buttonView = sender as! UIView
        let mainView = self.view
        
            // get any touch on the buttonView
         if let touch = event.touchesForView(buttonView)!.first {
            let location = touch.locationInView(mainView)
                
            let frame = shake.frame
            let minX = CGRectGetMinX(frame)
            let maxX = CGRectGetMaxX(frame)
            let minY = CGRectGetMinY(frame)
            let maxY = CGRectGetMaxY(frame)
            if ((location.x < minX || location.x > maxX) ||
                (location.y < minY || location.y > maxY)){
                    enterReleaseState()
                }else{
                    enterShakeState()
                }
        }
    }
    
    func enterStartState(){
        setThumbVisibility(true)
        setSettingsVisibility(true)
        setProgressVisibility(false)
        setShakeVisibility(false, type: true)
        changeTitle(MainViewController.MAIN_TITLE, sub: MainViewController.MAIN_TITLE_SUB)
        
        mode = state.START
    }
    
    func enterThumbState(){
        setThumbVisibility(false)
        setSettingsVisibility(false)
        setProgressVisibility(false)
        setShakeVisibility(true, type: true)
        changeTitle(MainViewController.THUMB_TITLE, sub: MainViewController.THUMB_TITLE_SUB)
        
        shakeDesc.text = MainViewController.THUMB_SHAKE_DESC
        
        mode = state.THUMB
    }
    
    /**
    Changes the display to reflect that the release state
    */
    func enterDisplayReleaseState() {
        setThumbVisibility(true)
        setSettingsVisibility(false)
        setProgressVisibility(true)
        setShakeVisibility(false,type: true)
        changeTitle(MainViewController.RELEASE_TITLE, sub: MainViewController.RELEASE_TITLE_SUB)
        mode = state.RELEASE
        
        progressLabel.text = "0"
    }
    
    /**
    Configures this view controller with the stored configuration, checks to see if there is 
    an internet connection to send sms
    
    :param: configurationContext (optional) the managed object context to get the configuration
    */
    func configure(configurationContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!) {
        do {
            let conf = try Configuration.get(configurationContext)
            self.releaseDuration = conf.release_duration as? Double
            
            // If texting is enabled, must have an internet connection
            if let _ = conf.sms_recipients {
                // Every 10 seconds check to see if the internet is up, otherwise we can't send sms
                var seenOnce = false
                let timedActionBuilder = TimedActionBuilder { builder in
                    builder.secondsToRun = DBL_MAX
                    builder.recurrentInterval = 10
                    builder.recurrentFunction = { (timeElapsed: Double) in
                        dispatch_async(dispatch_get_main_queue(), {
                            if (!Reachability.isConnectedToNetwork()) {
                                let alert = UIAlertView()
                                alert.title = "Network Unavailable"
                                alert.message = "Please enable networking or disable the texting feature. This app cannot send an emergency SMS without an internet connection"
                                alert.addButtonWithTitle("Ok")
                                alert.show()
                                seenOnce = true
                            }
                        })
                    }
                    builder.breakCondition = { _ in
                        return seenOnce
                    }
                }
                
                // Run once to make sure we're connected now
                timedActionBuilder.recurrentFunction!(0)
                
                TimedAction(builder: timedActionBuilder).run()
            }
        } catch let error as NSError {
            print("An error occurred while loading the configuration in the MainViewController, using fallback values")
            print(error.localizedDescription)
            
            self.releaseDuration = 1.5
        }
    }
    
    /**
    Dispatches an aynchronous timer that will enter the lockdown state after 2 seconds
      if the phone is still in the release state
    
    */
    func dispatchLockdownTimer() -> TimedAction {
        let timedActionBuilder = TimedActionBuilder {builder in
            builder.secondsToRun = self.releaseDuration
            builder.recurrentFunction = self.updateProgress
            builder.breakCondition = { _ in
                return self.mode != state.RELEASE
            }
            builder.exitFunction = { _ in
                if (self.mode == state.RELEASE){
                    self.lockdown()
                }
            }
        }
        
        let action = TimedAction(builder: timedActionBuilder)
        action.run()
        return action
    }
    
    func lockdown() {
        // Get out of shake mode so multiple shake gestures aren't received
        self.mode = state.START
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("mainToLockdownSegue", sender: nil)
        })
    }
    
    func enterReleaseState(){
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        enterDisplayReleaseState()
        dispatchLockdownTimer()
    }
    
    /**
    Updates the progressbar progress with the timeElapsed based on the endTime
    
    :param: timeElapsed the time elapsed
    :param: endTime the time this progress bar ends at
    */
    func updateProgress(timeElapsed: Double) {
        dispatch_async(dispatch_get_main_queue(), {
            let fractionalProgress = Float(timeElapsed / self.releaseDuration)
            let animated = false;
            
            self.progressBar.setProgress(fractionalProgress, animated: animated)
            let progressString = (self.releaseDuration - timeElapsed).format("0.2")
            self.progressLabel.text = ("\(progressString) seconds remaining")
        })
    }
    
    func enterShakeState(){
        setThumbVisibility(false)
        setSettingsVisibility(false)
        setProgressVisibility(false)
        setShakeVisibility(true, type: false)
        changeTitle(MainViewController.SHAKE_TITLE, sub: MainViewController.SHAKE_TITLE_SUB)
        
        shakeDesc.text = MainViewController.SHAKE_SHAKE_DESC
        mode = state.SHAKE
    }
    
    func changeTitle(title: NSString,  sub: NSString){
        titleMain.text = title as String
        titleSub.text = sub as String
    }
    
    func setProgressVisibility(visibility: Bool){
        progressBar.hidden = !visibility
        progressLabel.hidden = !visibility
    }
    
    func setThumbVisibility(visibility: Bool){
        thumb.hidden = !visibility
        thumbDesc.hidden = !visibility
    }
    
    func setSettingsVisibility(visibility: Bool) {
        settings.hidden = !visibility
        help.hidden = !visibility
    }
    
    // First parameter is whether it's visible
    // Second sets it as the shake button when true,
    // exit button when false
    func setShakeVisibility(visibility: Bool, type: Bool){
        shake.hidden = !visibility
        shakeDesc.hidden = !visibility
        
        // Setup the shake icon
        if type{
            if let image  = UIImage(named: "shake_icon.png") {
                shake.setImage(image, forState: .Normal)
            }
        }
        else{
            if let image  = UIImage(named: "close_icon.png") {
                    shake.setImage(image, forState: .Normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeApp()
        
        locationManager.requestAlwaysAuthorization()
        
        // Don't allow auto screen locking while app is running
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        // If interrupted by a phone call or something, just go back to start state
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "interrupted", name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        if let navController = self.navigationController {
            navController.navigationBarHidden = true
        }
        
        configure()
        enterStartState()
    }
    
    func interrupted() {
        if (self.mode == state.THUMB) {
            enterShakeState()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
