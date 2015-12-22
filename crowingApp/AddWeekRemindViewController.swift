//
//  AddWeekRemindViewController.swift
//  crowingApp
//
//  Created by michaeltam on 15/11/10.
//  Copyright © 2015年 mike公司. All rights reserved.
//

import UIKit

class AddWeekRemindViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var remindTime:NSMutableDictionary = ["remindTime":"", "repeatInterval":""]
    let user = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var list = ["每周一","每周二","每周三","每周四","每周五","每周六","每周日"]
    var listNo = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        datePicker.datePickerMode = UIDatePickerMode.Time
        self.navigationItem.title = "每周提醒"
        let rightButton = UIBarButtonItem(title: "保存", style: .Plain, target: self, action: "save")
        navigationItem.rightBarButtonItem = rightButton

    }

    @IBAction func selectDay(sender: AnyObject) {
    }
    
    
    @IBAction func selectTime(sender: AnyObject) {
    }
    
    
    func save() {
        let time = datePicker.date
//        let timeString = Functions.stringFromDate(time)
        let timeString = stringFromDateWithFormat(time, format: "HH:mm")
        var repeatInterval:String  = "none"

        for i in listNo {
            switch  i {
            case "1":
                repeatInterval = "每周一"
            case "2":
                repeatInterval = "每周二"
            case "3":
                repeatInterval = "每周三"
            case "4":
                repeatInterval = "每周四"
            case "5":
                repeatInterval = "每周五"
            case "6":
                repeatInterval = "每周六"
            case "7":
                repeatInterval = "每周日"
            default: break
            }
            if i != "" {
                remindTime.setValue(timeString, forKey: "remindTime")
                remindTime.setValue(repeatInterval, forKey: "repeatInterval")
                var remindTimeArray = user.arrayForKey("remindTimeArray")!
                remindTimeArray.append(remindTime)
                user.setObject(remindTimeArray, forKey: "remindTimeArray")
            }
            

            
            }
        self.performSegueWithIdentifier("FromIntervalToAddRemind", sender: self)
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = list[indexPath.row]
        cell.accessoryType  = UITableViewCellAccessoryType.None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let number = indexPath.row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if(cell?.accessoryType == UITableViewCellAccessoryType.Checkmark) {
            cell!.accessoryType  = UITableViewCellAccessoryType.None
        
            for i in listNo {
                if i.isEqual(String(number)) {
                    listNo.removeAtIndex(number)
                }
            }
            
        }
        else {
            cell!.accessoryType  = UITableViewCellAccessoryType.Checkmark
            switch number {
            case 0 :
                listNo.append("1")
            case 1 :
                listNo.append("2")
            case 2 :
                listNo.append("3")
            case 3 :
                listNo.append("4")
            case 4 :
                listNo.append("5")
            case 5 :
                listNo.append("6")
            case 6 :
                listNo.append("7")
            default: break
                
            }
        }
    
    }
    

    
    
    
    
    func add() {
        
        
    }
    func del() {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
