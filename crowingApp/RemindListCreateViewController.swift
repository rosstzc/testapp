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
    var selectRemind:Remind? = nil
    
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
        var sortedResults = sorted(reminds, {
            $0.remind_time.compare($1.remind_time) == NSComparisonResult.OrderedDescending
        })
        reminds = sortedResults
        
        return reminds.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat =  "yyyy-MM-dd HH:mm:ss EEEE"
        var timeString:String = dateFormat.stringFromDate(reminds[indexPath.row].remind_time)
        cell.textLabel!.text = reminds[indexPath.row].title + " " + timeString
        println(reminds[indexPath.row].remind_time)
        
        cell.imageView?.image = UIImage(named:"0.jpeg")
        return cell
    }
    
    
    //传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueShowRemind" {
            var nextVC = segue.destinationViewController as! ShowRemindViewController
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
        var context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        var request =  NSFetchRequest(entityName: "Remind")
        self.reminds = context.executeFetchRequest(request, error: nil ) as! [Remind]
        return self.reminds
    }
    
    
    
}

