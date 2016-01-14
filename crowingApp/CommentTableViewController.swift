//
//  CommentTableViewController.swift
//  crowingApp
//
//  Created by michaeltam on 16/1/2.
//  Copyright © 2016年 mike公司. All rights reserved.
//

import UIKit

class CommentTableViewController: UITableViewController,UITextViewDelegate, UINavigationControllerDelegate {

    
    var user = NSUserDefaults.standardUserDefaults()
    let currentUser = AVUser.currentUser()
    var checkIn:AVObject = AVObject()
    var checkInId = ""
    var comments:[AnyObject] = []
    var comment:AVObject = AVObject()
    var commentCount = 0
    var rUid:AVObject? = AVObject()
    
    var selectCommentFromCommentList:AVObject = AVObject()   //来自于评论我的或未读的list
    @IBOutlet weak var commentContent: UITextField! //这里日后用textView
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //查询所有评论（包括“赞”）
        let query = AVQuery(className: "Comment")
        query.whereKey("cid", equalTo: checkIn)
        print(checkIn.objectId)
        query.orderByDescending("createdAt")
        query.includeKey("uid")
        query.includeKey("rUid")
        query.limit = 100
        self.comments = query.findObjects()
        commentCount = comments.count
        commentContent.placeholder = "评论"
        self.rUid = self.currentUser
    }

    
    
    @IBAction func sendComment(sender: AnyObject) {
        let content = commentContent.text
        comment = AVObject(className: "Comment")
        comment.setObject(content, forKey: "content")
        comment.setObject(checkIn, forKey: "cid")
        comment.setObject(currentUser, forKey: "uid")
        comment.setObject("comment", forKey: "type")
        comment.setObject(self.rUid, forKey: "rUid") //当uid等于rUid表示评论checkin，不同时表示评论某人的评论
        comment.save()
        
        //增加checkIn表中comment的累计数
        checkIn.incrementKey("commentCount")
        checkIn.save()
        
        
        commentContent.text = ""
        self.viewDidLoad()
        self.tableView.reloadData()

        //按道理这里应该异步插入一行数据
        
        
        
        //未完，从评论/未读列表的segue过来，要定位到具体行位置 （下面实现）
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        comment = self.comments[indexPath.row] as! AVObject
        self.rUid = comment.valueForKey("uid") as? AVObject
        
        //如果当前用户与rUid是相同，那么显示删除
        if  self.rUid == currentUser {
            //显示删除actionsheet
        }else {
            let userName = comment.valueForKey("uid")?.valueForKey("username") as! String
            commentContent.placeholder = "回复\(userName):"
            self.rUid = (comment.valueForKey("uid") as! AVObject)
        }
    }
    
    //滚动时，让键盘隐藏
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        commentContent.resignFirstResponder()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        commentContent.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("1")
        return self.commentCount
    }

    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell")!
        //        let avatar = cell.viewWithTag(10) as! UIImageView
        let username = cell.viewWithTag(11) as! UILabel
        let time = cell.viewWithTag(12) as! UILabel
        let content = cell.viewWithTag(13) as! UILabel
        let comment = self.comments[indexPath.row]
        
        //        avatar.image = UIImage(named: <#T##String#>)
        username.text = comment.valueForKey("uid")!.valueForKey("username") as? String
        time.text = timeStringForMessage(comment.valueForKey("createdAt") as! NSDate)
        content.text = (comment.valueForKey("content") as! String)
        
        //当评论别人评论时,评论内容如下( 如果评论人与被评论人是相同，逻辑认为是评论checkIn，因为操作上不允许评论自己的评论)
        let uidString = comment.valueForKey("uid")?.valueForKey("objectId") as! String
        let rUidString = comment.valueForKey("rUid")?.valueForKey("objectId") as! String
        print(uidString)

        if (uidString != rUidString)  {
            print(uidString)
            let usernameR = comment.valueForKey("rUid")!.valueForKey("username") as! String
            content.text = "回复\(usernameR): \(content.text!)"
        }

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
