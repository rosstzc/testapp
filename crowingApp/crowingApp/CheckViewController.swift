//
//  trendsViewController.swift
//  crowingApp
//
//  Created by a a a a a on 15/8/28.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData


class CheckViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
        
    @IBOutlet weak var tableView: UITableView!
    
    var checks:[CheckAtFollowing] = []
    var selectCheck:CheckAtFollowing? = nil

    
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
            
            var context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
            var request =  NSFetchRequest(entityName: "CheckAtFollowing")
            self.checks = context.executeFetchRequest(request, error: nil ) as! [CheckAtFollowing]
        
            return checks.count
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("todoCell") as! UITableViewCell
            var userImage = cell.viewWithTag(10) as! UIImageView
            var userName = cell.viewWithTag(11) as! UILabel
            var checkContent = cell.viewWithTag(13) as! UILabel
            var remindTitle = cell.viewWithTag(14) as! UILabel
            
            var check = checks[indexPath.row] as CheckAtFollowing
            userName.text = check.userName
            checkContent.text = check.content
            remindTitle.text = check.remindTitle
            
            return cell
            
        }
        
        
        
        
        
        
        
        func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
            
        }
        
}

