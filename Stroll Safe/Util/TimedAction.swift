//
//  TimedAction.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/4/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation

class TimedActionBuilder {
    var secondsToRun: Double?
    var recurrentInterval: Double?
    var recurrentFunction: ((Double) -> (Void))?
    var exitFunction: ((Double) -> (Void))?
    var breakCondition: ((Double) -> Bool)?
    var accelerationRate: Double?
    
    typealias BuilderClosure = (TimedActionBuilder) -> ()
    
    init(buildClosure: BuilderClosure) {
        buildClosure(self)
    }
}

class TimedAction {
    var secondsToRun: Double = 1
    var recurrentInterval: Double = 0.00001
    var recurrentFunction: (Double) -> (Void) = { timeElapsed in }
    var exitFunction: (Double) -> (Void) = {timeElapsed in }
    var breakCondition: (Double) -> (Bool) = {timeElapsed in return false}
    var accelerationRate: Double = 0.02
    
    var acceleratedIterations = 0
    var accelerated = false
    var paused = false
    var secondsRemaining: Double!
    
    init(builder: TimedActionBuilder) {
        if let secondsToRun = builder.secondsToRun {
            self.secondsToRun = secondsToRun
            self.secondsRemaining = secondsToRun
        }
        
        
        if let recurrentInterval = builder.recurrentInterval {
            self.recurrentInterval = recurrentInterval
        }
        
        if let recurrentFunction = builder.recurrentFunction {
            self.recurrentFunction = recurrentFunction
        }
        
        if let exitFunction = builder.exitFunction {
            self.exitFunction = exitFunction
        }
        
        if let breakCondition = builder.breakCondition {
            self.breakCondition = breakCondition
        }
        
        if let accelerationRate = builder.accelerationRate {
            self.accelerationRate = accelerationRate
        }
    }
    
    func run() {
        paused = false
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            var curTime = NSDate()
            while((self.secondsRemaining > 0) && !self.breakCondition(self.secondsToRun - self.secondsRemaining) && !self.paused) {
                curTime = NSDate()
                NSThread.sleepForTimeInterval(self.recurrentInterval)
                
                self.secondsRemaining = self.secondsRemaining - NSDate().timeIntervalSinceDate(curTime) - ((Double)(self.acceleratedIterations)*self.accelerationRate)
                
                if self.accelerated {
                    self.acceleratedIterations++
                }
                
                self.recurrentFunction(self.secondsToRun - self.secondsRemaining)
            }
            
            if (!self.paused) {
                self.exitFunction(self.secondsToRun - self.secondsRemaining)
            }
        })
    }
    
    func enableAcceleration() {
        accelerated = true
    }
    
    func disableAcceleration() {
        accelerated = false
        acceleratedIterations = 0
    }
    
    /**
    Suspends the asynch thread
    */
    func pause() {
        paused = true
    }
}
