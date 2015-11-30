//
//  AddIntervalViewController.swift
//  crowingApp
//
//  Created by michaeltam on 15/11/4.
//  Copyright © 2015年 mike公司. All rights reserved.
//

import UIKit

class AddIntervalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var intervalArray = ["单日", "每周", "每月", "每年"]
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intervalArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = intervalArray[indexPath.row]
        cell.accessoryType  = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            self.performSegueWithIdentifier("segueAddOneDay", sender: self)
        }
        if indexPath.row == 1 {
            self.performSegueWithIdentifier("segueAddWeekDay", sender: self)
        }
        if indexPath.row == 2 {
            self.performSegueWithIdentifier("segueAddMonthDay", sender: self)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "segueAddOneDay"  {
            
            print("terett")
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
