//
//  Funs.swift
//  crowingApp
//
//  Created by michaeltam on 15/10/26.
//  Copyright © 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData

let siteUrl:String = "http://"

func temp2() {
    print("666")
}


func addRemindMessage(remind:Remind, uid:String, time:NSDate, state:Int = 0) {
    // 写入提醒信息
    let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    let Message = NSEntityDescription.insertNewObjectForEntityForName("RemindMessage",inManagedObjectContext: context) as! RemindMessage
    Message.title = remind.title
    Message.content = remind.content
    Message.timeRemind = time
    Message.remindId = remind.remindId
    Message.uid = uid
    Message.state = state
    do {
        //                    remind.repeat_type = "e   / 未完，需要在界面选择
        try context.save()
//        return true
    } catch _ {
//        return false
    }
    
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




//重排数组  --自己实现但没有用

//        if remindTimeArray.count > 0 {
////            print(user.arrayForKey("remindTimeArray"))
//            print("4444")
//            var temp:[AnyObject] = []
//            print(remindTimeArray[0])
//            var n = remindTimeArray.count
//            for _ in 0...n {
//                if n == 0 {
//                    break
//                }
//                n = n - 1
//                temp.append(remindTimeArray[n])
//                print (temp)
//            }
//            remindTimeArray = temp
//        }





//        if user.arrayForKey("remindTimeArray")  == [] {
//            print("4444")
//
//        }

//        if user.arrayForKey("remindTimeArray") != nil {
//
//            var temp = remindTimeArray[0]
//            print("eee")
//            print(temp)
////
////            remindTimeArray = user.arrayForKey("remindTimeArray")! as NSMutableArray as [AnyObject] as [AnyObject]
////            var temp: [AnyObject] = []
////
////            temp = remindTimeArray[0]
////
////            var n = remindTimeArray.count
////            for _ in 0...n {
////                temp.append(remindTimeArray[n])
////                n = n - 1
////            }
////            remindTimeArray = temp
//        }

