//
//  SettingsViewController.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/10/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate, UISearchBarDelegate{
    
    @IBOutlet weak var contactPoliceSwitch: UISwitch!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phonenumber: UITextField!
    @IBOutlet weak var callContact: UISearchBar!
    @IBOutlet weak var textContact: UISearchBar!
    @IBOutlet weak var textBody: UITextField!
    @IBOutlet weak var lockdownTime: UITextField!
    @IBOutlet weak var releaseTime: UITextField!
    @IBOutlet weak var done: UIBarButtonItem!
    var contactSearchVC: ContactSearchViewController!
    
    @IBAction func donePress(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("settingsToMainSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.name.delegate = self
        self.phonenumber.delegate = self
        self.callContact.delegate = self
        //self.textContact.delegate = self
        self.textBody.delegate = self
        self.lockdownTime.delegate = self
        self.releaseTime.delegate = self
        
        //self.callContact.delegate = ContactSearchDelegate( { _ in
            //println("hello")        })
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if (searchBar == callContact) {
            self.contactPoliceSwitch.on = false
        }
        
        let contactSearchVC = self.storyboard?.instantiateViewControllerWithIdentifier("ContactSearchViewController") as! ContactSearchViewController
        contactSearchVC.setCompletion({ selectedNumber in
            searchBar.text = selectedNumber
        })
        
        self.presentViewController(contactSearchVC, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func contactPoliceSwitch(sender: AnyObject) {
        self.callContact.text = ""
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        switch section {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 2
        case 3:
            return 2
        case 4:
            return 1
        default:
            return 0
        }
    }
    
    /**
     Will make text fields close on return
    
    :param: userText <#userText description#>
    
    :returns: <#return value description#>
    */
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }
}
