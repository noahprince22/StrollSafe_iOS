//
//  ContactSearchControllerViewController.swift
//  Stroll Safe
//
//  Created by Lynda Prince on 8/15/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import UIKit
import AddressBook

class ContactSearchViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    lazy var addressBook: ABAddressBookRef = {
        var error: Unmanaged<CFError>?
        return ABAddressBookCreateWithOptions(nil,
            &error).takeRetainedValue() as ABAddressBookRef
        }()
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchActive : Bool = false
    var people : [(String, String)] = []
    var filtered:[(String, String)] = []
    var completionFn: ((String) throws -> (Void))!

    /**
    Sets the function that will be executed when a number is selected
    
    :param: fn The function to execute
    */
    func setCompletion(fn: (String) throws -> (Void)) {
        self.completionFn = { try fn($0) }
    }
    
    func readFromAddressBook(addressBook: ABAddressBookRef){
        
        /* Get all the people in the address book */
        let allPeople = ABAddressBookCopyArrayOfAllPeople(
            addressBook).takeRetainedValue() as NSArray
        
        for person in allPeople {
            if let firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty) {
                if let lastName = ABRecordCopyValue(person, kABPersonLastNameProperty) {
                    let ln:String = (lastName.takeRetainedValue() as? String) ?? ""
                    let fn:String = (firstName.takeRetainedValue() as? String) ?? ""
                    
                    /* Get all the phone numbers this user has */
                    let unmanagedPhones = ABRecordCopyValue(person, kABPersonPhoneProperty)
                    let phones: ABMultiValueRef =
                    Unmanaged.fromOpaque(unmanagedPhones.toOpaque()).takeUnretainedValue()
                        as NSObject as ABMultiValueRef
                    
                    let countOfPhones = ABMultiValueGetCount(phones)
                    
                    for index in 0..<countOfPhones{
                        let unmanagedPhone = ABMultiValueCopyValueAtIndex(phones, index)
                        let phone: String = Unmanaged.fromOpaque(
                            unmanagedPhone.toOpaque()).takeUnretainedValue() as NSObject as! String
                        
                        people.append(("\(fn) \(ln)", phone))
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()
        
        switch ABAddressBookGetAuthorizationStatus(){
        case .Authorized:
            print("Already authorized")
            readFromAddressBook(addressBook)
        case .Denied:
            print("You are denied access to address book")
            
        case .NotDetermined:
            ABAddressBookRequestAccessWithCompletion(addressBook,
                {[weak self] (granted: Bool, error: CFError!) in
                    
                    if granted{
                        let strongSelf = self!
                        print("Access is granted")
                        strongSelf.readFromAddressBook(strongSelf.addressBook)
                    } else {
                        print("Access is not granted")
                    }
                    
                })
        case .Restricted:
            print("Access is restricted")
            
        }
        
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        searchBar.becomeFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        
        self.dismissViewControllerAnimated(true, completion: { _ in
            try! self.completionFn(searchBar.text!)
        })
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;

        self.dismissViewControllerAnimated(true, completion: { _ in
            try! self.completionFn("")
        })
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filtered.append(("",searchText))
        
        filtered = []
        for person in people {
            if (person.0.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil || person.1.rangeOfString(searchText) != nil) {
                filtered.append(person)
            }
        }
        
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return people.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell?
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"Cell")
        }
        
        if(searchActive){
            cell!.textLabel!.text = filtered[indexPath.row].0
            cell!.detailTextLabel!.text = filtered[indexPath.row].1
        } else {
            cell!.textLabel!.text = people[indexPath.row].0
            cell!.detailTextLabel!.text = people[indexPath.row].1
        }
        
        return cell!;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        self.dismissViewControllerAnimated(true, completion: { _ in
            try! self.completionFn(cell!.detailTextLabel!.text!)
        })
    }
}
