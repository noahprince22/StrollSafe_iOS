//
//  NavigatorViewController.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/21/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import UIKit

class SettingsNavigatorViewController: UIViewController {
    weak var settingsViewController: SettingsViewController!
    var delegate: DismissableViewDelegate! = nil
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? SettingsViewController
            where segue.identifier == "settingsEmbed" {
                self.settingsViewController = vc
        }
    }

    @IBAction func donePress(sender: UIBarButtonItem) {
        let errorString = settingsViewController.saveSettings()
        if (errorString == "") {
            delegate.dismiss(self)
        } else {
            settingsViewController.displayAlertView("Oops!", message: errorString)
        }
    }
}
