//
//  NavigatorViewController.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/21/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import UIKit

class NavigatorViewController: UIViewController {
    weak var settingsViewController: SettingsViewController!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? SettingsViewController
            where segue.identifier == "settingsEmbed" {
                self.settingsViewController = vc
        }
    }

    @IBAction func donePress(sender: UIBarButtonItem) {
        if (self.settingsViewController.saveSettings()) {
            self.performSegueWithIdentifier("settingsToMainSegue", sender: nil)
        }
    }
}
