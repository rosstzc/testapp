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


func dateFromStringWithFormat(timeString:String, format:String = "yyyy-MM-dd HH:mm:ss") -> NSDate{
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = format
    let time = dateFormatter.dateFromString(timeString)
    return time!
}


func stringFromDateWithFormat(time:NSDate, format:String = "yyyy-MM-dd") -> String{
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = format
    let timeString = dateFormatter.stringFromDate(time)
    return timeString
}


//指定格式显示时间
func timeStringForMessage(time:NSDate, type:String = "message") ->String{
    var timeStamp = ""
    let nowTime = NSDate()
    let gapTime =  Int(nowTime.timeIntervalSinceDate(time))
    
    let interval:NSTimeInterval = 24*60*60
    let yesterday:NSDate  = nowTime.dateByAddingTimeInterval(-interval)
    let beforeYesterday:NSDate = nowTime.dateByAddingTimeInterval(-interval*2)
    
    let timeString = stringFromDateWithFormat(time)
    let nowTimeString = stringFromDateWithFormat(nowTime)
    let yesterdayString = stringFromDateWithFormat(yesterday)
    let beforeYesterdayString = stringFromDateWithFormat(beforeYesterday)
    
    //五分钟内显示刚刚
    if (gapTime < 300) {
        timeStamp = "刚刚"
    }
        //五分钟以上且一个小时之内的，显示“多少分钟前”，例如“5分钟前”
    else if (300 < gapTime && gapTime < 60*60) {
        timeStamp = "\(gapTime/60)分钟前"
    }
        
        
        //显示今天时间
    else if (timeString == nowTimeString ) {
        
        if type == "message" {
            let temp = Int(stringFromDateWithFormat(time, format: "H"))
            if (0 <= temp && temp <= 11) {
                timeStamp = ("\(stringFromDateWithFormat(time, format: "h:mm"))")
            }else {
                timeStamp = ("下午\(stringFromDateWithFormat(time, format: "h:mm"))")
            }
        }
        
        //当在timeline显示时，采用最近24小时方式展示
        if type == "timeline" {
            timeStamp = "\(gapTime/3600)小时前"
        }
        
        
    }
        //显示昨天
    else if (timeString == yesterdayString) {
        timeStamp = "昨天"
        //        当在timeline显示时，采用最近24小时方式展示
        if (type == "timeline" && gapTime < 24*60*60) {
            timeStamp = "\(gapTime/3600)小时前"
        }
        
    }
        //显示前天
    else if (timeString == beforeYesterdayString) {
        timeStamp = "前天"
    }
        //显示日期
    else{
        timeStamp = stringFromDateWithFormat(time, format: "yy/M/d")
        
    }
    return timeStamp
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
