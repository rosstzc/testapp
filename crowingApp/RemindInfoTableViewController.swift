//
//  RemindInfoTableViewController.swift
//  crowingApp
//
//  Created by michaeltam on 15/12/12.
//  Copyright © 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData

class RemindInfoTableViewController: UITableViewController {

    @IBOutlet weak var followText: UIButton!
    
    var reminds:[Remind] = []
    var remind:Remind! = nil
    let user = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        //如果是自己创建或已关注，就不会显示关注按钮
        let uid = user.valueForKey("uid") as! String
        let rid = remind.remindId!
        
        //自己创建
        var condition:String
        //        condition = "createNot = '1'"
        condition = "uid = '\(uid)' && remindId = '\(rid)' && createNot = '1'"
        reminds = getOneRemind(condition)
        
        
        
        if reminds.count > 0 {
            print("我创建的")
            tappedFollow.setTitle("我创建的", forState: .Normal)
            self.remindRelation = 1
            tappedFollow.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        }
        
        condition = "uid = '\(uid)' && remindId = '\(rid)' && createNot = '0'"
        reminds = getOneRemind(condition)
        if reminds.count > 0 {
            print("我关注的")
            //非用户自己创建的提醒，隐藏编辑按钮
            self.navigationItem.rightBarButtonItem = nil
            tappedFollow.setTitle("已关注", forState: .Normal)
            self.remindRelation = 1
            tappedFollow.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            
        }
        
        
        // Do any additional setup after loading the view.
        if remind != nil {
            remindTitle.text = remind?.title
            remindContent.text = remind?.content
        }
        
        //获取所有提醒时间
        remindTimeArray = remind.remindTimeArray as! NSArray
        
        
        
    }


   
    
    @IBAction func followBtn(sender: AnyObject) {
        
        
    }
    
    
    func getOneRemind(condition:String) -> [Remind]{
        let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let request = NSFetchRequest(entityName: "Remind")
        request.predicate = NSPredicate(format: condition as String)
        self.reminds = (try! context.executeFetchRequest(request)) as! [Remind]
        return self.reminds
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
        
    }
    

   

}
