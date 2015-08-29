//
//  TermsViewController.swift
//  Stroll Safe
//
//  Created by Noah Prince on 5/15/15.
//  Copyright (c) 2015 Stroll Safe. All rights reserved.
//

import UIKit

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
        if let navController = self.navigationController {
            // Note that the dismiss function of DismissableViewDelegate will handle further views
            let setPasscodeVC = self.storyboard?.instantiateViewControllerWithIdentifier("SetPasscodeViewController") as! SetPasscodeViewController
            setPasscodeVC.delegate = self
            navController.pushViewController(setPasscodeVC, animated: true)
        }
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
                self.storyboard?.instantiateViewControllerWithIdentifier("SettingsNavigatorViewController") as! NavigatorViewController
                settingsVC.delegate = self
                
                settingsVC.navigationItem.setHidesBackButton(true, animated: false)
                navController.pushViewController(settingsVC, animated: true)
            }
            else if (controller is NavigatorViewController) {
                navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    func removePreviousVC(navigationController: UINavigationController) {
        let length = navigationController.viewControllers.count
        navigationController.viewControllers.removeAtIndex(length-2)
    }
}
