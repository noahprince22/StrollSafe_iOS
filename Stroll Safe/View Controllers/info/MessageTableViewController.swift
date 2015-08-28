//
//  MessageTableView.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/27/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import UIKit

class MessageTableViewController: UITableViewController {
    
    @IBOutlet weak var subjectField: UITextField!
    @IBOutlet weak var bodyField: UITextView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    var doneAction: (() throws -> ()) = { _ in
        return
    }
    var trashAction: (() throws -> ()) = { _ in
        return
    }
    // Run after view loads
    var configure: (() throws -> ()) = { _ in
        return
    }
    
    override func viewDidLoad() {
        try! configure()
    }
    
    var subject: String {
        get {
            return subjectField.text!
        }
        
        set {
            subjectField.text = newValue
        }
    }
    
    var body: String {
        get {
            return bodyField.text!
        }
        
        set {
            bodyField.text = newValue
        }
    }
    
    var navTitle: String {
        get {
            return navBar.title!
        }
        
        set {
            navBar.title = newValue
        }
    }
    
    
    
    @IBAction func done(sender: AnyObject) {
        try! self.doneAction()
    }
    
    @IBAction func trash(sender: AnyObject) {
        try! self.trashAction()
    }
    
    func close() {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let navController = self.navigationController {
            navController.navigationBarHidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if let navController = self.navigationController {
            navController.navigationBarHidden = false
        }
    }
}
