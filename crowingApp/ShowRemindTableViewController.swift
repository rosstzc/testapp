//
//  ShowRemindTableViewController.swift
//  crowingApp
//
//  Created by michaeltam on 15/12/9.
//  Copyright © 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData

class ShowRemindTableViewController: UITableViewController {

    @IBOutlet weak var remindTitle: UILabel!
    @IBOutlet weak var remindContent: UILabel!
    @IBOutlet weak var tappedFollow: UIButton!
    
    @IBOutlet weak var checkContent: UITextField!
    var remind:Remind! = nil
    var reminds:[Remind] = []
    let user = NSUserDefaults.standardUserDefaults()
    var remindRelation:Int = 0
    
    var remindTimeArray:NSArray = []
    
    @IBOutlet weak var itemEdit: UIBarButtonItem!
    
    @IBOutlet weak var checkBarButtonItem: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //显示toolbar，用程序增加toolbar
        self.navigationController?.setToolbarHidden(false, animated: true)

        tableView.dataSource = self
        tableView.delegate  = self
        
        

        
        
        
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
    
    @IBAction func checkAction(sender: AnyObject) {
        
        print("我要check一下")
    }
    @IBAction func edit(sender: AnyObject) {
        self.performSegueWithIdentifier("segueEditRemind", sender: self)
    
    }
    
    //为修改提醒而设计回退，只有从这个页面过去addRemind才会调用unwind
    @IBAction func close(sugue:UIStoryboardSegue) {
        print("unwind close")
        
        //        remind = nil
        //        self.view.setNeedsDisplay()
    }
    
    //传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueEditRemind" {
            let nextVC = segue.destinationViewController as! AddRemindViewController
            nextVC.remind = self.remind
        }
        
    }
    
    
    override func viewWillAppear(animated: Bool) {

        print("view refresh")
        self.viewDidLoad()
        self.tableView.reloadData()
        
        
    }
    
    
    //关注某个提醒，createNot状态是0
    @IBAction func follow(sender: AnyObject) {
        
        if self.remindRelation == 1 {
            
        }
        if self.remindRelation == 2 {
            
        }
        
        
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
                
                temp.remindId = remind?.remindId
                temp.uid = user.valueForKey("uid") as? String
                temp.title = remind?.title
                temp.content = remind?.content
                temp.remindTimeArray = remind?.remindTimeArray
                temp.schedule = remind?.schedule
                temp.createNot = "0"
                
                do {
                    try context.save()
                } catch {
                    print(error)
                }
                
                tappedFollow.setTitle("已关注", forState: .Normal)
                
            }
            
        }
        
        
        
        
        
    }
    
    @IBAction func submit(sender: AnyObject) {
        //点按钮，触发写入 followAtRemind 表
        let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let check = NSEntityDescription.insertNewObjectForEntityForName("CheckAtFollowing",inManagedObjectContext: context) as! CheckAtFollowing
        
        
        check.remindTitle = remindTitle.text!
        check.content = checkContent.text!
        check.userId = "2"
        check.userName = "mike"
        do {
            //        check.userImage =
            //        check.dbID =
            try context.save()
        } catch {
        }
        
        
    }
    
    
    func getOneRemind(condition:String) -> [Remind]{
        let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let request = NSFetchRequest(entityName: "Remind")
        request.predicate = NSPredicate(format: condition as String)
        self.reminds = (try! context.executeFetchRequest(request)) as! [Remind]
        return self.reminds
    }
    
    
    //输入键盘屏蔽
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        checkContent.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        checkContent.resignFirstResponder()
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return remindTimeArray.count
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "")
        var test:Dictionary = ["remindTime":"", "repeatInterval":""]
        test = remindTimeArray.reverse()[indexPath.row] as! [String : String]
        
        cell.textLabel?.text = test["remindTime"]
        cell.detailTextLabel?.text  = test["repeatInterval"]
        return cell
    }
    
    //滚动tableView时让uiview滚动
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        //        var previousOffset:CGFloat = CGFloat()
//        //        var rect:CGRect = self.view.frame
//        //        rect.origin.y += previousOffset - scrollView.contentOffset.y
//        //        previousOffset = scrollView.contentOffset.y
//        //        self.view.frame = rect
//        //
//        var rect:CGRect = self.view.frame
//        
//        rect.origin.y =  -scrollView.contentOffset.y
//        
//        self.view.frame = rect
//    }
//    
    
    
    //for test
    //    func getRemindFollow() ->[FollowAtRemind] {
    //        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    //        let request =  NSFetchRequest(entityName: "FollowAtRemind")
    //        self.remindFollows = (try! context.executeFetchRequest(request)) as! [FollowAtRemind]
    //        
    //        for i in remindFollows {
    //            print(i.title)
    //        }
    //        
    //        return remindFollows
    //    }
    

}
