//
//  AddRemindViewController.swift
//  crowingApp
//
//  Created by a a a a a on 15/8/29.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData

class AddRemindViewController: UIViewController,UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
//    @IBOutlet weak var remindTime: UILabel!
//    @IBOutlet weak var repeatInterval: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    var reminds:[Remind] = []
    var MainVC = RemindListViewController()
    var remindTimeArray: [AnyObject] = []
    
    let user = NSUserDefaults.standardUserDefaults()
    

    @IBOutlet weak var textTitle: UITextField!
    @IBOutlet weak var textContent: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textContent.delegate = self
        self.textTitle.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        //通知初始化设置
        setupNotificationSettings()
        
        //获取用户uid
        print("read userDefault",user.valueForKey("name"))
        print("uuid",user.valueForKey("uid"))
        
        textTitle.text = user.valueForKey("remindTitleTemp") as? String
        textContent.text = user.valueForKey("remindContentTemp") as? String
        
        
        remindTimeArray = user.arrayForKey("remindTimeArray")!
//        for i in remindTimeArray {
//            print(i)
//        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remindTimeArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell =  tableView.dequeueReusableCellWithIdentifier("remindTimeCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "remindTimeCell")
        }
        let remindTime = cell!.viewWithTag(11) as! UILabel
        let repeatInterval = cell!.viewWithTag(15) as! UILabel
        var test:Dictionary = ["remindTime":"", "repeatInterval":""]
        test = remindTimeArray[indexPath.row] as! [String : String]
        
        remindTime.text = test["remindTime"]
        repeatInterval.text = test["repeatInterval"]
        return cell!
    }


    @IBAction func addRemindTime(sender: AnyObject) {
        
        user.setObject(textTitle.text, forKey: "remindTitleTemp")
        user.setObject(textContent.text, forKey: "remindContentTemp")
    }

    @IBAction func tappedSave(sender: AnyObject) {

        let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let remind = NSEntityDescription.insertNewObjectForEntityForName("Remind",inManagedObjectContext: context) as! Remind
        remind.title = textTitle.text!
        remind.content = textContent.text!
        remind.remindTimeArray = remindTimeArray
        remind.updateTime = NSDate()
        remind.remindId = NSUUID().UUIDString
        remind.createNot = "1"
        remind.uid = user.valueForKey("uid") as? String

        do {
            //        user.online = false
            try context.save()
            
//            self.dismissViewControllerAnimated(true, completion: nil)
            //先删除所有通知
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            //触发通知
            for i in  (user.valueForKey("remindTimeArray") as! NSArray) {
                print(i)
                print(i["remindTime"])
                
                let remindTimeString = i["remindTime"] as! String
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let remindTime = dateFormatter.dateFromString(remindTimeString)
//                var repeatIntervel = i["repeatIntervel"]
                
                let repeatType: NSCalendarUnit = NSCalendarUnit.Minute   //未完根据界面选项生成
                scheduleLocalNotificationWith(remindTime!, repeated: repeatType )
            }
            //保存后，要把userDefault的remindTimeArray清空
            let null: [AnyObject] = []
            user.setObject(null, forKey: "remindTimeArray")
            user.setObject("", forKey: "remindTitleTemp")
            user.setObject("", forKey: "remindContentTemp")
            user.synchronize()
            
        } catch {
            print(error)
        }

        self.dismissViewControllerAnimated(true,completion: nil)
//        self.performSegueWithIdentifier("segueToRemindListCreateVC", sender: self)
        print("11")
//        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//        let vc = storyboard.instantiateViewControllerWithIdentifier("navToRemindCreate") as UIViewController
//        self.presentViewController(vc, animated: true, completion: nil)

    }
    
    
    
    
    
    @IBAction func tappedCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
//        self.navigationController?.popToViewController(RemindListViewController() as UIViewController, animated: true)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//        let vc = storyboard.instantiateViewControllerWithIdentifier("tab") as UIViewController;
//        self.presentViewController(vc, animated: true, completion: nil)
    
    }

    
//    func saveCoreData(title: String, content: String, time:NSDate ) {
//        var  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
//        var remind = NSEntityDescription.insertNewObjectForEntityForName("Remind",inManagedObjectContext: context) as! Remind
//        remind.title = title
//        remind.content = content
//        
//        context.save(nil)
//        
//    }

    
    
    //输入键盘屏蔽
    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
        textTitle.resignFirstResponder()
        textContent.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        textTitle.resignFirstResponder()
        textContent.resignFirstResponder()
    }
    
    //可定义出发时间和循环周期的提醒函数
    func scheduleLocalNotificationWith(time: NSDate, repeated: NSCalendarUnit){
        let localNotification = UILocalNotification()
        localNotification.fireDate = time
        localNotification.timeZone = NSCalendar.currentCalendar().timeZone
        localNotification.alertBody = "you must go shopping, remember!"
        localNotification.alertAction = "View list"
        localNotification.repeatInterval = repeated
        print("repeat", repeated)
        
        localNotification.applicationIconBadgeNumber++
        
        localNotification.category = "shoppingListReminderCategory"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    //配置通知
    func scheduleLocalNotification(){
        let localNotification = UILocalNotification()
//        localNotification.fireDate = datePicker.date
//        print(datePicker.date)
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 8)
        print("test", NSDate(timeIntervalSinceNow: 8))
        localNotification.timeZone = NSCalendar.currentCalendar().timeZone
        localNotification.alertBody = "you must go shopping, remember!"
        localNotification.alertAction = "View list"
        
        localNotification.repeatInterval = NSCalendarUnit.Minute
        
        localNotification.applicationIconBadgeNumber++
        
        localNotification.category = "shoppingListReminderCategory"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    //通知的基本设置
    func setupNotificationSettings() {
        
        let notificationSettings: UIUserNotificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()!
        
        if(notificationSettings.types == UIUserNotificationType.None) {
            
            //定义通知类型
            let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Sound]
            
            //定义通知响应
            let justInformAction = UIMutableUserNotificationAction()
            justInformAction.identifier = "justInform"
            justInformAction.title = "ok, 知道了"
            justInformAction.destructive = false
            justInformAction.activationMode = UIUserNotificationActivationMode.Background
            justInformAction.authenticationRequired = false
            
            
            let modifyListAction = UIMutableUserNotificationAction()
            modifyListAction.identifier = "editList"
            modifyListAction.title = "修改东西"
            modifyListAction.activationMode = UIUserNotificationActivationMode.Foreground
            modifyListAction.destructive = false
            modifyListAction.authenticationRequired = false
            
            let deleteListAction = UIMutableUserNotificationAction()
            deleteListAction.identifier = "delete"
            deleteListAction.title = "删除"
            deleteListAction.activationMode = UIUserNotificationActivationMode.Background
            deleteListAction.destructive   = false
            deleteListAction.authenticationRequired = true
            
            
            let actionArray = NSArray(objects: justInformAction, modifyListAction, deleteListAction)
            let actionArrayMinimal = NSArray(objects: deleteListAction, modifyListAction)
            
            //定义分类与action的关系
            let shoppingListRemindCategory = UIMutableUserNotificationCategory()
            shoppingListRemindCategory.identifier = "shoppingListReminderCategory"
            shoppingListRemindCategory.setActions(actionArray  as? [UIUserNotificationAction], forContext:UIUserNotificationActionContext.Default )
            shoppingListRemindCategory.setActions(actionArrayMinimal as? [UIUserNotificationAction] , forContext: UIUserNotificationActionContext.Minimal)
            
            let categoriesForSettings = NSSet(object: shoppingListRemindCategory)
            
            //注册通知设定
            let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings as? Set<UIUserNotificationCategory>)
            UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
            
        }
    }
    
    

    
}
