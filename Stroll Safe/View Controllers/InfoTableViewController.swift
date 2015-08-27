//
//  InfoTableViewController.swift
//  Stroll Safe
//
//  Created by Lynda Prince on 8/27/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import UIKit

class InfoTableViewController: UITableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1) {
            let tutorialVC = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialViewController") as? TutorialViewController
            
            self.presentViewController(tutorialVC!, animated: true, completion: nil)
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
                        vc.body = "Overview:"
                    }
                    
                    vc.doneAction = { _ in
                        vc.close()
                    }
                case 1:
                    vc.doneAction = { _ in
                        vc.close()
                    }
                default: break
                }
                
                if let navController = self.navigationController {
                    navController.pushViewController(vc, animated: true)
                }
            }
        }
    }

    @IBAction func done(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("infoToMainSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
