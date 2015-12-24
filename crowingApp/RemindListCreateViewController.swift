//
//  ViewController.swift
//  crowingApp
//
//  Created by a a a a a on 15/8/28.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData

class RemindListCreateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var reminds:[Remind] = []
    var selectRemind:Remind! = nil
    let user = NSUserDefaults.standardUserDefaults()
    
    var fromSegue:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.hidesBottomBarWhenPushed = true   //隐藏低栏

        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self

        
        self.navigationItem.title = "我创建的提醒"
        
        if fromSegue == "RemindListVC" {  
            self.performSegueWithIdentifier("segueToCreateRemind", sender: self)
        }
        

    }
    
    func toAddRemind() {
        print("test")
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewControllerWithIdentifier("navToAddRemind") as UIViewController;
        self.presentViewController(vc, animated: true, completion: nil)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reminds = getDataFromCoreData()
        
        
        //提醒时间倒序
        let sortedResults = reminds.sort({
            $0.updateTime!.compare($1.updateTime!) == NSComparisonResult.OrderedDescending
        })
        reminds = sortedResults
        return reminds.count
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellRemind")!
        let dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat =  "yyyy-MM-dd"
        let timeString:String = dateFormat.stringFromDate(reminds[indexPath.row].updateTime!)
        let title = cell.viewWithTag(11) as! UILabel
//        let repeatIcon = cell.viewWithTag(12) as! UILabel
        let dateCreate = cell.viewWithTag(13) as! UILabel

        title.text = reminds[indexPath.row].title!
//        repeatIcon.text = reminds[indexPath.row]
        dateCreate.text = timeString

        
        
        
//        cell.viewWithTag(11) as UILabel = reminds[indexPath.row].title!
//        cell.detailTextLabel?.text = "11"
//        print(reminds[indexPath.row].updateTime)
//        print(reminds[indexPath.row].uid)
        
//        cell.imageView?.image = UIImage(named:"0.jpeg")
        return cell
    }
    
    
    
    //滑动删除某行数据
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            //            messages.removeAtIndex(indexPath.row)
            
            let rid = reminds[indexPath.row].remindId
            let uid = self.user.valueForKey("uid") as? String
            
            //给一个actionsheet来提醒
            let actionSheet = UIAlertController(title: nil, message: "删除后将收不到其提醒信息", preferredStyle: UIAlertControllerStyle.ActionSheet)
            let action1:UIAlertAction = UIAlertAction(title: "删除该提醒", style: UIAlertActionStyle.Destructive, handler: {(action) -> Void in
                //执行删除本地记录，不需要删除LC上的记录（在LC要做个标记）。但记得删除intallation的订阅； （用户下次看到该提醒将当非自己的提醒处理）
                let remindTemp = AVObject(withoutDataWithClassName: "Remind", objectId: rid)
                remindTemp.setObject("1", forKey: "deleteKey")
                remindTemp.saveInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
                    if (error != nil) {
                        print("错误")
                    }else {
                        let condition = "uid = '\(uid)' && remindId = '\(rid)'"
                        deleteRemind(condition)
                        deleteLCInstallation(rid!)
                        deleteRemindMessage(condition)
                    }
                })
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            })
            let action2:UIAlertAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil )
            actionSheet.addAction(action1)
            actionSheet.addAction(action2)
            presentViewController(actionSheet, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func close(sender: AnyObject) {
//        self.dismissViewControllerAnimated(true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewControllerWithIdentifier("tab") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    
    //传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueShowRemind" {
            let nextVC = segue.destinationViewController as! ShowRemindTableViewController
            nextVC.remind = self.selectRemind
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectRemind = reminds[indexPath.row]
        self.performSegueWithIdentifier("segueShowRemind", sender: self)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    func getDataFromCoreData() -> [Remind] {
        
        let uid:String = user.valueForKey("uid") as! String

        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let request =  NSFetchRequest(entityName: "Remind")
        let filter:NSPredicate = NSPredicate(format: "uid= %@ && createNot = '1'", uid) // 显示自己创建的
        request.predicate = filter
        self.reminds = (try! context.executeFetchRequest(request)) as! [Remind]
        return self.reminds
    }
    
    
    
}

