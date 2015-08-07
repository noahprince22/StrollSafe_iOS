//
//  ViewController.swift
//  Stroll Safe
//
//  Created by Noah Prince on 3/21/15.
//  Copyright (c) 2015 Stroll Safe. All rights reserved.
//

import UIKit
import CoreData

// Lets the time display as 2.00 and not 2
extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}

class MainViewController: UIViewController {
    
    static var MAIN_TITLE = "Stroll Safe"
    static var MAIN_TITLE_SUB = "Keeping You Safe on Your Late Night Strolls"
    
    static var THUMB_TITLE = "Armed"
    static var THUMB_TITLE_SUB = "Release Finger to Enter Lockdown"
    static var THUMB_SHAKE_DESC = "Slide and Release Here to Enter Shake Mode"
    
    static var RELEASE_TITLE = "Thumb Released"
    static var RELEASE_TITLE_SUB = "Press and Hold Button to Cancel"
    
    static var SHAKE_TITLE = "Shake Mode"
    static var SHAKE_TITLE_SUB = "Shake Phone to Enter Lockdown"
    static var SHAKE_SHAKE_DESC =  "Press and Hold to Exit the App"
    
    // hacked see http://stackoverflow.com/questions/24015207/class-variables-not-yet-supported
    static var test: Bool = true
    
    static var TIME_TO_LOCKDOWN: Double = 1.5
    
    enum state {
        case START, THUMB, RELEASE,SHAKE
    }
    var mode = state.START;
    
    @IBOutlet weak var titleMain: UILabel!
    @IBOutlet weak var titleSub: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var thumb: UIButton!
    @IBOutlet weak var shake: UIButton!
    @IBOutlet weak var shakeDesc: UILabel!
    @IBOutlet weak var thumbDesc: UILabel!
        
    /**
    Should execute before displaying any view
    For now decides which view to start at, set password or main
    TODO: Move this to a place that actually executes before the main view loads
    
    :params: The managed object context to check for the passcode
    :returns: <#return value description#>
    */
    func initializeApp(managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!) {
        if (MainViewController.test) {
            let request = NSFetchRequest(entityName: "Passcode")
            
            var passcodes = try! managedObjectContext.executeFetchRequest(request)
            
            for passcode: AnyObject in passcodes
            {
                managedObjectContext.deleteObject(passcode as! NSManagedObject)
            }
            
            passcodes.removeAll(keepCapacity: false)
            try! managedObjectContext.save()
            
            MainViewController.test = false
        }
        
        do {
            try Passcode.get(managedObjectContext)
        } catch Passcode.PasscodeError.NoResultsFound {
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("firstTimeUserSegue", sender: nil)
            })
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            abort()
        }
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
    

    @IBAction func releaseButtonAction(sender: AnyObject) {
    }
    
    @IBAction func thumbButtonAction(sender: AnyObject) {
    }
    
    func enterStartState(){
        setThumbVisibility(true)
        setProgressVisibility(false)
        setShakeVisibility(false, type: true)
        changeTitle(MainViewController.MAIN_TITLE, sub: MainViewController.MAIN_TITLE_SUB)
        
        mode = state.START
    }
    
    func enterThumbState(){
        setThumbVisibility(false)
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
        setProgressVisibility(true)
        setShakeVisibility(false,type: true)
        changeTitle(MainViewController.RELEASE_TITLE, sub: MainViewController.RELEASE_TITLE_SUB)
        mode = state.RELEASE
        
        progressLabel.text = "0"
    }
    
    /**
    Dispatches an aynchronous timer that will enter the lockdown state after 2 seconds
      if the phone is still in the release state
    */
    func dispatchLockdownTimer() {
        let timedActionBuilder = TimedActionBuilder {builder in
            builder.secondsToRun = MainViewController.TIME_TO_LOCKDOWN
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
        
        TimedAction(builder: timedActionBuilder).run()
    }
    
    func lockdown() {
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("lockdownSegue", sender: nil)
        })
    }
    
    func enterReleaseState(){
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
            let fractionalProgress = Float(timeElapsed / MainViewController.TIME_TO_LOCKDOWN)
            let animated = false;
            
            self.progressBar.setProgress(fractionalProgress, animated: animated)
            let progressString = (MainViewController.TIME_TO_LOCKDOWN - timeElapsed).format("0.2")
            self.progressLabel.text = ("\(progressString) seconds remaining")
        })
    }
    
    func enterShakeState(){
        setThumbVisibility(true)
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
        enterStartState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
}

