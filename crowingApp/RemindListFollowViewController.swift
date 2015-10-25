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
    
    
    //传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueShowRemind" {
            let nextVC = segue.destinationViewController as! ShowRemindViewController
            
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
