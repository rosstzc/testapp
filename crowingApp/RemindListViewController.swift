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
    var reminds:[Remind] = []
    var selectMessage:RemindMessage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self

        println("home page")
        
    }


    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("numberOfRow")
        self.messages = getRemindMessageData()
    
        var sortedResults = sorted(messages, {
            $0.time_remind.compare($1.time_remind) == NSComparisonResult.OrderedDescending
        })
        messages = sortedResults
        self.tabBarItem.badgeValue = "9"
        return messages.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let dateFormat: NSDateFormatter = NSDateFormatter()
        var message = messages[indexPath.row]
        dateFormat.dateFormat =  "yyyy-MM-dd HH:mm:ss EEEE"
        var timeString:String = dateFormat.stringFromDate(message.time_remind)
//        println(messages[indexPath.row].time_remind)
//        println(timeString)
        //read or not
        println(message.state)
        cell.textLabel!.text = message.title + " " + timeString

        if message.state == 0 {
            cell.textLabel!.text = message.title + "(N)" + timeString
        }
        cell.imageView?.image = UIImage(named:"0.jpeg")
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectMessage = messages[indexPath.row]
        selectMessage?.state = 1
        
        
        
//        self.performSegueWithIdentifier("segueShowRemind", sender: self)
        
    }
    
    
    
    func updateRemindMessage() {
//        var followReminds:[FollowAtRemind] = []
        
        reminds = getRemindData()
        messages = getRemindMessageData()
      
        if messages.count > 0 {
            // 倒序后取message最后获取信息时间，然后用这个时间去remind表比较
            var lastMessageTime: NSDate
            var now:NSDate = NSDate()
            var sortedResults = sorted(messages, {
                $0.time_remind.compare($1.time_remind) == NSComparisonResult.OrderedDescending
            })
            messages = sortedResults
            lastMessageTime =  messages[0].time_remind
            println(lastMessageTime)
            //循环所有关注的提醒，如果大于最后信息，并且少于当前时间，那么就到信息表写信息。。（信息未读逻辑，未完）
            for i in reminds {
                if (i.remind_time.compare(lastMessageTime) == NSComparisonResult.OrderedDescending) && (now.compare(i.remind_time) == NSComparisonResult.OrderedDescending)   {
                    // 写入信息表
                    var  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
                    var Message = NSEntityDescription.insertNewObjectForEntityForName("RemindMessage",inManagedObjectContext: context) as! RemindMessage
                    Message.title = i.title
                    Message.content = i.content
                    Message.time_remind = i.remind_time
                    Message.state = 0
                    
//                    remind.repeat_type = "everMinute"  // 未完，需要在界面选择
                    context.save(nil)
                    
                }
                
                
            }
        } else {
            
            for i in reminds {
                // 写入信息表
                var  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
                var Message = NSEntityDescription.insertNewObjectForEntityForName("RemindMessage",inManagedObjectContext: context) as! RemindMessage
                Message.title = i.title
                Message.content = i.content
                Message.time_remind = i.remind_time
                
                //                    remind.repeat_type = "everMinute"  // 未完，需要在界面选择
                context.save(nil)
                
                
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
        tableView.reloadData()
    }
    
    
    
    
    func getRemindMessageData() ->[RemindMessage] {
        var context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        var filter:NSPredicate = NSPredicate(format: "state != 2") //不显示删除的
        var request =  NSFetchRequest(entityName: "RemindMessage")
        request.predicate = filter
        self.messages = context.executeFetchRequest(request, error: nil ) as! [RemindMessage]
        return messages
    }
    
    func getRemindData() ->[Remind] {
        var context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        var request =  NSFetchRequest(entityName: "Remind")
        
        reminds = context.executeFetchRequest(request, error: nil ) as! [Remind]
        return reminds
    }
}

