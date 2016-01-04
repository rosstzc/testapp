//
//  CheckFlowTableViewController.swift
//  crowingApp
//
//  Created by michaeltam on 16/1/1.
//  Copyright © 2016年 mike公司. All rights reserved.
//

import UIKit
import CoreData

class CheckFlowTableViewController: UITableViewController {

    @IBOutlet weak var flowSegment: UISegmentedControl!
    
    @IBOutlet weak var highView: UIView!
    
    let user = NSUserDefaults.standardUserDefaults()
    let currentUser = AVUser.currentUser()

    var reminds:[Remind] = []
    var checkIns:[AnyObject] = []
    var checkInCount:Int = 0
    var markForCurrentUserLikeCheck:[AnyObject] = []
    var uid:String = ""
    var selectCheckIn:AVObject = AVObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()


        //默认取相关的checkIns
        getRelatedCheckIns()
        

    }
    
    
    
    //最新的checkIn
    func getLatestCheckIns(){
        let queryCheckIn = AVQuery(className: "CheckIn")
        queryCheckIn.orderByDescending("createdAt")
        queryCheckIn.includeKey("uid")
        queryCheckIn.includeKey("image")
        queryCheckIn.limit = 100
        self.checkIns = queryCheckIn.findObjects()
        self.checkInCount = checkIns.count
        markForCurrentUserLikeCheck = getMarkForCurrentUserLikeCheck(queryCheckIn, checkIns: checkIns, user: currentUser)
        
    }
    
    //与我相关remind的checkIn
    func getRelatedCheckIns() {
        //从本地获得相关的提醒id
        let uid:String = user.valueForKey("uid") as! String
        let condition = "uid = '\(uid)'"
        reminds = getOneRemind(condition)
        var ridArray:[String] = []
        for i in reminds {
            let rid = i.valueForKey("remindId") as! String
            ridArray.append(rid)
        }
        //到LC查询相关的提醒对象
        let queryRemind = AVQuery(className: "Remind")
        queryRemind.whereKey("objectId", containedIn: ridArray)
        //        let temp = queryRemind.findObjects()
        
        //从LC获取与我相关提醒的checkIn
        let queryCheckIn = AVQuery(className: "CheckIn")
        queryCheckIn.whereKey("rid", matchesQuery: queryRemind)
        queryCheckIn.orderByDescending("createdAt")
        queryCheckIn.includeKey("uid")
        queryCheckIn.includeKey("image")
        queryCheckIn.limit = 100
        self.checkIns = queryCheckIn.findObjects()
        self.checkInCount = checkIns.count
        
        
        markForCurrentUserLikeCheck = getMarkForCurrentUserLikeCheck(queryCheckIn, checkIns: checkIns, user: currentUser)
    }

    
    // 我发的checkIn
    func getMyCheckIn() {
        let queryCheckIn = AVQuery(className: "CheckIn")
        queryCheckIn.whereKey("uid", equalTo: currentUser)
        queryCheckIn.orderByDescending("createdAt")
        queryCheckIn.includeKey("uid")
        queryCheckIn.includeKey("image")
        queryCheckIn.limit = 100
        self.checkIns = queryCheckIn.findObjects()
        self.checkInCount = checkIns.count
    }
    
    
    
    //点赞：点击cell上的button
    @IBAction func likeCheckIn(sender: AnyObject) {
        //获取表格的行数
        var cellRow = getCellRow(sender,tableView: tableView)
        let row = cellRow[0] as! Int
        let selectCell = cellRow[1] as! UITableViewCell
        let likeButton = selectCell.viewWithTag(15) as! UIButton
        //点赞逻辑和UI刷新
        changeLikeButton(self.checkIns[row], currentUser: currentUser, button: likeButton)
        
        //更新那个标记自己赞过/未赞的数组
        if markForCurrentUserLikeCheck[row] as! Int == 0 {
            markForCurrentUserLikeCheck[row] = 1
        }else {
            markForCurrentUserLikeCheck[row] = 0
        }
        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        if !self.isViewLoaded() {
            return
        }
//        tableView.reloadData()
    }
    
    
    
    
    @IBAction func changeSegment(sender: AnyObject) {

        if flowSegment.selectedSegmentIndex == 0 {
            getRelatedCheckIns()
            tableView.reloadData()
        }
        if flowSegment.selectedSegmentIndex == 1 {
            getLatestCheckIns()
            tableView.reloadData()
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToComment" {
            let nextVC = segue.destinationViewController as! CommentTableViewController
            var cellRow = getCellRow(sender!, tableView: self.tableView)
            let row = cellRow[0] as! Int
            nextVC.checkIn = self.checkIns[row] as! AVObject
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.checkInCount
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("checkInCell")!
        
     
        let checkIn = checkIns[indexPath.row]
        
        //        let avatar = cell.viewWithTag(10) as! UIImageView
        let username = cell.viewWithTag(11) as! UILabel
        let time = cell.viewWithTag(12) as! UILabel
        //        let image = cell.viewWithTag(13) as! UIImageView
        
        let content = cell.viewWithTag(18) as! UILabel
        
        var likeButton  = cell.viewWithTag(15) as! UIButton
        //        let comment = cell.viewWithTag(16) as! UIButton
        //        let report = cell.viewWithTag(17) as! UIButton
        
        //        avatar.image = UIImage(named: <#T##String#>)
        username.text = checkIn.valueForKey("uid")!.valueForKey("username") as? String
        time.text = timeStringForMessage(checkIn.valueForKey("createdAt") as! NSDate)
        //        image.image =
        content.text = checkIn.valueForKey("content") as? String
        
        likeButton = showLikeButton(checkIn, button: likeButton, indexPath: indexPath, mark: markForCurrentUserLikeCheck)
        
        return cell
    }

    
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
