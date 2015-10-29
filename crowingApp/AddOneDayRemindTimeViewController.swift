//
//  AddOneDayRemindTimeViewController.swift
//  crowingApp
//
//  Created by michaeltam on 15/10/22.
//  Copyright © 2015年 mike公司. All rights reserved.
//

import UIKit

class AddOneDayRemindTimeViewController: UIViewController{

    @IBOutlet weak var datePicker: UIDatePicker!
    var remindTime:NSMutableDictionary = ["remindTime":"", "repeatInterval":""]
    let user = NSUserDefaults.standardUserDefaults()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //待优化：1）中文日期，分钟以5分钟为间隔， 2）默认取当前时间， 3）如果采已过去的时间就出错误提示
        
        datePicker.datePickerMode = UIDatePickerMode.DateAndTime
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func today(sender: AnyObject) {
    }
    @IBAction func tomorrow(sender: AnyObject) {
    }
    @IBAction func save(sender: AnyObject) {
        
        let time = datePicker.date
        let timeString = Functions.stringFromDate(time)
        
//        let repeatInterval:NSCalendarUnit = NSCalendarUnit.Minute
        let repeatInterval:String  = "none"
        
        remindTime.setValue(timeString, forKey: "remindTime")
        remindTime.setValue(repeatInterval, forKey: "repeatInterval")
        
        
        //假设user已经有remindTimeArray键
        var remindTimeArray = user.arrayForKey("remindTimeArray")!
        remindTimeArray.append(remindTime)
        user.setObject(remindTimeArray, forKey: "remindTimeArray")
        

    }
    
    //把值传递到目的VC，并执行逻辑处理
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addOneDayRemind" {
            let nextVC = segue.destinationViewController as! AddRemindViewController
            nextVC.remindTimeArray.append(remindTime)
            
        }
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
