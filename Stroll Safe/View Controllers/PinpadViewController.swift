//
//  PinpadViewController.swift
//  Stroll Safe
//
//  Created by noah prince on 3/25/15.
//  Copyright (c) 2015 Stroll Safe. All rights reserved.
//

import UIKit

class PinpadViewController: UIViewController {

    @IBOutlet weak var first: UIButton!
    @IBOutlet weak var second: UIButton!
    @IBOutlet weak var third: UIButton!
    @IBOutlet weak var fourth: UIButton!
    
    @IBOutlet weak var placeholder1: UIView!
    @IBOutlet weak var placeholder2: UIView!
    @IBOutlet weak var placeholder3: UIView!
    @IBOutlet weak var placeholder4: UIView!
    
    var correctPass = [Double](count: 4, repeatedValue: 2.0)
    var passField = [Double](count: 4, repeatedValue: 0.0)
    var currentIdx = 0;

    var enteredFn: (String) throws -> () = { (String) -> () in }
    
    func setEnteredFunction(fn: (String) throws -> ()) {
        enteredFn = fn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        clear()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clear(){
        first.hidden = true
        second.hidden = true
        third.hidden = true
        fourth.hidden = true
        currentIdx = 0
    }
    
    func passFieldString() -> NSString{
        let passString = "\(Int(passField[0]))\(Int(passField[1]))\(Int(passField[2]))\(Int(passField[3]))"
        return passString
    }
    
    func setPass(value: Double){
        if (currentIdx < passField.count){
            passField[currentIdx] = value
            currentIdx++
        }
        
        switch currentIdx{
        case 1:
            first.hidden = false
        case 2:
            second.hidden = false
        case 3:
            third.hidden = false
        case 4:
            fourth.hidden = false
            try! enteredFn(getCurrentPass() as String)

        default:
            print("Invalid")
        }
        
    }
    
    func shake(){
        let numbers = [placeholder1,placeholder2,placeholder3,placeholder4]
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            for filler in numbers {
                dispatch_async(dispatch_get_main_queue(), {
                    let number = filler as UIView
                    
                    let animation = CABasicAnimation(keyPath: "position")
                    animation.duration = 0.07
                    animation.repeatCount = 4
                    animation.autoreverses = true
                    animation.fromValue = NSValue(CGPoint: CGPointMake(number.center.x - 10, number.center.y))
                    animation.toValue = NSValue(CGPoint: CGPointMake(number.center.x    + 10, number.center.y))
                    number.layer.addAnimation(animation, forKey: "position")
                })
            }
        })
    }
    
    func getCurrentPass() -> NSString {
        return passFieldString()
    }

    
    @IBAction func buttonOne(sender: AnyObject) {
        setPass(1)
    }
    
    @IBAction func buttonTwo(sender: AnyObject) {
        setPass(2)
    }

    @IBAction func buttonThree(sender: AnyObject) {
        setPass(3)
    }
    
    @IBAction func buttonFour(sender: AnyObject) {
        setPass(4)
    }
    
    
    @IBAction func buttonFive(sender: AnyObject) {
        setPass(5)
    }
    
    @IBAction func buttonSix(sender: AnyObject) {
        setPass(6)
    }
    
    @IBAction func buttonSeven(sender: AnyObject) {
        setPass(7)
    }
    
    @IBAction func buttonEight(sender: AnyObject) {
        setPass(8)
    }
    
    @IBAction func buttonNine(sender: AnyObject) {
        setPass(9)
    }
    
    @IBAction func buttonClear(sender: AnyObject) {
        first.hidden = true
        second.hidden = true
        third.hidden = true
        fourth.hidden = true
        
        currentIdx = 0
    }
    
    @IBAction func buttonZero(sender: AnyObject) {
        setPass(0)
    }
    
    @IBAction func buttonBack(sender: AnyObject) {
        switch currentIdx{
        case 0:
            print("Invalid")
            return
        case 1:
            first.hidden = true
        case 2:
            second.hidden = true
        case 3:
            third.hidden = true
        case 4:
            fourth.hidden = true
        default:
            print("Invalid")
        }
        
        currentIdx--
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
