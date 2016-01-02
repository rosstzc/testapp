//
//  CommentTableViewController.swift
//  crowingApp
//
//  Created by michaeltam on 16/1/2.
//  Copyright © 2016年 mike公司. All rights reserved.
//

import UIKit

class CommentTableViewController: UITableViewController {

    
    var user = NSUserDefaults.standardUserDefaults()
    let currentUser = AVUser.currentUser()
    var checkIn:AVObject = AVObject()
    var checkInId = ""
    var comments:[AnyObject] = []
    var comment:AVObject = AVObject()
    var commentCount = 0
    
    
    @IBOutlet weak var commentContent: UITextField! //这里日后用textView
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = AVQuery(className: "Comment")
        query.whereKey("cid", equalTo: checkIn)
        query.orderByDescending("createdAt")
        query.includeKey("uid")
        query.includeKey("rUid")
        query.limit = 100
        self.comments = query.findObjects()
        commentCount = comments.count
        commentContent.placeholder = "评论"
    }

    
    @IBAction func sendComment(sender: AnyObject) {
        let content = commentContent.text
        comment = AVObject(className: "Comment")
        comment.setObject(content, forKey: "content")
        comment.setObject(currentUser, forKey: "uid")
        comment.setObject(currentUser, forKey: "rUid")

        comment.setObject(checkIn, forKey: "cid")
        comment.save()
        
        commentContent.text = ""
        self.viewDidLoad()
        self.tableView.reloadData()

        //按道理这里应该异步插入一行数据
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        comment = self.comments[indexPath.row] as! AVObject
        let userName = comment.valueForKey("uid")?.valueForKey("username") as! String
        commentContent.placeholder = "回复\(userName):"
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
        content.text = comment.valueForKey("content") as? String
        
        
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
