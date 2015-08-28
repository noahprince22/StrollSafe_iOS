//
//  TermsViewController.swift
//  Stroll Safe
//
//  Created by Noah Prince on 5/15/15.
//  Copyright (c) 2015 Stroll Safe. All rights reserved.
//

import UIKit

let termsFinishedNotificationKey = "com.strollsafe.termsFinishedNotificationKey"
class TermsViewController: DismissableViewController {

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
        if let navController = self.navigationController {
            let setPasscodeVC = self.storyboard?.instantiateViewControllerWithIdentifier("SetPasscodeViewController") as! DismissableViewController
            setPasscodeVC.dismissFn = { _ in
                let tutorialVC = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialViewController") as! DismissableViewController
                tutorialVC.dismissFn = { _ in
                    let settingsVC = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsNavigatorViewController") as! DismissableViewController
                    
                    settingsVC.dismissFn = { _ in
                        navigationController?.popToRootViewControllerAnimated(true)
                    }
                    
                    settingsVC.navigationItem.setHidesBackButton(true, animated: false)
                    navController.pushViewController(settingsVC, animated: true)
                }
                
                navController.pushViewController(tutorialVC, animated: true)
            }
            
            navController.pushViewController(setPasscodeVC, animated: true)
        }
    }
    
    func removePreviousVC(navigationController: UINavigationController) {
        let length = navigationController.viewControllers.count
        navigationController.viewControllers.removeAtIndex(length-2)
    }
}
