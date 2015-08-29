//
//  TutorialViewController.swift
//  Stroll Safe
//
//  Created by Lynda Prince on 8/11/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController!
    var pageTitles: NSArray!
    var pageImages: NSArray!
    
    var delegate: DismissableViewDelegate! = nil
    
    static var MAIN_DESC = "To arm the app, place your finger on the fingerprint button and hold it on the phone until you feel safe"
    static var RELEASE_DESC = "After lifting your finger, you will have 1.5 seconds to replace the finger to cancel."
    static var THUMB_DESC = "To enter shake mode, slide your finger to the shake mode button and release"
    static var SHAKE_DESC = "In shake mode, when you are in danger, just shake your phone.\n\nPlease do not lock your screen or exit the app while in shake mode; shake gestures will not be received."
    static var LOCKDOWN_DESC = "To disarm, enter your passcode within the time limit.\n\nDo not exit the app or lock your screen; emergency text messages will send, but phone calls will not."

    @IBOutlet weak var gotIt: UIButton!

    @IBAction func gotItPressed(sender: AnyObject) {
        delegate.dismiss(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = self.navigationController {
            navController.navigationBarHidden = true
        }

        // Do any additional setup after loading the view.
        self.pageTitles = NSArray(objects: TutorialViewController.MAIN_DESC, TutorialViewController.RELEASE_DESC, TutorialViewController.THUMB_DESC, TutorialViewController.SHAKE_DESC, TutorialViewController.LOCKDOWN_DESC)
        self.pageImages = NSArray(objects: "mainscreen.png", "release.png", "thumbdown.png", "shakemode",  "lockdown.png")
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialPageViewController") as! UIPageViewController
        
        self.pageViewController.dataSource = self
        
        let startVC = self.viewControllerAtIndex(0) as TutorialContentViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.width, self.view.frame.size.height - 60)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        gotIt.hidden = true
        gotIt.layer.zPosition = 1000
        self.view.bringSubviewToFront(gotIt)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
    Creates a new content view controller and sets the correct title and image
    
    :param: index <#index description#>
    
    :returns: <#return value description#>
    */
    func viewControllerAtIndex(index: Int) -> TutorialContentViewController {
        if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return TutorialContentViewController()
        }
        
        let vc: TutorialContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialContentViewController") as! TutorialContentViewController
        
        vc.imageFile = self.pageImages[index] as! String
        vc.descriptionText = self.pageTitles[index] as! String
        vc.pageIndex = index
        
        return vc
    }
    
    // MARK: - Page View Controller Data Source
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! TutorialContentViewController
        var index = vc.pageIndex as Int
        
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! TutorialContentViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound) {
            return nil
        }
        
        index++
        
        if (index == self.pageTitles.count) {
            return nil
        }
        
        if (index == pageTitles.count - 1) {
            gotIt.hidden = false
        }
        
        return self.viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
