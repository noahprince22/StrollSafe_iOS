//
//  MessageTableViewControllerSpec.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/27/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//


import Foundation
import Quick
import Nimble
@testable import Stroll_Safe

class MessageTableViewControllerSpec: QuickSpec {
    
    override func spec() {
        describe ("the message table view") {
            var viewController: MessageTableViewController!
            
            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                viewController =
                    storyboard.instantiateViewControllerWithIdentifier(
                        "MessageTableViewController") as! Stroll_Safe.MessageTableViewController
                
                viewController.beginAppearanceTransition(true, animated: false)
                viewController.endAppearanceTransition()
            }
            
            it ("can have configure") {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                viewController =
                    storyboard.instantiateViewControllerWithIdentifier(
                        "MessageTableViewController") as! Stroll_Safe.MessageTableViewController
                
                let placeholder = "hello"
                viewController.configure = { _ in
                    viewController.subjectField.placeholder = placeholder
                }
                
                viewController.beginAppearanceTransition(true, animated: false)
                viewController.endAppearanceTransition()
                
                expect(viewController.subjectField.placeholder).to(equal(placeholder))

            }
            
            it ("can get/set body") {
                let body = "hello"
                viewController.body = body
                expect(viewController.bodyField.text).to(equal(body))
                expect(viewController.body).to(equal(body))
            }
            
            it ("can get/set subject") {
                let subject = "hi"
                viewController.subject = subject
                expect(viewController.subjectField.text).to(equal(subject))
                expect(viewController.subject).to(equal(subject))
            }
            
            it ("can have empty subject/body") {
                expect(viewController.subject).to(equal(""))
                expect(viewController.subject).to(equal(""))
            }
            
            it ("doesn't require done action") {
                try! viewController.doneAction()
            }
            
            it ("doesn't require trash action") {
                try! viewController.trashAction()
            }
            
            it ("executes an action when done is clicked") {
                var hit = false
                viewController.trashAction = { _ in
                    hit = true
                }
                
                viewController.trash(self)
                expect(hit).to(beTrue())
            }
            
            it ("executes an action when trash is clicked") {
                var hit = false
                viewController.doneAction = { _ in
                    hit = true
                }
                
                viewController.done(self)
                expect(hit).to(beTrue())
            }
        }
    }
}