//
//  Stroll_SafeUITests.swift
//  Stroll SafeUITests
//
//  Created by Noah Prince on 7/25/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import XCTest
import CoreData
import UIKit
import Foundation
@testable import Stroll_Safe

class Stroll_SafeUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        // Delete all existing passcodes in CoreData for a fresh state
        //Passcode.purge()
    }
    
    func testSpeedCall(){
        let app = testCorrectSetPass()
        app.buttons["Done"].tap()

        let fingerIconButton = app.buttons["finger icon"]
        fingerIconButton.tap()
        sleep(2)
        app.buttons["speed-dial"].pressForDuration(3)
        let timeRemaining = app.descendantsMatchingType(.StaticText)["timeRemaining"].label
      
        XCTAssertEqual(timeRemaining, "0")
    }
    
    func testIncorrectSetPass() {
        let app = XCUIApplication()
        app.buttons["I Agree, Continue"].tap()
        let element = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element
        element.swipeLeft()
        element.swipeLeft()
        element.swipeLeft()
        element.swipeLeft()
        app.buttons["Got it!"].tap()
        
        let lockUtil = LockUtil(app: app)
        
        // Test invalid second entry
        lockUtil.keyPressAndVerify("1");
        lockUtil.keyPressAndVerify("2");
        lockUtil.keyPressAndVerify("3");
        lockUtil.keyPressAndVerify("4");
        
        lockUtil.keyPressAndVerify("5");
        lockUtil.keyPressAndVerify("6");
        lockUtil.keyPressAndVerify("7");
        lockUtil.keyPressAndVerify("8");
        
        lockUtil.testBackAndClear();
    }
    
    func testCorrectSetPass() -> XCUIApplication {
        let app = XCUIApplication()
        app.buttons["I Agree, Continue"].tap()
        let element = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element
        element.swipeLeft()
        element.swipeLeft()
        element.swipeLeft()
        element.swipeLeft()
        app.buttons["Got it!"].tap()
        
        let lockUtil = LockUtil(app: app)
        // Test valid entries
        lockUtil.keyPressAndVerify("2");
        lockUtil.keyPressAndVerify("2");
        lockUtil.keyPressAndVerify("4");
        lockUtil.keyPressAndVerify("4");
        
        lockUtil.keyPressAndVerify("2");
        lockUtil.keyPressAndVerify("2");
        lockUtil.keyPressAndVerify("4");
        lockUtil.keyPressAndVerify("4");
        
        return app;
    }
    
    /** Covers: Releasing your finger and placing it back
                Incorrect pass code entry
                Back button press
                Clear
                Disarming and rearming
                Base call with full 20 second wait
    */
    // Beta 5 broke this test, it finds multiple matches for everything on the lock screen
//    func testReleaseArmDisarm(){
//        let app = testCorrectSetPass()
//        app.buttons["Done"].tap()
//
//        let fingerIconButton = app.buttons["finger icon"]
//        // Press and lift release quickly
//        fingerIconButton.pressForDuration(0.9)
//        fingerIconButton.pressForDuration(1)
//        NSThread.sleepForTimeInterval(1.5)
//
//        let lockUtil = LockUtil(app: app)
//        
//        // Test invalid entry
//        lockUtil.keyPressAndVerify("1");
//        lockUtil.keyPressAndVerify("2");
//        lockUtil.keyPressAndVerify("3");
//        lockUtil.keyPressAndVerify("4");
//        
//        // Input valid entry
//        lockUtil.keyPressAndVerify("2");
//        lockUtil.keyPressAndVerify("2");
//        lockUtil.keyPressAndVerify("4");
//        lockUtil.keyPressAndVerify("4");
//        
//        // Rearm
//        fingerIconButton.pressForDuration(0.9)
//        NSThread.sleepForTimeInterval(1.5)
//
//        lockUtil.testBackAndClear();
//    }
    
/**  
    Shake mode is currently unsupported for testing
    func testShakeModeEnterExitArm(){
        let app = testCorrectSetPass()
        
        // Enable shake mode
        let fingerIconButton = app.buttons["finger icon"]
        let shakeIconButton = app.buttons["shake icon"]
        fingerIconButton.pressForDuration(0.8, thenDragToElement: shakeIconButton)
        let closeIcon = app.buttons["close icon"]
        
        closeIcon.pressForDuration(0.8);
        XCTAssertFalse(closeIcon.hittable)
    }*/
    
}
