//
//  InfoTableViewController.swift
//  Stroll Safe
//
//  Created by Lynda Prince on 8/27/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import UIKit

class InfoTableViewController: UITableViewController, DismissableViewDelegate {
    
    @IBOutlet weak var version: UILabel!
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1) {
            self.performSegueWithIdentifier("infoToTutorialSegue", sender: self)
        }
        
        if (indexPath.section == 2) {
            let messageVC = self.storyboard?.instantiateViewControllerWithIdentifier("MessageTableViewController") as? MessageTableViewController
            if let vc = messageVC {
                vc.trashAction = { _ in
                    vc.close()
                }
                
                switch(indexPath.row) {
                case 0:
                    vc.configure = { _ in
                        vc.subjectField.placeholder = "a brief description of the feature"
                        vc.body = "Overview:\n"
                    }
                    
                    vc.doneAction = { _ in
                        CommunicationUtil().sendFeature(vc.subject, body: vc.body)
                        self.navigationController!.popViewControllerAnimated(true)
                    }
                case 1:
                    vc.configure = { _ in
                        vc.subjectField.placeholder = "a brief description of the bug"
                        vc.body = "Description:\n\n\n\nSteps to Recreate This Bug:\n"
                    }
                    
                    vc.doneAction = { _ in
                        CommunicationUtil().sendBug(vc.subject, body: vc.body)
                        self.navigationController!.popViewControllerAnimated(true)
                    }
                default: break
                }
                
                if let navController = self.navigationController {
                    navController.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "infoToTutorialSegue") {
            (segue.destinationViewController as! TutorialViewController).delegate = self
        }
    }
    
    func dismiss(controller: UIViewController) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = self.navigationController {
            navController.navigationBarHidden = false
        }
        
        self.version.text = AppDelegate.VERSION
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 2
        default:
            return 0
        }
    }
}
