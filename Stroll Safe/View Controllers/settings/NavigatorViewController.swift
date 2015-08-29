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
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        // If they hit the back button use the main right to left custom segue
//        if (parent == nil && self.dismissFn == nil) {
//            self.performSegueWithIdentifier("settingsToMainSegue", sender: self)
//        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? SettingsViewController
            where segue.identifier == "settingsEmbed" {
                self.settingsViewController = vc
        }
    }

    @IBAction func donePress(sender: UIBarButtonItem) {
        if (settingsViewController.saveSettings()) {
            if let _ = self.dismissFn {
                self.dismiss()
            } else {
                let main = self.navigationController!.viewControllers.first!
                self.navigationController!.viewControllers.removeAtIndex(0)
                self.navigationController!.pushViewController(main, animated: true)
                self.navigationController!.viewControllers.removeAtIndex(0)
            }
        }
    }
}
