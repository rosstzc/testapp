//
//  RemindListFollowViewController.swift
//  crowingApp
//
//  Created by a a a a a on 15/8/31.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData

class RemindListFollowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    var reminds:[Remind] = []
    var selectRemind:Remind! = nil
    let user = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.title = "关注的提醒"
        self.hidesBottomBarWhenPushed = true   //隐藏低栏

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
        print("follow count: ", reminds.count)
        return reminds.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat =  "yyyy-MM-dd HH:mm:ss EEEE"
        let timeString:String = dateFormat.stringFromDate(reminds[indexPath.row].updateTime!)
        cell.textLabel!.text = reminds[indexPath.row].title! + " " + timeString
        print(reminds[indexPath.row].updateTime)
        print(reminds[indexPath.row].uid)
        
        cell.imageView?.image = UIImage(named:"0.jpeg")
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            //            messages.removeAtIndex(indexPath.row)
            
            let rid = reminds[indexPath.row].remindId
            let uid = self.user.valueForKey("uid") as? String
            
            //给一个actionsheet来提醒
            let actionSheet = UIAlertController(title: nil, message: "取消关注后将收不到其提醒信息", preferredStyle: UIAlertControllerStyle.ActionSheet)
            let action1:UIAlertAction = UIAlertAction(title: "删除该提醒", style: UIAlertActionStyle.Destructive, handler: {(action) -> Void in
                //先删除LC上关注记录，再删除本地记录
                let query = AVQuery(className: "FollowAtRemind")
                query.whereKey("uid", equalTo: uid)
                query.whereKey("rid", equalTo: rid)
                var result = query.findObjects()
                let followOid = result[0].objectId
                let follow = AVObject(withoutDataWithClassName: "FollowAtRemind", objectId: followOid)
                follow.deleteInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
                    if (error != nil) {
                        print("错误")
                    }else {
                        //删除本地记录（关注记录、message记录）
                        let condition = "uid = '\(uid)' && remindId = '\(rid)'"
                        deleteRemindMessage(condition)
                        deleteRemind(condition)
                        
                        //删除LC上的installtion
                        deleteLCInstallation(rid!)
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
    
    
    
    //传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueShowRemind" {
            let nextVC = segue.destinationViewController as! ShowRemindTableViewController
            
            nextVC.remind = self.selectRemind
        }
    
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //把从关注提醒表读取的值传递到 创建提醒表
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
        let filter:NSPredicate = NSPredicate(format: "uid= %@ && createNot = '0'", uid) //不显示已删除的
        request.predicate = filter
        self.reminds = (try! context.executeFetchRequest(request)) as! [Remind]
        return self.reminds
    }
    
    
    

    


    
    

}
