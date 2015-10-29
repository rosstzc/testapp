//
//  ViewController.swift
//  crowingApp
//
//  Created by a a a a a on 15/8/28.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData


class RemindListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var tableView: UITableView!
    var messages:[RemindMessage] = []
    var reminds:[Remind]! = []
    var selectMessage:RemindMessage? = nil
    var selectMessageRemindId:String? = nil
    let user = NSUserDefaults.standardUserDefaults()
    var uid:String = ""
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        print("home page")
        uid = user.valueForKey("uid") as! String

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
        let cell = UITableViewCell()
        let dateFormat: NSDateFormatter = NSDateFormatter()
        let message = messages[indexPath.row]
        dateFormat.dateFormat =  "yyyy-MM-dd HH:mm:ss EEEE"
        let timeString:String = dateFormat.stringFromDate(message.timeRemind!)
//        println(messages[indexPath.row].time_remind)
//        println(timeString)
        //read or not
        print(message.state)
        cell.textLabel!.text = message.title! + " " + timeString

        if message.state == 0 {
            cell.textLabel!.text = message.title! + "(N)" + timeString
        }
        cell.imageView?.image = UIImage(named:"0.jpeg")
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath)
        print(indexPath.row)
        
        selectMessage = messages[indexPath.row]
        print(selectMessage!.title)
        let id = selectMessage!.objectID
        
        // 从coredata中找到id的行，然后修改保存
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let request =  NSFetchRequest(entityName: "RemindMessage")
        var temp:[RemindMessage] = []
        temp = (try! context.executeFetchRequest(request)) as! [RemindMessage]
        for i in temp {
            if i.objectID == id {
                i.state = 1
                print(i.title)
            }
        }
        do {
            try context.save()
        } catch _ {
        }
        
        //刷新cell内容
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        print(selectMessage?.title)
        cell.textLabel!.text = selectMessage!.title
        
        self.selectMessageRemindId = selectMessage?.remindId
        self.performSegueWithIdentifier("segueShowRemind", sender: self)
    }
    
    
    //滑动删除某行数据
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
//            messages.removeAtIndex(indexPath.row)
            
            //删除coredata上的数据
            let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
            let id = messages[indexPath.row].remindId
            let filter:NSPredicate = NSPredicate(format: "remindId = %@", id!) //不显示已删除的
            let request =  NSFetchRequest(entityName: "RemindMessage")
            request.predicate = filter
            var temp:[RemindMessage] = []
            temp = (try! context.executeFetchRequest(request)) as! [RemindMessage]
            for i in temp {
                i.state = 2
//                context.deleteObject(i)
            }
            do {
                try context.save()
            } catch _ {
            }
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            //顺便删除最近一个提醒信息前的所有state=2的信息，待补充
            //
            //
            //
        }
    }
    
    
    
    @IBAction func close(sugue:UIStoryboardSegue) {
        print("close")
    }
    
    //传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueShowRemind" {
            let nextVC = segue.destinationViewController as! ShowRemindViewController
            
            //根据remindId获取该remind的数据
            reminds = getRemindData()
            for i in reminds {
                let remindId = i.remindId
                let id: String = selectMessageRemindId!
                if (remindId == id) {
                    nextVC.remind = i
                    break
                }
            }
            
            
        }
        
    }
    
    //把未更新的提醒信息列表更新
    func updateRemindMessage() {
//        var followReminds:[FollowAtRemind] = []
        
        reminds = getRemindData()
        messages = getRemindMessageData2("state >= 0 && uid='\(uid)'") //表示取与自己香港的所有提醒信息
      
        if messages.count > 0 {
            // 倒序后取message最后获取信息时间，然后用这个时间去remind表比较
            var lastMessageTime: NSDate
            let now:NSDate = NSDate()
            let sortedResults = messages.sort({
                $0.timeRemind!.compare($1.timeRemind!) == NSComparisonResult.OrderedDescending
            })
            messages = sortedResults
            lastMessageTime =  messages[0].timeRemind!
            print(lastMessageTime)
            
            
            //循环所有创建+关注的提醒，如果大于最后信息，并且少于当前时间，那么就到信息表写信息。。
            for i in reminds {
                if i.remindTimeArray == []  {
                    print("没有填写 remindTime")
                    continue
                }

                //先从remindTimeArray中找到最近的提醒时间，然后再纳入下面比较
                
                //变量time是要得出这个任务中最大的时间。 当然这个涉及重复提醒，未完
                let timeString = (i.remindTimeArray as! NSArray)[0].valueForKey("remindTime") as! String
                var time = Functions.dateFromString(timeString)
                
                for j in (i.remindTimeArray as! NSArray)   {
                    let tempTimeString = j.valueForKey("remindTime") as! String
                    let tempTime = Functions.dateFromString(tempTimeString)
                    if tempTime.compare(time) ==  NSComparisonResult.OrderedAscending  {
                        time = tempTime
                    }
                }
                
                //把提醒时间最近的拿来比较
                if (time.compare(lastMessageTime) == NSComparisonResult.OrderedDescending) && (now.compare(time) == NSComparisonResult.OrderedDescending)   {
                    // 写入信息表
                    let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
                    let Message = NSEntityDescription.insertNewObjectForEntityForName("RemindMessage",inManagedObjectContext: context) as! RemindMessage
                    Message.title = i.title
                    Message.content = i.content
                    Message.timeRemind = time
                    Message.remindId = i.remindId
                    print(i.remindId)

                    Message.uid = uid
                    Message.state = 0
                    do {
                        //                    remind.repeat_type = "e   / 未完，需要在界面选择
                        try context.save()
                    } catch _ {
                    }
                    
                }
                
                
            }
        } else {
            
            for i in reminds {
                
                if i.remindTimeArray == []  {
                    print("没有填写 remindTime")
                    continue
                }
                
                //变量time是要得出这个任务中最大的时间(把时间字符转为NSDate)。 当然这个涉及重复提醒，未完
                let timeString = (i.remindTimeArray as! NSArray)[0].valueForKey("remindTime") as! String
                var time = Functions.dateFromString(timeString)
                
                
                for j in (i.remindTimeArray as! NSArray)   {
                    
                    let tempTimeString = j.valueForKey("remindTime") as! String
                    let tempTime = Functions.dateFromString(tempTimeString)
                    
                    if tempTime.compare(time) ==  NSComparisonResult.OrderedAscending  {
                        time = tempTime
                    }
                }
                
                
                // 写入信息表
                let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
                let Message = NSEntityDescription.insertNewObjectForEntityForName("RemindMessage",inManagedObjectContext: context) as! RemindMessage
                Message.title = i.title
                Message.content = i.content
                Message.timeRemind = time
                Message.remindId = i.remindId
                Message.uid = uid
                Message.state = 0
                do {
                    //                    remind.repeat_type = "everMinute"  // 未完，需要在界面选择
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
    


    
    override func viewWillAppear(animated: Bool) {
        //检查是否有信息的通知信息，如果有就刷新
        updateRemindMessage()
        if !self.isViewLoaded() {
            return
        }
        tableView.reloadData()
    }
    
    
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
    
    func getRemindData() ->[Remind] {
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

