//
//  SetPasscodeViewController.swift
//  Stroll Safe
//
//  Created by noah prince on 3/25/15.
//  Copyright (c) 2015 Stroll Safe. All rights reserved.
//

import UIKit
import CoreData

class SetPasscodeViewController: UIViewController {
    
    static var ENTER_TEXT = "Enter a passcode"
    static var REENTER_TEXT = "Re-enter passcode"

    @IBOutlet weak var subLabel: UILabel!

    var firstPass = ""
    var firstEntered: Bool = false

    weak var pinpadViewController: PinpadViewController!
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PinpadViewController
            where segue.identifier == "setPassEmbedPinpad" {
                
                self.pinpadViewController = vc
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPinpadViewToStorePasscode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    Sets up the pinpad view to store the provided passcode in the managedObjectContext
    
    :param: managedObjectContext the context to store the provided passcode in
    */
    func setupPinpadViewToStorePasscode(managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!) {
        pinpadViewController.setEnteredFunction({(pass: String) throws -> () in
            self.pinpadViewController.clear()
            
            if (self.firstEntered){
                // They entered the second password, verify it's the same as the first one they entered
                if self.firstPass == pass {
                    Passcode.set(pass, managedObjectContext: managedObjectContext)
                    
                    // Transition to the main screen
                    self.performSegueWithIdentifier("setPassSuccessSegue", sender: nil)
                }else{
                    // They fucked up, take them back to the beginning
                    self.firstEntered = false
                    self.firstPass = ""
                    
                    self.subLabel.text = SetPasscodeViewController.ENTER_TEXT
                    self.pinpadViewController.shake()
                }
            }else{
                // They entered the first password. When this function comes around again
                // We'll verify the password
                self.firstEntered = true
                self.firstPass = pass
                
                self.subLabel.text = SetPasscodeViewController.REENTER_TEXT
            }
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
