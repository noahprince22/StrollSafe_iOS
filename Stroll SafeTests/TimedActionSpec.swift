//
//  TimedActionSpec.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/3/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Stroll_Safe

class TimedActionSpec: QuickSpec {
    
    override func spec() {
        describe("The Timed Action Util") {
            let tolerance = 0.15
            
            it("executes a function at the given interval") {
                let secondsToRun: Double = 1
                let recurrentInterval = 0.001
                
                var totalTime: Double = 0
                var executeTimesCalled = 0
                let timedActionBuilder = Stroll_Safe.TimedActionBuilder { builder in
                    builder.secondsToRun = secondsToRun
                    builder.recurrentInterval = recurrentInterval
                    builder.recurrentFunction = { (timeElapsed: Double) in
                        expect(timeElapsed).to(beGreaterThanOrEqualTo(totalTime))
                        totalTime += recurrentInterval
                        executeTimesCalled++
                    }
                }
                
                Stroll_Safe.TimedAction(builder: timedActionBuilder).run()
                expect(executeTimesCalled).toEventually(beGreaterThan(2), timeout: secondsToRun)
            }
            
            it("executes an exit function") {
                let secondsToRun: Double = 0.8
                let recurrentInterval = 0.005
                
                var exitFunctionCalled = false
                let timedActionBuilder = TimedActionBuilder { builder in
                    builder.secondsToRun = secondsToRun
                    builder.recurrentInterval = recurrentInterval
                    builder.exitFunction = { (timeElapsed: Double) in
                        exitFunctionCalled = true
                        expect(timeElapsed).to(beCloseTo(secondsToRun, within: tolerance))
                    }
                }
                
                TimedAction(builder: timedActionBuilder).run()
                expect(exitFunctionCalled).toEventually(beTrue(), timeout: secondsToRun + tolerance)
            }

            it("stops with a break condition") {
                let secondsToRun: Double = 0.6
                let recurrentInterval = 0.002
                let breakTime = 0.3
                
                var totalTime: Double = 0
                var executeTimesCalled = 0
                let timedActionBuilder = TimedActionBuilder { builder in
                    builder.secondsToRun = secondsToRun
                    builder.recurrentInterval = recurrentInterval
                    builder.recurrentFunction = { (timeRemaining: Double) in
                        expect(timeRemaining).to(beGreaterThanOrEqualTo(totalTime))
                        totalTime += recurrentInterval
                        executeTimesCalled++
                    }
                    builder.breakCondition = { (timeElapsed: Double) -> Bool in
                        return timeElapsed >= breakTime
                    }
                }
                
                TimedAction(builder: timedActionBuilder).run()
                expect(executeTimesCalled).toEventually(beGreaterThan(1), timeout: breakTime)
            }
            
            it("accelerates when enableAcceleration is called") {
                let secondsToRun: Double = 10.03
                let accelerationRate = 0.8
                
                var executeTimesCalled = 0
                let timedActionBuilder = TimedActionBuilder { builder in
                    builder.secondsToRun = secondsToRun
                    builder.recurrentFunction = { (timeElapsed: Double) in
                        executeTimesCalled++
                    }
                    builder.accelerationRate = accelerationRate
                }
                
                let action = TimedAction(builder: timedActionBuilder)
                action.run()
                action.enableAcceleration()
                expect(executeTimesCalled).toEventually(beGreaterThan(3), timeout: 1)
            }
            
            it("stops accelerating when disableAcceleration is called") {
                let secondsToRun:Double  = 1
                let recurrentInterval = 0.001
                let accelerationRate:Double = 0.01
                
                var exitFunctionCalled = false
                let timedActionBuilder = TimedActionBuilder { builder in
                    builder.secondsToRun = secondsToRun
                    builder.recurrentInterval = recurrentInterval
                    builder.accelerationRate = accelerationRate
                    builder.exitFunction = { (timeElapsed: Double) in
                        exitFunctionCalled = true
                        expect(timeElapsed).to(beCloseTo(secondsToRun, within: tolerance))
                    }
                }
                
                let action = TimedAction(builder: timedActionBuilder)
                action.run()
                action.enableAcceleration()
                action.disableAcceleration()
                
                // It should still be running at this point
                NSThread.sleepForTimeInterval(0.5)
                expect(exitFunctionCalled).to(beFalse())
                NSThread.sleepForTimeInterval(0.5 + tolerance)
                expect(exitFunctionCalled).to(beTrue())
            }
            
            it ("pauses") {
                let secondsToRun: Double = 0.8
                let recurrentInterval = 0.005
                
                var exitFunctionCalled = false
                let timedActionBuilder = TimedActionBuilder { builder in
                    builder.secondsToRun = secondsToRun
                    builder.recurrentInterval = recurrentInterval
                    builder.exitFunction = { (timeElapsed: Double) in
                        exitFunctionCalled = true
                        expect(timeElapsed).to(beCloseTo(secondsToRun, within: tolerance))
                    }
                }
                
                let action = TimedAction(builder: timedActionBuilder)
                action.run()
                action.pause()
                NSThread.sleepForTimeInterval(0.8 + tolerance)
                expect(exitFunctionCalled).to(beFalse())
                action.run()
                expect(exitFunctionCalled).toEventually(beTrue(), timeout: secondsToRun + tolerance)
            }
        }
    }
}