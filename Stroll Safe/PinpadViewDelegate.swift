//
//  PinpadViewDelegate.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/29/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation

protocol PinpadViewDelegate {
    func passEntered(controller: PinpadViewController, pass: String)
}