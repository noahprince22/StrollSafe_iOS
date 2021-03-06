//
//  RightToLeftSegue.swift
//  Stroll Safe
//
//  Created by Noah Prince on 8/27/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import UIKit

class LeftToRightSegue: UIStoryboardSegue {
    
    override func perform() {
        let src: UIViewController = self.sourceViewController 
        let dst: UIViewController = self.destinationViewController
        
        let finalFrame  = src.view.bounds
        let initalFrame = CGRect(x: -finalFrame.width, y: 0, width: finalFrame.width, height: finalFrame.height)
        
        dst.view.frame = initalFrame
        UIView.animateWithDuration(0.25, animations: { dst.view.frame = finalFrame })
        src.navigationController!.pushViewController(dst, animated: false)
    }
}
