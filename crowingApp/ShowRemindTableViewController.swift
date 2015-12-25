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
    @IBOutlet weak var remindContent: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var checkContent: UITextField!
    var remind:Remind! = nil
    var reminds:[Remind] = []
    let user = NSUserDefaults.standardUserDefaults()
    let currentUser = AVUser.currentUser()
    var remindRelation:Int = 0
    
    var remindTimeArray:NSArray = []
    
    @IBOutlet weak var checkBarButtonItem: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //显示toolbar，用程序增加toolbar
//        self.navigationController?.setToolbarHidden(false, animated: true)

        tableView.dataSource = self
        tableView.delegate  = self
        
        self.navigationItem.title = remind.title
        
        //按目前逻辑，只要从本地能查到的remind，都能保证最新； 只有在本地去不到然后才需要到LC上查，因此segue那个页面操作，比如动态页，不在这个页面获取数据
        //请看function.swift
        
        let rid = remind.remindId! as String
        //从LC获取图片
        let query = AVQuery(className: "Remind")
        query.cachePolicy = AVCachePolicy.CacheElseNetwork
        query.maxCacheAge = 1
        let remindLC = query.getObjectWithId(rid)
        if let imageFile = (remindLC.objectForKey("image") as? AVFile ){
            let imageData:NSData? = imageFile.getData()
            image.image = UIImage.init(data:imageData!)
        }


        
        // Do any additional setup after loading the view.
        if remind != nil {
            remindTitle.text = remind?.title
            remindContent.text = remind?.content
        }
        
        //获取所有提醒时间
        remindTimeArray = remind.remindTimeArray as! NSArray
        
        
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
        
        //        remind = nil
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
        
    }
    
    
    override func viewWillAppear(animated: Bool) {

        print("view refresh")
        self.viewDidLoad()
        self.tableView.reloadData()
        
        
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
        
        return remindTimeArray.count
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "")
        var test:Dictionary = ["remindTime":"", "repeatInterval":""]
        test = remindTimeArray.reverse()[indexPath.row] as! [String : String]
        
        cell.textLabel?.text = test["remindTime"]
        cell.detailTextLabel?.text  = test["repeatInterval"]
        return cell
    }
    

    

}
