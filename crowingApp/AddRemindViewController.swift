//
//  AddRemindViewController.swift
//  crowingApp
//
//  Created by a a a a a on 15/8/29.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData

class AddRemindViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate  , UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIAlertViewDelegate  {
    
//    @IBOutlet weak var remindTime: UILabel!
//    @IBOutlet weak var repeatInterval: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    var MainVC = RemindListViewController()
    var remindTimeArray: [AnyObject] = []
    var placeHolder = "补充（可为空）"
    var remind:Remind! = nil
    var remindId:String = ""
    
    let user = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var pic: UIImageView!

    @IBOutlet weak var textTitle: UITextField!

    @IBOutlet weak var textViewContent: UITextView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textViewContent.delegate = self
        self.textTitle.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        //通知初始化设置
        setupNotificationSettings()
        
        //获取用户uid
        print("read userDefault",user.valueForKey("name"))
        print("uuid",user.valueForKey("uid"))
        
        



        
//        if let remindId = user.valueForKey("remindId") as? String {
//            print  (remindId)
//            let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
//            let request = NSFetchRequest(entityName: "Remind")
//            request.predicate = NSPredicate(format: "remindId = %@",(remindId))
//            let reminds = (try! context.executeFetchRequest(request)) as! [Remind]
//            remind = reminds[0]
//        }
//        
        
        //如果是修改remind流程，第一次加载view时就把remind内容写入userDefault中
        if remind != nil {
            user.setObject(remind.remindId, forKey: "remindId")
            user.setObject(remind.title, forKey: "remindTitleTemp")
            user.setObject(remind.content, forKey: "remindContentTemp")
            user.setObject(remind.remindTimeArray, forKey: "remindTimeArray")
            //标题变为“修改提醒”
            self.title = "修改提醒"
        }
        
        //检查userDefault有没有remind记录，如果有就赋值到这里 （在提交保存时，要清空userDefault的 remind记录）
        if user.valueForKey("remindId") != nil {
            remindId = user.valueForKey("remindId") as! String
        }

        
        //从userDefault读取数据显示到view
        textTitle.text = user.valueForKey("remindTitleTemp") as? String
        textViewContent.text = user.valueForKey("remindContentTemp") as? String
        if textViewContent.text == "" {
            textViewContent.text = placeHolder
            textViewContent.textColor = UIColor.lightGrayColor()
        }
    
        remindTimeArray = user.arrayForKey("remindTimeArray")! 
        //重排数组
        
//        if remindTimeArray.count > 0 {
////            print(user.arrayForKey("remindTimeArray"))
//            print("4444")
//            var temp:[AnyObject] = []
//            print(remindTimeArray[0])
//            var n = remindTimeArray.count
//            for _ in 0...n {
//                if n == 0 {
//                    break
//                }
//                n = n - 1
//                temp.append(remindTimeArray[n])
//                print (temp)
//            }
//            remindTimeArray = temp
//        }

        

        
        
//        if user.arrayForKey("remindTimeArray")  == [] {
//            print("4444")
//
//        }
        
//        if user.arrayForKey("remindTimeArray") != nil {
//            
//            var temp = remindTimeArray[0]
//            print("eee")
//            print(temp)
////            
////            remindTimeArray = user.arrayForKey("remindTimeArray")! as NSMutableArray as [AnyObject] as [AnyObject]
////            var temp: [AnyObject] = []
////            
////            temp = remindTimeArray[0]
////            
////            var n = remindTimeArray.count
////            for _ in 0...n {
////                temp.append(remindTimeArray[n])
////                n = n - 1
////            }
////            remindTimeArray = temp
//        }
        
        
    }
    


    
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textViewContent.text == placeHolder {
            textViewContent.text = ""
            textViewContent.textColor = UIColor.blackColor()
        }
    }
    func textViewDidEndEditing(textView: UITextView) {
        if textViewContent.text == "" {
            textViewContent.text = placeHolder
            textViewContent.textColor = UIColor.lightGrayColor()
        }
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
        test = remindTimeArray.reverse()[indexPath.row] as! [String : String]
        
        remindTime.text = test["remindTime"]
        repeatInterval.text = test["repeatInterval"]
        return cell!
    }

    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            //在userdefault删除某个提醒时间
            remindTimeArray.removeAtIndex(indexPath.row)
            user.setObject(remindTimeArray, forKey: "remindTimeArray")
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    
    
//    @IBAction func cancel(sender: AnyObject) {
//        self.dismissViewControllerAnimated(true, completion: nil)
//        print("cancel")
//    }
    
    
    @IBAction func addPic(sender: AnyObject) {
        launchCamera()
        
    }
    
    func launchCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.allowsEditing   = true
            
            picker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.On
            if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front) {
                picker.cameraDevice = UIImagePickerControllerCameraDevice.Front
            }
            self.presentViewController(picker, animated: true, completion: {() ->Void in })
        }
        else {
            print("no camera")
        }
        
    }
    
    //处理图片，代理逻辑
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        pic.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }

    

    @IBAction func addRemindTime(sender: AnyObject) {
        
        //把输入的内容临时保存到userDefault
        user.setObject(textTitle.text, forKey: "remindTitleTemp")
        user.setObject(textViewContent.text, forKey: "remindContentTemp")
    }
    

    @IBAction func tappedSave(sender: AnyObject) {

        //如果有remind，那么就是修改后值存入到该remind对应的coredata
        // ...对应如何处理系统通知，得再考虑
        let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!

        //如果选择提醒时间，给出alert提醒
        if remindTimeArray.isEmpty || textTitle == "" {
            let alert = UIAlertView(title: "提醒", message:"请添加提醒日期时间.", delegate: self, cancelButtonTitle: "知道了")
            alert.show()
            return
        }
        

        
        if remindId != "" {   //修改
            let filter:NSPredicate = NSPredicate(format: "remindId = %@", remindId)
            let request = NSFetchRequest(entityName: "Remind")
            request.predicate = filter
            let temp = (try! context.executeFetchRequest(request)) as! [Remind]
            remind = temp[0]
            remind.title = textTitle.text!
            remind.content = textViewContent.text!
            remind.remindTimeArray = remindTimeArray
            remind.updateTime = NSDate()



        } else { //新创建
            remind = NSEntityDescription.insertNewObjectForEntityForName("Remind",inManagedObjectContext: context) as! Remind
            remind.title = textTitle.text!
            remind.content = textViewContent.text!
            remind.remindTimeArray = remindTimeArray
            remind.updateTime = NSDate()
            remind.remindId = NSUUID().UUIDString
            remind.createNot = "1"
            remind.uid = user.valueForKey("uid") as? String
        }

        

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
            user.setObject(nil, forKey: "remindId")
            user.synchronize()
            
            
            
        } catch {
            print(error)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
//        self.navigationController?.popViewControllerAnimated(true)
        

        
//        self.performSegueWithIdentifier("segueToRemindListCreateVC", sender: self)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//        let vc = storyboard.instantiateViewControllerWithIdentifier("navToRemindCreate") as UIViewController
//        self.presentViewController(vc, animated: true, completion: nil)

    }
    

//    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
//        if identifier == ""
//    }
    
    @IBAction func tappedCancel(sender: AnyObject) {
        print("tapped cancel")
        self.dismissViewControllerAnimated(true, completion: nil)
        //如果是修改流程，在退出前清理临时记录
        if user.valueForKey("remindId") != nil {
            user.setObject([], forKey: "remindTimeArray")
            user.setObject("", forKey: "remindTitleTemp")
            user.setObject("", forKey: "remindContentTemp")
            user.setObject(nil, forKey: "remindId")
        }
        
    
    }

    override func viewWillAppear(animated: Bool) {
//        self.viewDidLoad()
        //
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

    
    
    //点return键，键盘屏蔽
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textTitle.resignFirstResponder()
        return true
    }
    
    //滚动时，让键盘隐藏
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        textTitle.resignFirstResponder()
        textViewContent.resignFirstResponder()
    }
    
    
    
    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        textTitle.resignFirstResponder()
//        textViewContent.resignFirstResponder()
//    }
    
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
    
    //配置通知 （这没用上）
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
