//
//  PinpadViewControllSpec.swift
//  Stroll Safe
//
//  Created by Noah Prince on 7/31/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Stroll_Safe

// Lets the time display as 2.00 and not 2
extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}

class MainViewControllerSpec: QuickSpec {
    
    override func spec() {
        describe ("the main view") {
            var viewController: Stroll_Safe.MainViewController!
            
            beforeEach {
                MainViewController.test = true

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                viewController =
                    storyboard.instantiateViewControllerWithIdentifier(
                        "MainViewController") as! Stroll_Safe.MainViewController

                viewController.beginAppearanceTransition(true, animated: false)
                viewController.endAppearanceTransition()
            }
            
            it ("enters the shake state when interrupted while armed") {
                viewController.thumbDown(UIButton())
               
                NSNotificationCenter.defaultCenter().postNotificationName("UIApplicationWillResignActiveNotification", object:self, userInfo:nil);
                
                
                expect(viewController.thumb.hidden).to(beTrue())
                expect(viewController.thumbDesc.hidden).to(beTrue())
                expect(viewController.settings.hidden).to(beTrue())
                expect(viewController.help.hidden).to(beTrue())
                expect(viewController.shake.hidden).to(beFalse())
                expect(viewController.shakeDesc.hidden).to(beFalse())
                expect(viewController.progressLabel.hidden).to(beTrue())
                expect(viewController.progressBar.hidden).to(beTrue())
            }
            
            it ("does stays in the default state when interrupted and not armed") {
                NSNotificationCenter.defaultCenter().postNotificationName("UIApplicationWillResignActiveNotification", object:self, userInfo:nil);
                
                expect(viewController.thumb.hidden).to(beFalse())
                expect(viewController.thumbDesc.hidden).to(beFalse())
                expect(viewController.settings.hidden).to(beFalse())
                expect(viewController.help.hidden).to(beFalse())
                expect(viewController.shake.hidden).to(beTrue())
                expect(viewController.shakeDesc.hidden).to(beTrue())
                expect(viewController.progressLabel.hidden).to(beTrue())
                expect(viewController.progressBar.hidden).to(beTrue())
            }
            
            it ("starts out in the default state") {
                expect(viewController.thumb.hidden).to(beFalse())
                expect(viewController.thumbDesc.hidden).to(beFalse())
                expect(viewController.settings.hidden).to(beFalse())
                expect(viewController.help.hidden).to(beFalse())
                expect(viewController.shake.hidden).to(beTrue())
                expect(viewController.shakeDesc.hidden).to(beTrue())
                expect(viewController.progressLabel.hidden).to(beTrue())
                expect(viewController.progressBar.hidden).to(beTrue())
            }
            
            it ("exposes the enable shake interface when the thumb is pressed") {
                viewController.thumbDown(UIButton())
            
                expect(viewController.thumb.hidden).to(beTrue())
                expect(viewController.thumbDesc.hidden).to(beTrue())
                expect(viewController.settings.hidden).to(beTrue())
                expect(viewController.help.hidden).to(beTrue())
                expect(viewController.shake.hidden).to(beFalse())
                expect(viewController.shakeDesc.hidden).to(beFalse())
                expect(viewController.progressLabel.hidden).to(beTrue())
                expect(viewController.progressBar.hidden).to(beTrue())
            }
            
            it ("exposes the progress bar in release state") {
                viewController.enterDisplayReleaseState()
                
                expect(viewController.thumb.hidden).to(beFalse())
                expect(viewController.thumbDesc.hidden).to(beFalse())
                expect(viewController.settings.hidden).to(beFalse())
                expect(viewController.help.hidden).to(beFalse())
                expect(viewController.shake.hidden).to(beTrue())
                expect(viewController.shakeDesc.hidden).to(beTrue())
                expect(viewController.progressLabel.hidden).to(beFalse())
                expect(viewController.progressBar.hidden).to(beFalse())
            }
            
            it ("exposes the exit button in shake state") {
                viewController.enterShakeState()
                
                expect(viewController.thumb.hidden).to(beTrue())
                expect(viewController.thumbDesc.hidden).to(beTrue())
                expect(viewController.settings.hidden).to(beTrue())
                expect(viewController.help.hidden).to(beTrue())
                expect(viewController.shake.hidden).to(beFalse())
                expect(viewController.shakeDesc.hidden).to(beFalse())
                expect(viewController.progressLabel.hidden).to(beTrue())
                expect(viewController.progressBar.hidden).to(beTrue())
            }
            
            it ("does not lock down immediately when thumb is released") {
                viewController.thumbUpInside(UIButton())
                viewController.thumbDown(UIButton())
                
                expect(viewController.thumb.hidden).to(beTrue())
                expect(viewController.thumbDesc.hidden).to(beTrue())
                expect(viewController.settings.hidden).to(beTrue())
                expect(viewController.help.hidden).to(beTrue())
                expect(viewController.shake.hidden).to(beFalse())
                expect(viewController.shakeDesc.hidden).to(beFalse())
                expect(viewController.progressLabel.hidden).to(beTrue())
                expect(viewController.progressBar.hidden).to(beTrue())
            }
            
            describe("lockdown timer") {
                var action: TimedAction!
                var conf: Stroll_Safe.Configuration!
                let releaseDuration: Double = 1
                
                beforeEach {
                    let moc = TestUtils().setUpInMemoryManagedObjectContext()
                    conf = TestUtils().getNewConfigurationItem(moc)
                    conf.passcode = "1234"
                    conf.release_duration = releaseDuration
                    try! moc.save()
                    
                    viewController.enterDisplayReleaseState()
                    viewController.configure(moc)
                    action = viewController.dispatchLockdownTimer()
                    
                    // We don't want this action actually doing anything, just want to check some values
                    action.pause()
                }
                
                it ("sets the correct value for the release duration") {
                    expect(action.secondsToRun).to(equal(releaseDuration))
                }
                
                it ("breaks only when in release mode") {
                    expect(action.breakCondition(0.0)).to(beFalse())
                    viewController.enterThumbState()
                    expect(action.breakCondition(0)).to(beTrue())
                }
                
                it ("updates the progress bar in the release state on recurrent function") {
                    let expectedProgress = action.secondsToRun / 2
                    action.recurrentFunction(expectedProgress)
                    
                    expect(viewController.progressBar.progress).to(beCloseTo(0.5, within: 0.05))
                    let expectedProgressString = expectedProgress.format("0.2")
                    expect(viewController.progressLabel.text).toEventually(contain(expectedProgressString), timeout: 0.5 + 0.05)
                }
            }
        }
    }
}
