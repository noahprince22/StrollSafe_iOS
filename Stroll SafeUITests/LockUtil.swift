//
//  LockUtil.swift
//  Stroll Safe
//
//  Created by Noah Prince on 7/25/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation
import XCTest

class LockUtil {
    var currentFocused = "First"
    var app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    // Presses a key and makes sure the placeholder is filled
    // When the key is the fourth keypress, verifies a placeholder clear
    func keyPressAndVerify(key: String){
        XCTAssertFalse(currentPlaceholderFilled())
        let button = app.buttons[key]
        button.tap()
        
        switch(key) {
        case "clear":
            verifyClear()
        case "back":
            // Verify our current placeholder didn't get filled
            XCTAssertFalse(currentPlaceholderFilled())
            previousFocused()
        default:
            nextFocused()
        }
    }
    
    func testBackAndClear() {
        keyPressAndVerify("back");
        keyPressAndVerify("1");
        keyPressAndVerify("back");
        keyPressAndVerify("1");
        keyPressAndVerify("2");
        keyPressAndVerify("back");
        keyPressAndVerify("back");
        keyPressAndVerify("back");
        keyPressAndVerify("1");
        keyPressAndVerify("2");
        keyPressAndVerify("9");
        keyPressAndVerify("back");
        keyPressAndVerify("1");
        keyPressAndVerify("clear")
    }
    
    private func currentPlaceholderFilled() -> Bool {
        return app.images[currentFocused].hittable
    }
    
    private func nextFocused() {
        if (currentFocused != "Fourth") {
            XCTAssert(currentPlaceholderFilled())
        }
        
        switch currentFocused {
        case "First":
            currentFocused = "Second"
        case "Second":
            currentFocused = "Third"
        case "Third":
            currentFocused = "Fourth"
        default:
            verifyClear()
        }
    }
    
    private func previousFocused() {
        switch currentFocused {
        case "Second":
            currentFocused = "First"
        case "Third":
            currentFocused = "Second"
        case "Fourth":
            currentFocused = "Third"
        default:
            currentFocused = "First"
        }
        
        
        // Verify the the back one was erased
        XCTAssertFalse(currentPlaceholderFilled())
    }
    
    private func verifyClear(){
        if (app.buttons["First"].exists) {
            XCTAssertFalse(app.buttons["First"].hittable)
            XCTAssertFalse(app.buttons["Second"].hittable)
            XCTAssertFalse(app.buttons["Third"].hittable)
            XCTAssertFalse(app.buttons["Fourth"].hittable)
        }
        currentFocused = "First"
    }
}

