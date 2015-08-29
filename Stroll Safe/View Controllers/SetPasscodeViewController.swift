//
//  SetPasscodeViewController.swift
//  Stroll Safe
//
//  Created by noah prince on 3/25/15.
//  Copyright (c) 2015 Stroll Safe. All rights reserved.
//

import UIKit
import CoreData

class SetPasscodeViewController: UIViewController, PinpadViewDelegate {
    
    static var ENTER_TEXT = "Enter a passcode"
    static var REENTER_TEXT = "Re-enter passcode"
    
    var delegate: DismissableViewDelegate! = nil

    @IBOutlet weak var subLabel: UILabel!

    var firstPass = ""
    var firstEntered: Bool = false
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PinpadViewController
            where segue.identifier == "setPassEmbedPinpad" {
                vc.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = self.navigationController {
            navController.navigationBarHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
    What happens when the pass is entered
    
    :param: controller the pinpad view controller that got the pass
    :param: pass the passcode
    */
    func passEntered(controller: PinpadViewController, pass: String) {
        checkAndStorePass(controller, pass: pass)
    }

    /**
    Checks the passcode and stores it if valid
    
    :param: controller the pinpad view controller that got the pass
    :param: pass                 the passcode
    :param: managedObjectContext the context to store it in
    */
    func checkAndStorePass(controller: PinpadViewController, pass: String, managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!) {
        controller.clear()
        
        if (self.firstEntered){
            // They entered the second password, verify it's the same as the first one they entered
            if self.firstPass == pass {
                var newConf: Configuration
                do {
                    try newConf = Configuration.get(managedObjectContext)
                } catch {
                    // We can be sure this is the first run, so we'll just set the passcode on a new
                    //    configuration, which will have all of the default values for everything else
                    newConf = NSEntityDescription.insertNewObjectForEntityForName("Configuration", inManagedObjectContext: managedObjectContext) as! Configuration
                }
                
                newConf.passcode = pass
                
                // This shouldn't fail, but if it does we should die. Don't want a lockdown to init
                //    with no stored password to unlock it
                try! managedObjectContext.save()
                
                self.delegate.dismiss(self)
            }else{
                // They fucked up, take them back to the beginning
                self.firstEntered = false
                self.firstPass = ""
                
                self.subLabel.text = SetPasscodeViewController.ENTER_TEXT
                controller.shake()
            }
        }else{
            // They entered the first password. When this function comes around again
            // We'll verify the password
            self.firstEntered = true
            self.firstPass = pass
            
            self.subLabel.text = SetPasscodeViewController.REENTER_TEXT
        }
    }
}
