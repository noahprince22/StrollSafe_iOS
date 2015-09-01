//
//  SimulatorUtility.swift
//  Stroll Safe
//
//  Created by Noah Prince on 9/1/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation

struct SimulatorUtility {
    private static let IS_TARGET_IPHONE_SIMULATOR = (TARGET_IPHONE_SIMULATOR != 0)
    
    static let isRunningSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
        }()
}