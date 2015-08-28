//
//  NavigatorViewController.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/21/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import UIKit

class NavigatorViewController: DismissableViewController {
    weak var settingsViewController: SettingsViewController!
    
    override func viewWillDisappear(animated: Bool) {
        if let navController = self.navigationController {
            navController.navigationBarHidden = true
        }
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        // If they hit the back button use the main right to left custom segue
//        if (parent == nil && self.dismissFn == nil) {
//            self.performSegueWithIdentifier("settingsToMainSegue", sender: self)
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if let navController = self.navigationController {
            navController.navigationBarHidden = false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? SettingsViewController
            where segue.identifier == "settingsEmbed" {
                self.settingsViewController = vc
        }
    }

    @IBAction func donePress(sender: UIBarButtonItem) {
        if (settingsViewController.saveSettings()) {
//            if let _ = self.dismissFn {
                self.dismiss()
//            } else {
//                // Default go back to main with a custom right to left segue
//                //self.performSegueWithIdentifier("settingsToMainSegue", sender: self)
//            }
        }
    }
}
