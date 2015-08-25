//
//  TutorialContentViewController.swift
//  Stroll Safe
//
//  Created by Lynda Prince on 8/11/15.
//  Copyright © 2015 Stroll Safe. All rights reserved.
//

import UIKit

class TutorialContentViewController: UIViewController {
    
    var pageIndex: Int!
    var descriptionText: String!
    var imageFile: String!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imageView.image = UIImage(named: self.imageFile)
        self.desc.text = self.descriptionText
        self.desc.font = UIFont.systemFontOfSize(15)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
