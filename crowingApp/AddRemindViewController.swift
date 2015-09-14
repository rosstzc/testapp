//
//  AddRemindViewController.swift
//  crowingApp
//
//  Created by a a a a a on 15/8/29.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData

class AddRemindViewController: UIViewController,UITextFieldDelegate {
    
    var reminds:[Remind] = []
    var MainVC = RemindListViewController()

    @IBOutlet weak var textTitle: UITextField!
    @IBOutlet weak var textContent: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textContent.delegate = self
        self.textTitle.delegate = self
        // Do any additional setup after loading the view.
        
        //通知初始化设置
        setupNotificationSettings()
    }



    @IBAction func tappedSave(sender: AnyObject) {
        
        var  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        var remind = NSEntityDescription.insertNewObjectForEntityForName("Remind",inManagedObjectContext: context) as! Remind
        remind.title = textTitle.text
        remind.content = textContent.text
        remind.remind_time = datePicker.date
        
        remind.repeat_type = "everMinute"  // 未完，需要在界面选择
        context.save(nil)
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //先删除所有通知
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        //触发通知
        var repeatType: NSCalendarUnit = NSCalendarUnit.CalendarUnitMinute   //未完，根据界面选项生成
        scheduleLocalNotificationWith(datePicker.date, repeat: repeatType )
//        scheduleLocalNotification()

    }
    
    
    
    
    
    @IBAction func tappedCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        textTitle.resignFirstResponder()
        textContent.resignFirstResponder()
    }
    
    
    func scheduleLocalNotificationWith(time: NSDate, repeat: NSCalendarUnit){
        var localNotification = UILocalNotification()
        localNotification.fireDate = time
        localNotification.timeZone = NSCalendar.currentCalendar().timeZone
        localNotification.alertBody = "you must go shopping, remember!"
        localNotification.alertAction = "View list"
        localNotification.repeatInterval = repeat
        println("repeat",repeat)
        
        localNotification.applicationIconBadgeNumber++
        
        localNotification.category = "shoppingListReminderCategory"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    //配置通知
    func scheduleLocalNotification(){
        var localNotification = UILocalNotification()
//        localNotification.fireDate = datePicker.date
        println(datePicker.date)
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 8)
        println("test", NSDate(timeIntervalSinceNow: 8))
        localNotification.timeZone = NSCalendar.currentCalendar().timeZone
        localNotification.alertBody = "you must go shopping, remember!"
        localNotification.alertAction = "View list"
        
        localNotification.repeatInterval = NSCalendarUnit.CalendarUnitMinute
        
        localNotification.applicationIconBadgeNumber++
        
        localNotification.category = "shoppingListReminderCategory"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    //通知的基本设置
    func setupNotificationSettings() {
        
        let notificationSettings: UIUserNotificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if(notificationSettings.types == UIUserNotificationType.None) {
            
            //定义通知类型
            var notificationTypes: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Sound
            
            //定义通知响应
            var justInformAction = UIMutableUserNotificationAction()
            justInformAction.identifier = "justInform"
            justInformAction.title = "ok, 知道了"
            justInformAction.destructive = false
            justInformAction.activationMode = UIUserNotificationActivationMode.Background
            justInformAction.authenticationRequired = false
            
            
            var modifyListAction = UIMutableUserNotificationAction()
            modifyListAction.identifier = "editList"
            modifyListAction.title = "修改东西"
            modifyListAction.activationMode = UIUserNotificationActivationMode.Foreground
            modifyListAction.destructive = false
            modifyListAction.authenticationRequired = false
            
            var deleteListAction = UIMutableUserNotificationAction()
            deleteListAction.identifier = "delete"
            deleteListAction.title = "删除"
            deleteListAction.activationMode = UIUserNotificationActivationMode.Background
            deleteListAction.destructive   = false
            deleteListAction.authenticationRequired = true
            
            
            let actionArray = NSArray(objects: justInformAction, modifyListAction, deleteListAction)
            let actionArrayMinimal = NSArray(objects: deleteListAction, modifyListAction)
            
            //定义分类与action的关系
            var shoppingListRemindCategory = UIMutableUserNotificationCategory()
            shoppingListRemindCategory.identifier = "shoppingListReminderCategory"
            shoppingListRemindCategory.setActions(actionArray as [AnyObject], forContext:UIUserNotificationActionContext.Default )
            shoppingListRemindCategory.setActions(actionArrayMinimal as [AnyObject] , forContext: UIUserNotificationActionContext.Minimal)
            
            let categoriesForSettings = NSSet(object: shoppingListRemindCategory)
            
            //注册通知设定
            let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings as Set<NSObject>)
            UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
            
        }
    }

    
}
