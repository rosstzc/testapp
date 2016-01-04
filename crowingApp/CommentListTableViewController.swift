//
//  CommentListTableViewController.swift
//  crowingApp
//
//  Created by michaeltam on 16/1/2.
//  Copyright © 2016年 mike公司. All rights reserved.
//

import UIKit

class CommentListTableViewController: UITableViewController {

    let user = NSUserDefaults.standardUserDefaults()
    let currentUser = AVUser.currentUser()
    var comments:[AnyObject] = []
    var commentCount = 0
    var selectComment:AVObject = AVObject()
    var checkIn:AVObject = AVObject()
    var segue:String = ""
    let typeArray = ["likeCheckIn","comment"]  //查询评论和check的赞

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        if segue == "segueToCommentList" {
            //所有评论我的评论（含赞）
            let query = AVQuery(className: "Comment")
            query.whereKey("rUid", equalTo: currentUser)
            query.whereKey("uid", notEqualTo: currentUser)
            query.whereKey("type", containedIn: typeArray)
            query.includeKey("uid")
            query.includeKey("cid")
            query.orderByDescending("createdAt")
            query.limit = 100
            self.comments = query.findObjects()
            self.commentCount = comments.count
            
//            //找到与我发出的checkIn
//            let queryCheckIn = AVQuery(className: "checkIn")
//            queryCheckIn.whereKey("uid", equalTo: currentUser)
//            queryCheckIn.includeKey("image")
//            
//            let queryLike = AVQuery(className: "Like")
//            queryLike.whereKey("readed", notEqualTo: true)
//            queryLike.whereKey("cid", matchesQuery: queryCheckIn)
//            query.orderByDescending("createdAt")
//
//            let likes = queryLike.findObjects()
            
            //找到checkIns相关的like中，那些readed不为true
        }
        
        
        if segue == "segueToCommentUnread" {
            //我未读评论（不含未读点赞）
            let query = AVQuery(className: "Comment")
            query.whereKey("rUid", equalTo: currentUser)
            query.whereKey("uid", notEqualTo: currentUser)
            query.whereKey("type", containedIn: typeArray)
            query.includeKey("uid")
            query.includeKey("cid")
            query.orderByDescending("createdAt")
            query.limit = 100
            
            query.whereKey("readed", notEqualTo: true)
            self.comments = query.findObjects()
            self.commentCount = comments.count
            
            //触发read逻辑，当我点入某个checkIn，其下面评论我的comment都被标记为true，同理 like

        }


        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectComment = comments[indexPath.row]
        checkIn = selectComment.valueForKey("cid") as! AVObject
        
        //清理未读标记
        let query = AVQuery(className: "Comment")
        query.whereKey("rUid", equalTo: currentUser)
        query.whereKey("cid", equalTo: checkIn)
        query.whereKey("type", containedIn: typeArray)
        let result = query.findObjects()
        
        
        self.performSegueWithIdentifier("segueToComment", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToComment" {
            let nextVC = segue.destinationViewController as! CommentTableViewController
            nextVC.selectCommentFromCommentList = self.selectComment
            nextVC.checkIn = self.checkIn
        }
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentCount
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentListCell")!
        let comment = comments[indexPath.row]
        
        //        let avatar = cell.viewWithTag(10) as! UIImageView
        let username = cell.viewWithTag(11) as! UILabel
        let content = cell.viewWithTag(12) as! UILabel
//        let checkInImage = cell.viewWithTag(13) as! UIImageView
        let checkInTitle = cell.viewWithTag(14) as! UILabel
        let time = cell.viewWithTag(15) as! UILabel


        username.text = comment.valueForKey("uid")!.valueForKey("username") as? String
        content.text = comment.valueForKey("content") as? String // 赞是没有内容的
//        checkInImage.image =
        checkInTitle.text = comment.valueForKey("cid")!.valueForKey("title") as? String
        time.text = timeStringForMessage(comment.valueForKey("createdAt") as! NSDate)
        
        
        return cell
    }

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
