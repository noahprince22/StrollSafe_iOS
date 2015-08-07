//
//  CommunicationsUtil.swift
//  Stroll Safe
//
//  Created by Lynda Prince on 8/6/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import Foundation
import MessageUI

class CommunicationUtil: UIViewController, MFMessageComposeViewControllerDelegate {
    
    // A wrapper function to indicate whether or not a text message can be sent from the user's device
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    // dismisses the view controller when the user is finished with it
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendSms(recipient: String, body: String) {
        if (canSendText()) {
            let messageComposeVC = MFMessageComposeViewController()
            
            messageComposeVC.messageComposeDelegate = self  //  set so that the controller can be dismissed!
            messageComposeVC.recipients = [recipient]
            messageComposeVC.body = body
            
            // The dismissal of the VC will be handled by the messageComposer instance,
            // since it implements the appropriate delegate call-back
            presentViewController(messageComposeVC, animated: true, completion: nil)
        } else {
            let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
}