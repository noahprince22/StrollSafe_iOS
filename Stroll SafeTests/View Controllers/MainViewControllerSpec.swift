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
                        "MainView") as! Stroll_Safe.MainViewController

                viewController.beginAppearanceTransition(true, animated: false)
                viewController.endAppearanceTransition()
            }
            
            it ("starts out in the default state") {
                expect(viewController.thumb.hidden).to(beFalse())
                expect(viewController.thumbDesc.hidden).to(beFalse())
                expect(viewController.shake.hidden).to(beTrue())
                expect(viewController.shakeDesc.hidden).to(beTrue())
                expect(viewController.progressLabel.hidden).to(beTrue())
                expect(viewController.progressBar.hidden).to(beTrue())
            }
            
            it ("exposes the enable shake interface when the thumb is pressed") {
                viewController.thumbDown(UIButton())
            
                expect(viewController.thumb.hidden).to(beTrue())
                expect(viewController.thumbDesc.hidden).to(beTrue())
                expect(viewController.shake.hidden).to(beFalse())
                expect(viewController.shakeDesc.hidden).to(beFalse())
                expect(viewController.progressLabel.hidden).to(beTrue())
                expect(viewController.progressBar.hidden).to(beTrue())
            }
            
            it ("exposes the progress bar in release state") {
                viewController.enterDisplayReleaseState()
                
                expect(viewController.thumb.hidden).to(beFalse())
                expect(viewController.thumbDesc.hidden).to(beFalse())
                expect(viewController.shake.hidden).to(beTrue())
                expect(viewController.shakeDesc.hidden).to(beTrue())
                expect(viewController.progressLabel.hidden).to(beFalse())
                expect(viewController.progressBar.hidden).to(beFalse())
            }
            
            it ("exposes the exit button in shake state") {
                viewController.enterShakeState()
                
                expect(viewController.thumb.hidden).to(beTrue())
                expect(viewController.thumbDesc.hidden).to(beTrue())
                expect(viewController.shake.hidden).to(beFalse())
                expect(viewController.shakeDesc.hidden).to(beFalse())
                expect(viewController.progressLabel.hidden).to(beTrue())
                expect(viewController.progressBar.hidden).to(beTrue())
            }
            
            it ("can update the progress bar in the release state") {
                let expectedProgress = Stroll_Safe.MainViewController.TIME_TO_LOCKDOWN / 2
                viewController.updateProgress(expectedProgress)
                
                expect(viewController.progressBar.progress).to(beCloseTo(0.5, within: 0.05))
                let expectedProgressString = expectedProgress.format("0.2")
                expect(viewController.progressLabel.text).toEventually(contain(expectedProgressString), timeout: 0.5)
            }
            
            it ("does not lock down immediately when thumb is released") {
                viewController.thumbUpInside(UIButton())
                viewController.thumbDown(UIButton())
                
                expect(viewController.thumb.hidden).to(beTrue())
                expect(viewController.thumbDesc.hidden).to(beTrue())
                expect(viewController.shake.hidden).to(beFalse())
                expect(viewController.shakeDesc.hidden).to(beFalse())
                expect(viewController.progressLabel.hidden).to(beTrue())
                expect(viewController.progressBar.hidden).to(beTrue())
            }
        }
    }
}
