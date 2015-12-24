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


//按目前逻辑，只要从本地能查到的remind，都能保证最新； 只有在本地去不到然后才需要到LC上查，因此segue那个页面操作，比如动态页，不在这个页面获取数据
func getRemindFromLC(rid:String, uid: String ) -> Remind{
    var remind:Remind! = nil
    let reminds = getOneRemind("uid = '\(uid)' && remindId = '\(rid)'")
    if reminds.count > 0 {
        remind = reminds[0] as Remind
    } else {
        let remindLC = AVObject(withoutDataWithClassName: "Remind", objectId: rid )
        remind.content = remindLC.objectForKey("content") as? String
        remind.remindTimeArray = remindLC.objectForKey("remindTimeArray") as! NSArray
        remind.title = (remindLC.objectForKey("title") as! String)
        remind.updateTime = remindLC.objectForKey("updatedAt") as? NSDate
        
        //        remind.createNot = remindLC.objectForKey(String!)
        //        remind.schedule = remindLC.objectForKey(<#T##key: String!##String!#>)
        //        remind.uid = remindLC.objectForKey(<#T##key: String!##String!#>)
        //        remind.updateTime = remindLC.objectForKey(<#T##key: String!##String!#>)
        //        remind.sentTime = remindLC.objectForKey(<#T##key: String!##String!#>)
    }
    return remind
    
}


// 在主页每次更新关注提醒的信息
func updateFollowRemind(uid: String) {
    
    
    var reminds:[Remind]! = []
    reminds = getOneRemind("uid = '\(uid)' && create = '0'")
    var ridArray = [String]()
    for i in reminds {
        ridArray.append(i.remindId!)
    }
    //从LC找到最近有更新的关注提醒项目 （这里有个前提是每次在LC上的remind更新都会触发FollowAtRemind表的changeKey），更新本地内容
    let query = AVQuery(className: "FollowAtRemind")
    query.whereKey("changeKey", equalTo: true)
    query.whereKey("uid", equalTo: uid)
    query.includeKey("rid")
    let result = query.findObjects()
    
    if query.countObjects() > 0 {
        
        //把LC最新的remind（关注的提醒）信息 copy到本地
        for i in result {
            let remindLC = i.objectForKey("rid")
            
            let ridTemp = remindLC!.objectForKey("rid") as! String
            let title = remindLC!.objectForKey("title") as! String
            let content = remindLC!.objectForKey("content") as! String
            let remindTimeArray = remindLC!.objectForKey("remindTimeArray") as! NSArray
            let updateTime = remindLC!.objectForKey("updatedAt") as! NSDate

            let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
            let filter:NSPredicate = NSPredicate(format: "remindId = '\(ridTemp)' && uid = '\(uid)' && createNot = '0'")
            let request = NSFetchRequest(entityName: "Remind")
            request.predicate = filter
            let temp = (try! context.executeFetchRequest(request)) as! [Remind]
            if temp.count > 0  {
                let remind = temp[0]
                remind.title = title
                remind.content = content
                remind.remindTimeArray = remindTimeArray
                remind.updateTime = updateTime
                
                do {
                    try context.save()
                }catch {
                    print(error)
                }
                // 把处理了的项目的标记设置为false
                i.setObject("changeKey", forKey: false)
            }
        }
        AVObject.saveAllInBackground(result)  //批量保存LC
    }
    
    
    

}


func getOneRemind(condition:String) -> [Remind]{
    let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    let request = NSFetchRequest(entityName: "Remind")
    request.predicate = NSPredicate(format: condition as String)
    let reminds = (try! context.executeFetchRequest(request)) as! [Remind]
    return reminds
}


func addLCInstallation(remindId:String) {
    let currentInstallation = AVInstallation.currentInstallation()
    currentInstallation.addUniqueObject(remindId, forKey: "channels")
    currentInstallation.save()
}


func deleteLCInstallation(remindId:String) {
    let currentInstallation = AVInstallation.currentInstallation()
    currentInstallation.removeObject(remindId, forKey: "channels")
    currentInstallation.save()
}


func deleteRemind(condition:String) {
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    print(condition)
    let filter:NSPredicate = NSPredicate(format: condition)
    let request =  NSFetchRequest(entityName: "Remind")
    request.predicate = filter
    var temp:[Remind] = []
    temp = (try! context.executeFetchRequest(request)) as! [Remind]
    if temp.count > 0 {
        for i in temp {
            context.deleteObject(i)
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
}


func deleteRemindMessage(condition:String) {
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    print(condition)
    let filter:NSPredicate = NSPredicate(format: condition)
    let request =  NSFetchRequest(entityName: "RemindMessage")
    request.predicate = filter
    var temp:[RemindMessage] = []
    temp = (try! context.executeFetchRequest(request)) as! [RemindMessage]
    if temp.count > 0 {
        for i in temp {
            //            i.state = 2 //表示删除，但不真实删除，可能以后有用
            context.deleteObject(i)
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
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

