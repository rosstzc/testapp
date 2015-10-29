//
//  Funs.swift
//  crowingApp
//
//  Created by michaeltam on 15/10/26.
//  Copyright © 2015年 mike公司. All rights reserved.
//

import UIKit


let siteUrl:String = "http://"

func temp2() {
    print("666")
}



class Functions: UIViewController {
    class func temp() ->String {
        print("2222")
        return "34"
    }
    
    class func abc() -> String {
        print("123")
        return "123"
    }

    
    class func dateFromString(timeString:String) -> NSDate{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let time = dateFormatter.dateFromString(timeString)
        return time!
    }
    
    class func stringFromDate(time:NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timeString = dateFormatter.stringFromDate(time)
        return timeString
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
