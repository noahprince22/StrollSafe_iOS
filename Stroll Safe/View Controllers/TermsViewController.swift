//
//  TermsViewController.swift
//  Stroll Safe
//
//  Created by Noah Prince on 5/15/15.
//  Copyright (c) 2015 Stroll Safe. All rights reserved.
//

import UIKit

let termsFinishedNotificationKey = "com.strollsafe.termsFinishedNotificationKey"
class TermsViewController: UIViewController {

    @IBOutlet weak var acceptButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func acceptTerms(sender: UIButton) {
        // Open the tutorial vc and have it go to setings when it's done
        self.dismissViewControllerAnimated(true, completion: {_ in
            NSNotificationCenter.defaultCenter().postNotificationName(termsFinishedNotificationKey, object: self)
        })
    }
    
    func goToSettings() {
        self.performSegueWithIdentifier("termsToSetPasscodeSegue", sender: self)
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
