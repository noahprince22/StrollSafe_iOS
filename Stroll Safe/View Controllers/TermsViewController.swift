//
//  TermsViewController.swift
//  Stroll Safe
//
//  Created by Noah Prince on 5/15/15.
//  Copyright (c) 2015 Stroll Safe. All rights reserved.
//

import UIKit
import DigitsKit
import Crashlytics

let termsFinishedNotificationKey = "com.strollsafe.termsFinishedNotificationKey"
class TermsViewController: UIViewController, DismissableViewDelegate {

    @IBOutlet weak var acceptButton: UIButton!
    
    override func viewDidLoad() {
        if let navController = self.navigationController {
            navController.navigationBarHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func acceptTerms(sender: UIButton) {
        accept()
    }
    
    func accept(digits: Digits = Digits.sharedInstance(), crashlytics: Crashlytics = Crashlytics.sharedInstance(), managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!) {
        if let navController = self.navigationController {
            // Note that the dismiss function of DismissableViewDelegate will handle further views
            let setPasscodeVC = self.storyboard?.instantiateViewControllerWithIdentifier("SetPasscodeViewController") as! SetPasscodeViewController
            setPasscodeVC.delegate = self
            
            digits.authenticateWithTitle("Set Phone Number", completion: { (session: DGTSession!, error: NSError!) in
                if (error == nil) {
                    let userId = session.userID
                    crashlytics.setUserIdentifier(userId)
                    self.storePhoneNumber(session.phoneNumber, managedObjectContext: managedObjectContext)
                    navController.pushViewController(setPasscodeVC, animated: true)
                }
            })
        }
    }
    
    func storePhoneNumber(number: String, managedObjectContext: NSManagedObjectContext) {
        var newConf: Configuration
        do {
            try newConf = Configuration.get(managedObjectContext)
        } catch {
            // We can be sure this is the first run, so we'll just set the phone number on a new
            //    configuration, which will have all of the default values for everything else
            newConf = NSEntityDescription.insertNewObjectForEntityForName("Configuration", inManagedObjectContext: managedObjectContext) as! Configuration
        }
        
        newConf.phone_number = number
        
        try! managedObjectContext.save()
    }
    
    func close(controller: UIViewController) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    func dismiss(controller: UIViewController) {
        if let navController = self.navigationController {
            if (controller is SetPasscodeViewController) {
                let tutorialVC = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialViewController") as! TutorialViewController
                tutorialVC.delegate = self
                navController.pushViewController(tutorialVC, animated: true)
            }
            else if (controller is TutorialViewController) {
                let settingsVC =
                self.storyboard?.instantiateViewControllerWithIdentifier("SettingsNavigatorViewController") as! SettingsNavigatorViewController
                settingsVC.delegate = self
                
                settingsVC.navigationItem.setHidesBackButton(true, animated: false)
                navController.pushViewController(settingsVC, animated: true)
            }
            else if (controller is SettingsNavigatorViewController) {
                navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    func removePreviousVC(navigationController: UINavigationController) {
        let length = navigationController.viewControllers.count
        navigationController.viewControllers.removeAtIndex(length-2)
    }
}
