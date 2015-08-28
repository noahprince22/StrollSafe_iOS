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
    
    func testLoginWithSettings() -> XCUIApplication{
        let app = testCorrectSetPass()
        
        TutorialUtil(app: app).finishTutorial()
        
        let tablesQuery = app.tables
        tablesQuery.textFields["full_name"].tap()
        tablesQuery.textFields["full_name"].typeText("Urist McTest")
        tablesQuery.textFields["Please include area code"].tap()
        tablesQuery.textFields["phone_number"].typeText("3018675309")
        tablesQuery.cells.containingType(.StaticText, identifier:"Or").textFields["Number to Contact"].tap()
        tablesQuery.textFields["call_contact"].typeText("5555555555")
        
        let textContactTextField = tablesQuery.textFields["text_contact"]
        textContactTextField.tap()
        textContactTextField.typeText("555555555")
        
        let doneButton = app.navigationBars["Settings"].buttons["Save"]
        doneButton.tap()
        app.alerts["Oops!"].collectionViews.buttons["Ok"].tap()
        textContactTextField.typeText("5")
        doneButton.tap()
        
        return app
    }
    
    func testSpeedCall() {
        let app = testLoginWithSettings()

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
    
    func testSettingsButton() {
        let app = testLoginWithSettings()
        app.buttons["settings"].tap()

        let doneButton = app.navigationBars["Settings"].buttons["Save"]
        doneButton.tap()
    }
    
    func testTutorialButton() {
        let app = testLoginWithSettings()
        app.buttons["help"].tap()
        
        let tablesQuery = app.tables
        let sugguestAFeatureStaticText = tablesQuery.staticTexts["Sugguest a Feature"]
        sugguestAFeatureStaticText.tap()
        
        let textField = tablesQuery.cells.containingType(.StaticText, identifier:"Subject:").childrenMatchingType(.TextField).element
        textField.tap()
        textField.typeText("sjkdfhkjs")
        
        let textView = tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(1).childrenMatchingType(.TextView).element
        textView.tap()
        textView.typeText("jhsadfkjs")
        
        let strollSafeMessagetableviewNavigationBar = app.navigationBars["Stroll_Safe.MessageTableView"]
        let doneButton = strollSafeMessagetableviewNavigationBar.buttons["Done"]
        let deleteButton = strollSafeMessagetableviewNavigationBar.buttons["Delete"]

        doneButton.tap()
        
        sugguestAFeatureStaticText.tap()
        deleteButton.tap()
        
        let reportABugStaticText = tablesQuery.staticTexts["Report a Bug"]
        reportABugStaticText.tap()
        textField.tap()
        textField.typeText("jkfghkfjdgh")
        textView.tap()
        textView.typeText("dfkjhgfdkjg")
        doneButton.tap()
        
        reportABugStaticText.tap()
        deleteButton.tap()
        
        app.tables.staticTexts["View Tutorial"].tap()
        
        TutorialUtil(app: app).finishTutorial()
    }
    
    /** Covers: Releasing your finger and placing it back
                Incorrect pass code entry
                Back button press
                Clear
                Disarming and rearming
                Base call with full 20 second wait
    */
    // TODO: Adding the settings view broke this test, it finds multiple matches for everything on the lock screen
    //    so we don't use the lockutil or any verify on the lock screen view. It's bad, and needs to be fixed
    //    but since they both use the same view, the view does get verified in setup pin.
    func testReleaseArmDisarm(){
        let app = testLoginWithSettings()

        let fingerIconButton = app.buttons["finger icon"]
        fingerIconButton.tap()
        
        let lockUtil = LockUtil(app: app)
        // Test valid entries
        lockUtil.keyPressAndVerify("2");
        lockUtil.keyPressAndVerify("2");
        lockUtil.keyPressAndVerify("4");
        lockUtil.keyPressAndVerify("4");

        fingerIconButton.tap()
        
        lockUtil.keyPressAndVerify("2");
        lockUtil.keyPressAndVerify("2");
        lockUtil.keyPressAndVerify("4");
        lockUtil.keyPressAndVerify("4");
    }
    
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
