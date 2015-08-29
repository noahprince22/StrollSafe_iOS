//
//  InfoNavigatorViewController.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/28/15.
//  Copyright © 

import UIKit

class InfoNavigatorViewController: UIViewController {
    
    var delegate: DismissableViewDelegate! = nil
    
    @IBAction func back(sender: UIBarButtonItem) {
        self.delegate.dismiss(self)
    }
}
