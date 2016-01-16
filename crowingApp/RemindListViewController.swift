//  ViewController.swift
//  crowingApp
//
//  Created by a a a a a on 15/8/28.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData
import SwiftDate


class RemindListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!

    

    var messages:[RemindMessage] = []
    var reminds:[Remind]! = []
    var selectMessage:RemindMessage! = nil
    var remindId:String! = nil
    let user = NSUserDefaults.standardUserDefaults()
    var uid:String = ""
    var rid:String = ""
    
    var currentUser = AVUser.currentUser()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //在登录页，登录数据是后台获取，但上面定义是先后台执行，所以会没有数据
        if currentUser == nil  {
            print("未登录")
            currentUser = AVUser.currentUser()
        }
 
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        print("home page")
        uid = user.valueForKey("uid") as! String


        
        
    }


    
    override func viewWillAppear(animated: Bool) {
        //检查是否有信息的通知信息，如果有就刷新
        updateRemindMessage2(uid)
        updateFollowRemind(uid) //刷新已关注的提醒信息
        if !self.isViewLoaded() {
            return
        }
        
        self.tableView.reloadData()
    }
    

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRow")
        self.messages = getRemindMessageData2("state != 2 && uid = '\(uid)'")  // state=0表示未读， 1表示已读， 2表示已删除
    
        let sortedResults = messages.sort({
            $0.timeRemind!.compare($1.timeRemind!) == NSComparisonResult.OrderedDescending
        })
        messages = sortedResults
        self.tabBarItem.badgeValue = "9"
        print("message count", messages.count )
        return messages.count
     
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell")!
        let dateFormat: NSDateFormatter = NSDateFormatter()
        let message = messages[indexPath.row]
        dateFormat.dateFormat =  "yyyy-MM-dd HH:mm:ss EEEE"
//        let timeString:String = dateFormat.stringFromDate(message.timeRemind!)
        let timeString:String = timeStringForMessage(message.timeRemind!)

        let state = UILabel()
        let titleLabel = cell.viewWithTag(11) as! UILabel
        let time = cell.viewWithTag(12) as! UILabel
        let imageReadNotIcon = cell.viewWithTag(13) as! UIImageView  //是否已读图标
        let content = cell.viewWithTag(14) as! UILabel
        let imagePushNotIcon = cell.viewWithTag(15) as! UIImageView  //是否推送图标
//        let repeatLabel = cell.viewWithTag(13) as! UILabel

   
        //read or not
        print(message.state)
        titleLabel.text = message.title!
        state.text = String(message.state)
        time.text = timeString
        imageReadNotIcon.image = UIImage(named: "twitter")
        content.text  = ""
        imagePushNotIcon.image = UIImage(named: "twitter")

        if message.state == 0 {
            imageReadNotIcon.image = UIImage(named: "geisha")

        }
        else {
            
        }
        
        return cell
    }
    
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectMessage = messages[indexPath.row]
        let objectId = selectMessage!.objectID
        print(selectMessage.remindId)
        print((selectMessage.remindId)! as String)
        // 从coredata中找到id的行,标记为已读
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let message  = (try!context.existingObjectWithID(objectId)) as! RemindMessage
        message.state = 1
        do {
            try context.save()
        } catch _ {
        }
        
        
        
//        let request =  NSFetchRequest(entityName: "RemindMessage")
//        var temp:[RemindMessage] = []
//        temp = (try! context.executeFetchRequest(request)) as! [RemindMessage]
//        for i in temp {
//            if i.objectID == id {
//                i.state = 1
//                print(i.title)
//            }
//        }
//        do {
//            try context.save()
//        } catch _ {
//        }
        
        //就是把对应的remindId传到下一个view
        remindId = (selectMessage!.remindId)! as String
        print(remindId)
//        self.performSegueWithIdentifier("segueShowRemind", sender: self)
//        self.performSegueWithIdentifier("segueShowRemind2", sender: self)
               self.performSegueWithIdentifier("segueTest", sender: self)
    }
    

    
    
    //滑动删除某行数据
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
//            messages.removeAtIndex(indexPath.row)
            
            //删除coredata上的数据
            let id = messages[indexPath.row].remindId! as String
            print(id)
            deleteRemindMessage("remindId = '\(id)'")
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            //顺便删除最近一个提醒信息前的所有state=2的信息，待补充
            //
            //
            //
        }
    }
    

    //传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "segueTest" {
            //            let nextVC = segue.destinationViewController as! ShowRemindViewController
            let nextVC = segue.destinationViewController as! TestTableViewController    
            
            //test
            //            reminds = getOneRemind("uid='\(uid)'")
            //            for i in reminds {
            //                print(i.remindId)
            //            }
            
            //根据remindId获取该remind的数据
            print(remindId)
            reminds = getOneRemind("remindId = '\(remindId)'")
            for i in reminds {
                nextVC.remind = i
                print(i.remindId)
                //                break
            }
        }
        if segue.identifier == "segueShowRemind2" {
//            let nextVC = segue.destinationViewController as! ShowRemindViewController
            let nextVC = segue.destinationViewController as! ShowRemindTableViewController

            //test
//            reminds = getOneRemind("uid='\(uid)'")
//            for i in reminds {
//                print(i.remindId)
//            }
            
            //根据remindId获取该remind的数据
            print(remindId)
            reminds = getOneRemind("remindId = '\(remindId)'")
            for i in reminds {
                nextVC.remind = i
                print(i.remindId)
//                break
            }
        }
        
        if segue.identifier == "RemindListToCreateList" {
            let nextVC = segue.destinationViewController as! RemindListCreateViewController
            nextVC.fromSegue = "RemindListVC"
        } 
    }
    
    
    func updateRemindMessage2(uid:String) {
        
        reminds = getRemindData(uid) //创建+关注的提醒
        var lastMessageTime: NSDate = NSDate()
        let now:NSDate = NSDate()
        if reminds.count > 0 {
            // 从remind中最后发出提醒信息的时间
            let sortedResults = reminds.sort({
                $0.sentTime!.compare($1.sentTime!) == NSComparisonResult.OrderedDescending
            })
            reminds = sortedResults
            print(reminds[0])
            print(reminds[0].title)
            print(reminds[0].sentTime)
            lastMessageTime =  reminds[0].sentTime!
        }
        
        for i in reminds {
            //跳过那些没有提醒时间的提醒
            if i.remindTimeArray == []  {
                print("没有填写 remindTime")
                continue
            }
            
            //把单次、转换后的循环时间,统一为日期+时间格式后放入到临时数组
            var tempTimeArray = [""]
            tempTimeArray.removeAll()
            for j in (i.remindTimeArray as! NSArray)   {
                let interval = j.valueForKey("repeatInterval") as! NSString
                let time = j.valueForKey("remindTime") as! String
                
                //处理单次提醒，塞入临时数组
                if (interval.isEqual("none") ) {
                    tempTimeArray.append(time)
                    print(tempTimeArray)
                }
                
                //处理周循环提醒
                if (interval.rangeOfString("周").location != NSNotFound) {
                    //判断今天是星期几，如果interval大于今天就丢弃，如果少于今天就计算其具体的date
                    let nowWeekDay:Int = NSDate().weekday
                    var intervalWeekDay:Int = 1
                    switch interval {
                    case "每周日" :
                        intervalWeekDay = 1
                    case "每周一" :
                        intervalWeekDay = 2
                    case "每周二" :
                        intervalWeekDay = 3
                    case "每周三" :
                        intervalWeekDay = 4
                    case "每周四" :
                        intervalWeekDay = 5
                    case "每周五" :
                        intervalWeekDay = 6
                    case "每周六" :
                        intervalWeekDay = 7
                    default:
                        break
                    }
                    let timeDate:NSDate
                    if intervalWeekDay > nowWeekDay {
                        //大于当前日
                        timeDate = now - (intervalWeekDay - nowWeekDay + 7).day
                    } else {
                        timeDate = now - (nowWeekDay - intervalWeekDay).day
                    }
                    var timeString = stringFromDateWithFormat(timeDate, format: "yyyy-MM-dd")
                    timeString = timeString + " " + time
                    tempTimeArray.append(timeString)
                }
                
            }
            
            //给临时数组的时间排序，找到时间最大但少于当前时间的那个时间
            print(i.remindId)
            var time = Functions.dateFromString(tempTimeArray[0])
            for x in tempTimeArray {
                let tempTime = Functions.dateFromString(x)
                if tempTime >= now {
                    continue
                } else {
                    if time.compare(tempTime) ==  NSComparisonResult.OrderedAscending  {
                        time = tempTime
                    }
                }
                
            }
            
            //把提醒时间最近的拿来比较 (大于上次提醒信息的发出时间，而少于当前时间)
            if (time.compare(lastMessageTime) == NSComparisonResult.OrderedDescending) && (now.compare(time) == NSComparisonResult.OrderedDescending)   {
                
                
                //删除该remindId之前的提醒信息 （日后要保留另外创建 remindMessageList表）
                deleteRemindMessage("remindId = '\(i.remindId! as String)'")
                
                // 写入提醒信息
                addRemindMessage(i, uid: uid, time: time, state: 0)
                
                //还要修改一下remind表中的sentTime
                let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
                let request =  NSFetchRequest(entityName: "Remind")
                request.predicate = NSPredicate(format: "remindId='\(i.remindId! as String)'")
                reminds = (try! context.executeFetchRequest(request)) as! [Remind]
                print(reminds.count)
                reminds[0].sentTime = time
                do {
                    try context.save()
                } catch _ {
                }
            }
        }
    }
    
    
    
    


    //传递数据
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "segueAddRemind" {
//            var nextVC = segue.destinationViewController as! AddRemindViewController
//            nextVC.MainVC = self
//        }
//        if segue.identifier == "segueShowRemind" {
//            var nextVC = segue.destinationViewController as! ShowRemindViewController
//            nextVC.remind = self.selectRemind
//            }
//            
//        }
    


    
    func getRemindMessageData2(condition:NSString) ->[RemindMessage] {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let filter:NSPredicate = NSPredicate(format: condition as String) //不显示已删除的
        let request =  NSFetchRequest(entityName: "RemindMessage")
        request.predicate = filter
        self.messages = (try! context.executeFetchRequest(request)) as! [RemindMessage]
        return messages
    }
    
    
    
    func getRemindMessageData() ->[RemindMessage] {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let filter:NSPredicate = NSPredicate(format: "state != 2") //不显示已删除的
        let request =  NSFetchRequest(entityName: "RemindMessage")
        request.predicate = filter
        self.messages = (try! context.executeFetchRequest(request)) as! [RemindMessage]
        
        return messages
    }
    
    func getRemindData(uid:String) ->[Remind] {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let request =  NSFetchRequest(entityName: "Remind")
        request.predicate = NSPredicate(format: "uid='\(uid)'")
        
        reminds = (try! context.executeFetchRequest(request)) as! [Remind]
        return reminds
    }
    
    class func abc() -> String {
        print("123")
        return "123"
    }
}

