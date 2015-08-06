//
//  PinpadViewControllSpec.swift
//  Stroll Safe
//
//  Created by Noah Prince on 7/26/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Stroll_Safe

class PinpadViewControllerSpec: QuickSpec {
    override func spec() {
        describe ("the view") {
            var viewController: Stroll_Safe.PinpadViewController!
            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                viewController =
                    storyboard.instantiateViewControllerWithIdentifier(
                        "Pinpad") as! Stroll_Safe.PinpadViewController
                
                viewController.beginAppearanceTransition(true, animated: false)
                viewController.endAppearanceTransition()
            }
            
            func expectClear() {
                // All should still be unfilled
                expect(viewController.first.hidden).to(beTrue())
                expect(viewController.second.hidden).to(beTrue())
                expect(viewController.third.hidden).to(beTrue())
                expect(viewController.fourth.hidden).to(beTrue())
            }
            
            it ("starts out cleared") {
                expectClear();
            }
            
            // The following three should cover all number presses
            describe ("number buttons") {
                it ("fills placeholders for numbers") {
                    expect(viewController.first.hidden).to(beTrue())
                    viewController.buttonOne(self)
                    expect(viewController.first.hidden).to(beFalse())
                    
                    expect(viewController.second.hidden).to(beTrue())
                    viewController.buttonTwo(self)
                    expect(viewController.second.hidden).to(beFalse())
                    
                    expect(viewController.third.hidden).to(beTrue())
                    viewController.buttonThree(self)
                    expect(viewController.third.hidden).to(beFalse())
                    
                    expect(viewController.fourth.hidden).to(beTrue())
                    viewController.buttonFour(self)
                    expect(viewController.fourth.hidden).to(beFalse())
                }
                
                it ("does not enter more numbers when over four are type") {
                    viewController.buttonFive(self)
                    viewController.buttonSix(self)
                    viewController.buttonSeven(self)
                    viewController.buttonEight(self)
                    viewController.buttonNine(self)
                    viewController.buttonZero(self)
                    
                    // All should still be filled
                    expect(viewController.first.hidden).to(beFalse())
                    expect(viewController.second.hidden).to(beFalse())
                    expect(viewController.third.hidden).to(beFalse())
                    expect(viewController.fourth.hidden).to(beFalse())
                }
              }
            
            describe ("the back button") {
                it("unfills the first placeholder") {
                    viewController.buttonFive(self)
                    
                    viewController.buttonBack(self)
                    expect(viewController.first.hidden).to(beTrue())
                }
                
                it ("unfills the second placeholder") {
                    viewController.buttonSix(self)
                    viewController.buttonSeven(self)
                    
                    viewController.buttonBack(self)
                    expect(viewController.second.hidden).to(beTrue())
                }
                
                it ("unfills the third placeholder") {
                    viewController.buttonSeven(self)
                    viewController.buttonEight(self)
                    viewController.buttonEight(self)
                    
                    viewController.buttonBack(self)
                    expect(viewController.third.hidden).to(beTrue())
                }
                
                it ("unfills the fourth placeholder") {
                    viewController.buttonSeven(self)
                    viewController.buttonEight(self)
                    viewController.buttonEight(self)
                    viewController.buttonOne(self)

                    
                    viewController.buttonBack(self)
                    expect(viewController.fourth.hidden).to(beTrue())
                }
                
                it ("can unfil multiple placeholders") {
                    viewController.buttonSeven(self)
                    viewController.buttonEight(self)
                    viewController.buttonEight(self)
                    viewController.buttonOne(self)
                    
                    
                    viewController.buttonBack(self)
                    expect(viewController.fourth.hidden).to(beTrue())
                    
                    viewController.buttonBack(self)
                    expect(viewController.third.hidden).to(beTrue())
                    
                    viewController.buttonBack(self)
                    expect(viewController.second.hidden).to(beTrue())
                    
                    viewController.buttonBack(self)
                    expect(viewController.first.hidden).to(beTrue())
                }
                
                it ("continues in the correct position after a back") {
                    viewController.buttonOne(self)
                    viewController.buttonTwo(self)
                    viewController.buttonThree(self)
                    
                    viewController.buttonBack(self)
                    
                    viewController.buttonOne(self)
                    
                    expect(viewController.first.hidden).to(beFalse())
                    expect(viewController.second.hidden).to(beFalse())
                    expect(viewController.third.hidden).to(beFalse())
                    expect(viewController.fourth.hidden).to(beTrue())
                }
                
                it ("does not do anything when it backspaces nothing") {
                    viewController.buttonBack(self)

                    
                    expectClear()
                }
            }
            
            describe ("the clear button") {
                it ("does nothing when nothing has been entered") {
                    viewController.buttonClear(self)
                    
                    
                    expectClear()
                }
                
                it ("clears when only partially full") {
                    viewController.buttonSix(self)
                    viewController.buttonSeven(self)
                    viewController.buttonClear(self)
                    
                    expectClear();
                }
                
                it ("clears when all are full") {
                    viewController.buttonSeven(self)
                    viewController.buttonEight(self)
                    viewController.buttonEight(self)
                    viewController.buttonOne(self)
                    viewController.buttonClear(self)

                    expectClear();
                }
                
                it ("allows typing after a clear") {
                    viewController.buttonOne(self)
                    viewController.buttonClear(self)
                    viewController.buttonTwo(self)
                    
                    expect(viewController.first.hidden).to(beFalse())
                }
            }
            
            it ("runs my function on completion with the correct pass") {
                var functionCalled = false
                viewController.setEnteredFunction({(pass: String) -> ()  in
                    expect(pass).to(equal("1234"))
                    viewController.clear();
                    
                    functionCalled = true
                })
                
                viewController.buttonOne(self)
                viewController.buttonTwo(self)
                viewController.buttonThree(self)
                viewController.buttonFour(self)
                
                expect(functionCalled).to(beTrue())
                expectClear();
            }
        }
    }
}