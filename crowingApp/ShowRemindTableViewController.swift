//
//  ShowRemindTableViewController.swift
//  crowingApp
//
//  Created by michaeltam on 15/12/9.
//  Copyright © 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData

class ShowRemindTableViewController: UITableViewController {


    @IBOutlet weak var remindTitle: UILabel!
    @IBOutlet weak var remindContent: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkContent: UITextField!
    
    
    var remind:Remind! = nil
    var reminds:[Remind] = []
    let user = NSUserDefaults.standardUserDefaults()
    let currentUser = AVUser.currentUser()
    var remindRelation:Int = 0
    var checkIns:[AnyObject] = []
    var checkInCount:Int = 0
    var rid:String = ""
    var remindLC:AnyObject? = nil

    var remindTimeArray:NSArray = []
    var markForCurrentUserLikeCheck:[AnyObject] = []
    
    @IBOutlet weak var checkBarButtonItem: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //显示toolbar，用程序增加toolbar
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.remindContent.editable = false
        self.remindContent.dataDetectorTypes = UIDataDetectorTypes.All  //检查textView的链接等

        print(remind)
        
        print(remind.remindId)

        tableView.dataSource = self
        tableView.delegate  = self
        
        self.navigationItem.title = remind.title
        
        remindContent.scrollEnabled = false

        
//        imageView.image = UIImage(named: "fangbingbing")
        
        
        
        //按目前逻辑，只要从本地能查到的remind，都能保证最新； 只有在本地去不到然后才需要到LC上查，因此segue那个页面操作，比如动态页，不在这个页面获取数据
        //请看function.swift
        
        rid = remind.remindId! as String
        print(rid)
        
        //从LC获取图片
        if user.valueForKey("imageTemp") != nil {
            let image = UIImage(data: user.valueForKey("imageTemp") as! NSData)
            imageView.image  = image
            user.setObject(nil, forKey: "imageTemp")
            user.synchronize()
        } else {
            let image = getImageFromLC("Remind", objectId: rid)
            imageView.image  = image
        }
        
     
        // Do any additional setup after loading the view.
        if remind != nil {
            remindTitle.text = remind?.title
            remindContent.text = remind?.content
        }
        
        
        //获取checkIn的数据
        let remindLC = AVObject(withoutDataWithClassName: "Remind", objectId: rid)
        let query = AVQuery(className: "CheckIn")
        query.whereKey("rid", equalTo: remindLC)
        query.includeKey("uid")
        query.includeKey("image")
        query.orderByDescending("createdAt")
        query.limit = 100
        let result = query.findObjects()
        self.checkInCount = result.count
        self.checkIns = result!

//        query.findObjectsInBackgroundWithBlock({(objects:[AnyObject]? , error:NSError?)  in
//            if (error != nil) {
//                print("错误")
//            } else {
//                self.checkInCount = objects!.count
//                self.checkIns = objects!
//                print(objects?.count)
//            }
//        })
        
        // 找到这个remind下我喜欢过的checkin (like记录)
        let query2 = AVQuery(className: "Like")
        query2.whereKey("uid", equalTo: self.currentUser)
        query2.whereKey("cid", matchesQuery: query)
        let likes = query2.findObjects()  //增加一个查询多1s
        
        //给已喜欢的做标记, 1表已喜欢
        var x = 0
        markForCurrentUserLikeCheck = []
        
        for i in checkIns {
            print(i.valueForKey("createdAt"))
            markForCurrentUserLikeCheck.append(0)
            print(markForCurrentUserLikeCheck   )
            markForCurrentUserLikeCheck[x] = 0
            for j in likes {
                if (i.objectId as String) == (j.valueForKey("cid")!.objectId) {
                    print("1")
                    markForCurrentUserLikeCheck[x] = 1
                }
            }
            x = x + 1
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        print("view refresh")
        self.viewDidLoad() //先更新数据
        self.tableView.reloadData() //然后更新table

    }
    
    
    
    @IBAction func checkAction(sender: AnyObject) {
        print("我要check一下")
    }
    
    @IBAction func goInfo(sender: AnyObject) {
        self.performSegueWithIdentifier("segueRemindInfo", sender: self)
    
    }
    
    //为修改提醒而设计回退，只有从这个页面过去addRemind才会调用unwind
    @IBAction func close(sugue:UIStoryboardSegue) {
        print("unwind close")

        //        self.view.setNeedsDisplay()
    }
    
    //传递数据
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "segueEditRemind" {
//            let nextVC = segue.destinationViewController as! AddRemindViewController
//            nextVC.remind = self.remind
//        }
        if segue.identifier == "segueRemindInfo" {
            let nextVC = segue.destinationViewController as! RemindInfoTableViewController
            nextVC.remind = self.remind
        }
        
        if segue.identifier == "segueToCheckIn" {
            let nextVC = segue.destinationViewController as! CheckInViewController
            nextVC.remindId = remind.remindId!
            nextVC.remindTitle = remind.title!
        }
        
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
    

    
    @IBAction func commentCheckIn(sender: AnyObject) {
    }
    
    
    
    
    //输入键盘屏蔽
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        checkContent.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        checkContent.resignFirstResponder()
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
    



}
