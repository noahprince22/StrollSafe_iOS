//
//  DismissableViewDelegate
//  Stroll Safe
//
//  Created by Noah Prince on 8/27/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//
// This is a protocol for a view that will either 'pop' itself or transition along another segway
// Hence, what it does when it is finished is variable

import Foundation
import UIKit

protocol DismissableViewDelegate {
    func dismiss(controller: UIViewController)
}
