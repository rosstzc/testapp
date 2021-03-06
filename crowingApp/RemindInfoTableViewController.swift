//
//  RemindInfoTableViewController.swift
//  crowingApp
//
//  Created by michaeltam on 15/12/12.
//  Copyright © 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData

class RemindInfoTableViewController: UITableViewController,UIActionSheetDelegate {

    @IBOutlet weak var followText: UIButton!
    @IBOutlet weak var switchOutlet: UISwitch!
    
    var reminds:[Remind] = []
    var remind:Remind! = nil
    var remindRelation:Int = 0
    var condition:String = ""

    let user = NSUserDefaults.standardUserDefaults()
    let currentUser = AVUser.currentUser()

    override func viewDidLoad() {
        super.viewDidLoad()


        
        //如果是自己创建或已关注，就不会显示关注按钮
        let uid = user.valueForKey("uid") as! String
        let rid = remind.remindId!
        
        //remindRelation = 0, 1, 2, 分布表示未关注、已关注、自己创建
        followText.setTitle("关注", forState: .Normal)

        
        //自己创建,
        //        condition = "createNot = '1'"
        condition = "uid = '\(uid)' && remindId = '\(rid)' && createNot = '1'"
        reminds = getOneRemind(condition)
        if reminds.count > 0 {
            print("我创建的")
            followText.setTitle("删除", forState: .Normal)
            self.remindRelation = 2
//            followText.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        }
        
        //已关注
        condition = "uid = '\(uid)' && remindId = '\(rid)' && createNot = '0'"
        reminds = getOneRemind(condition)
        if reminds.count > 0 {
            print("我关注的")
            //非用户自己创建的提醒，隐藏编辑按钮
            self.navigationItem.rightBarButtonItem = nil
            followText.setTitle("取消关注", forState: .Normal)
            self.remindRelation = 1
//            followText.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            
        }
  
    }
    
    
    
    //消息不打扰
    @IBAction func switchBtn(sender: AnyObject) {
        
        //不打扰
        if switchOutlet.on == true {
            print("不打扰")
        }
        
        
        
        //打不打扰
        if switchOutlet.on == false {
            print("打扰")
        }
        
    }
    
    
    
    //关注按钮
    @IBAction func followBtn(sender: AnyObject) {
        let uid = user.valueForKey("uid") as! String
        let rid = remind.remindId!
        
        //已关注，去取消关注
        if self.remindRelation == 1 {
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
                    deleteLCInstallation(rid)
                }
            })

        }
        
        
        //自己创建，要删除
        if self.remindRelation == 2 {
            
            //执行删除本地记录，不需要删除LC上的记录（在LC要做个标记）。但记得删除intallation的订阅； （用户下次看到该提醒将当非自己的提醒处理）
            let remindTemp = AVObject(withoutDataWithClassName: "Remind", objectId: rid)
            remindTemp.setObject("1", forKey: "deleteKey")
            remindTemp.saveInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
                if (error != nil) {
                    print("错误")
                }else {
                    deleteOneRemind(uid,rid: rid)
                    
                    //返回2层页面
                    print(self.navigationController?.viewControllers.count)
                    let level:Int = (self.navigationController?.viewControllers.count)!
                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[level - 3 ])!, animated: true) //

                }
            })

        }
        
        //去关注
        if self.remindRelation == 0 {
            let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
            
            //再次检查是否已关注，避免重复造成逻辑错误
            let request = NSFetchRequest(entityName: "Remind")
            request.predicate = NSPredicate(format: "uid = %@ && remindId = %@",(user.valueForKey("uid") as? String)!, (remind?.remindId)!)
            self.reminds = (try! context.executeFetchRequest(request)) as! [Remind]
            if reminds.count > 0 {
                //不做处理
            }
            else {
                let temp = NSEntityDescription.insertNewObjectForEntityForName("Remind",inManagedObjectContext: context) as! Remind
                // 在本地，把关注的信息保存下来
                temp.remindId = rid
                temp.uid = uid
                temp.title = remind?.title
                temp.content = remind?.content
                temp.remindTimeArray = remind?.remindTimeArray
                temp.schedule = remind?.schedule
                temp.updateTime = remind?.updateTime
                temp.createNot = "0"
                
                
                //先写入LC，然后再写入本地
                let remindLC = AVObject(withoutDataWithClassName: "Remind", objectId: rid )
                let followAtRemind = AVObject(className:"FollowAtRemind")
                followAtRemind.setObject(currentUser, forKey: "uid")
                followAtRemind.setObject(remindLC, forKey: "rid")
                    //写入LC的follow表
                followAtRemind.saveInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
                    if (error != nil) {
                        
                    }else {
                        
                        //写入LC的installation表
                        addLCInstallation(rid)
                        
                        // 写入本地
                        do {
                            try context.save()
                        } catch {
                            print(error)
                        }
                        
                        //关注时，即触发一条已读提醒信息
                        addRemindMessage(self.remind, uid: uid, time: NSDate(), state: 1)
                    }
          
                })

                
                //用actionSheet给出提示
                
           followText.setTitle("取消关注", forState: .Normal)
                
            }
            
        }
        
    }
    

    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row  == 0 {
            //分享到设计平台模块
        }
    }
    
    
    //当不是创建者时，隐藏“修改”那行
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.remindRelation != 2
&& indexPath.row == 1 && indexPath.section == 1){
        return 0  //高度为0
        } else {
        return 44
        }
    }

    
    //传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //        if segue.identifier == "segueEditRemind" {
        //            let nextVC = segue.destinationViewController as! AddRemindViewController
        //            nextVC.remind = self.remind
        //        }
        if segue.identifier == "seugeRemindTime" {
            let nextVC = segue.destinationViewController as! RemindTimeTableViewController
            nextVC.remind = self.remind
        }
        
        if segue.identifier == "segueEditRemind" {
            let nextVC = segue.destinationViewController as! AddRemindViewController
            nextVC.remind = self.remind
        }
        
    }
    

   

}
