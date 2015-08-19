//
//  SettingsViewControllerSpec.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/18/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Stroll_Safe

class SettingsViewControllerSpec: QuickSpec {
    
    override func spec() {
        describe ("the settings view") {
            var viewController: Stroll_Safe.SettingsViewController!
            
            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                viewController =
                    storyboard.instantiateViewControllerWithIdentifier(
                        "SettingsViewController") as! Stroll_Safe.SettingsViewController
                
                viewController.beginAppearanceTransition(true, animated: false)
                viewController.endAppearanceTransition()
            }
        }
    }
}