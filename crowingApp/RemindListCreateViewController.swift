//
//  ViewController.swift
//  crowingApp
//
//  Created by a a a a a on 15/8/28.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData

class RemindListCreateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
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

        
        self.navigationItem.title = "创建的提醒"
        
        //当从个人页的nav过来，就隐藏自己创建的nav bar
        if fromSegue == "toRmindCreate" {
        
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "toAddRemind")
            
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
            
            //删除coredata上的数据
            let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
            let id = reminds[indexPath.row].remindId
            let filter:NSPredicate = NSPredicate(format: "remindId = %@", id!) //不显示已删除的
            let request =  NSFetchRequest(entityName: "Remind")
            request.predicate = filter
            var temp:[Remind] = []
            temp = (try! context.executeFetchRequest(request)) as! [Remind]
//            context.delete(te)
            for i in temp {
                context.deleteObject(i)
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
    
    
    @IBAction func close(sender: AnyObject) {
//        self.dismissViewControllerAnimated(true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewControllerWithIdentifier("tab") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    
    //传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueShowRemind" {
            let nextVC = segue.destinationViewController as! ShowRemindViewController
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

