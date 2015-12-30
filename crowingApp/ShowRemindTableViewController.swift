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

    var remindTimeArray:NSArray = []
    
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
        query.limit = 100
        let result = query.findObjects()
        self.checkInCount = result!.count
        self.checkIns = result!

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
    
    
    override func viewWillAppear(animated: Bool) {
        
        print("view refresh")
        self.tableView.reloadData()
        self.viewDidLoad()

        
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
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "checkInCell")
        let checkIn = self.checkIns[indexPath.row]
        let content = checkIn.valueForKey("content") as! String
        let image = checkIn.valueForKey("image")
        let user = checkIn.valueForKey("uid")
        print (user?.valueForKey("username"))
//        let time = checkIn.valueForKey("createAt") as! NSDate
        

        
        cell.textLabel?.text = content
        return cell
    }
    

    

}
