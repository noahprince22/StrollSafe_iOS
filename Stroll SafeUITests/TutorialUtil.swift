//
//  TutorialUtil.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/22/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation
import XCTest

class TutorialUtil {
    var app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }
    
    func finishTutorial() {
        let element = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element
        element.swipeLeft()
        element.swipeLeft()
        element.swipeLeft()
        element.swipeLeft()
        app.buttons["Got it!"].tap()
    }
}