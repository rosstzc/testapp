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
    var messages:[RemindMessage] = []
    
    var remindLC = AVObject(className: "Remind")

    var user = NSUserDefaults.standardUserDefaults()

    let currentUser = AVUser.currentUser()
    
    @IBOutlet weak var pic: UIImageView!

    @IBOutlet weak var textTitle: UITextField!

    @IBOutlet weak var textViewContent: UITextView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textViewContent.delegate = self
        self.textTitle.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
//        print(currentUser.objectId)

        // Do any additional setup after loading the view.
        
        //通知初始化设置
//        setupNotificationSettings()  //不用本地提醒，所以屏蔽它
        
        //获取用户uid
        
        print("read userDefault",user.valueForKey("name"))
        print("uuid",user.valueForKey("uid"))
        pic.image = UIImage(named: "camera@1.5x")  //默认icon
//        pic.image = UIImage(named: "fangbingbing")  //测试用

//        showImageFullScreen(pic.image!) //测试用
        
        
        //如果是“修改remind流程”，第一次加载view时就把remind内容写入userDefault中
        if remind != nil {
            user.setObject(remind.remindId, forKey: "remindId")
            user.setObject(remind.title, forKey: "remindTitleTemp")
            user.setObject(remind.content, forKey: "remindContentTemp")
            user.setObject(remind.remindTimeArray, forKey: "remindTimeArray")
            //标题变为“修改提醒”
            self.title = "修改提醒"
            user.synchronize()
        
            //在修改流程，从LC获取图片并放入userDefault
            remindId = remind.remindId! as String
            if let imageTemppp = getImageFromLC("Remind", objectId: remindId) {
                user.setObject(UIImageJPEGRepresentation(imageTemppp, 100), forKey: "uploadImage")
                user.synchronize()
            } else {
                print("没有照片")
            }
        }
        
        //不管什么流程，尝试从userDefault获取照片,然后显示在界面
        if user.valueForKey("uploadImage") != nil {
            let imageTemp = UIImage(data: user.valueForKey("uploadImage") as! NSData)
            pic.image = imageTemp
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
    }
    
 
    //实习placeholder效果
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
            remindTimeArray = remindTimeArray.reverse()
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
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default,  handler: { (action) -> Void in
            self.launchCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "从手机相册", style: UIAlertActionStyle.Default,  handler: { (action) -> Void in
            self.launchPhotoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel,  handler: { (action) -> Void in
        }))
        
        presentViewController(actionSheet, animated: true, completion: nil)
        
    }
    
    
    //看相册
    func launchPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            print ("access library")
        }
        picker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        picker.allowsEditing   = false
        self.presentViewController(picker, animated: true, completion:nil)
    }
    //触发拍照
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
        
        //临时放到userDefault，保存后再删除
        pic.image = image
        let temp = UIImageJPEGRepresentation(image, 95)
        user.setObject(temp, forKey: "uploadImage")
        user.synchronize()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    //测试用
    func showImageFullScreen(image:UIImage) {
        let vc:UIViewController = UIViewController()
        let imageView:UIImageView = UIImageView()
        
        //        view.contentMode = UIViewContentMode.ScaleToFill
        imageView.image = image
        imageView.backgroundColor = UIColor.whiteColor()
        imageView.contentMode = UIViewContentMode.Center
        imageView.frame = CGRectMake(100, 100, imageView.frame.size.width, imageView.frame.size.height)
        vc.view.addSubview(imageView)
        
        self.navigationController?.pushViewController(vc, animated:true)
        
    }

    @IBAction func addRemindTime(sender: AnyObject) {
        //把输入的内容临时保存到userDefault
        user.setObject(textTitle.text, forKey: "remindTitleTemp")
        user.setObject(textViewContent.text, forKey: "remindContentTemp")
    }
    
    //
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "saveSegue" {
            //如果未选择时间，或者标题为空，就阻止segue跳转
            if remindTimeArray.isEmpty || textTitle == "" {
                return false
            } else {
                return true
            }
        }
        return true
    }
    

    @IBAction func tappedSave(sender: AnyObject) {
        
        user = NSUserDefaults.standardUserDefaults()
  
        //如果有remind，那么就是修改后值存入到该remind对应的coredata
        let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        
//        如果未选择提醒时间，给出alert提醒
        if remindTimeArray.isEmpty || textTitle == "" {
            let alert = UIAlertView(title: "提醒", message:"亲，请补充标题或提醒时间。", delegate: self, cancelButtonTitle: "知道了")
            alert.show()
            return
            
        }
        
        //这个userDefault是用在showRemind页，用户于显示图片，因为uploadImage会在保存流程中清空
        if user.valueForKey("uploadImage") != nil {
            print("yes")
            user.setObject(user.valueForKey("uploadImage"), forKey: "imageTemp")
            user.synchronize()
        }
        
        
        if remindId != "" {   //修改流程
            print(remindId)
            let filter:NSPredicate = NSPredicate(format: "remindId = %@", remindId)
            let request = NSFetchRequest(entityName: "Remind")
            request.predicate = filter
            let temp = (try! context.executeFetchRequest(request)) as! [Remind]
            remind = temp[0]
            remind.title = textTitle.text!
            remind.content = textViewContent.text!
            remind.remindTimeArray = remindTimeArray
            remind.updateTime = NSDate()
//            remind.sentTime = NSDate()
            remind.createAt = NSDate()

            
            //先从LC查询到对应的remind
            let query = AVQuery(className: "Remind")
            remindLC = query.getObjectWithId(remindId)
            remindLC.setObject(textTitle.text!, forKey: "title")
            remindLC.setObject(textViewContent.text!, forKey: "content")
            remindLC.setObject(remindTimeArray, forKey: "remindTimeArray")
//            remindLC.setObject(NSDate(), forKey: "sentTime")
            
            //先把原来图片删除(只有修改流程才又需要删除老的照片)
            deleteImageFromLC("Remind", objectId: remindId)
            print("123")

        } else { //新创建
            let uid = user.valueForKey("uid") as? String
            remind = NSEntityDescription.insertNewObjectForEntityForName("Remind",inManagedObjectContext: context) as! Remind
            remind.title = textTitle.text!
            remind.content = textViewContent.text!
            if textViewContent.text! == placeHolder {
                remind.content = ""
            }
            remind.remindTimeArray = remindTimeArray
            remind.updateTime = NSDate()
            remind.createNot = "1"
            remind.uid = uid
            remind.sentTime = NSDate()
            remind.createAt = NSDate()
            
            
            //写入LC数据库
            remindLC.setObject(textTitle.text!, forKey: "title")
            remindLC.setObject(textViewContent.text!, forKey: "content")
            remindLC.setObject(remindTimeArray, forKey: "remindTimeArray")
            remindLC.setObject(currentUser, forKey: "uid")
//            remindLC.setObject(NSDate(), forKey: "sentTime")
        }


        
        //从userDefault获取图片，保存到LC的AVFile
        if user.valueForKey("uploadImage") != nil {
            let imageData = user.valueForKey("uploadImage") as! NSData
            let imageTemp = UIImage(data: imageData)
           let fileData = saveImageToLC(imageTemp!)
            remindLC.setObject(fileData, forKey: "image")
        }
        

        
        
        //触发先保存到LC，如果LC成功再保存本地
        remindLC.save()
        remindLC.saveInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
            if (error != nil) {
                print(error)
            } else {
        
                do {
                    self.remind.remindId = self.remindLC.objectId   //获取LC上objectId, 写入到本地
                    try context.save()
                    
                    //写入订阅
                    addLCInstallation(self.remindLC.objectId)
                    
                    //创建时，即触发一条已读提醒信息（让用户在首页感知关注了什么）
                    let uid = self.user.valueForKey("uid") as? String
                    if self.remindId == "" {
                        addRemindMessage(self.remind, uid: uid!, time: NSDate(), state: 1)
                    }

                    
                    //当修改remind时，修改FollowRemind表的changeKey标记为true
                    if self.remindId != "" {
                        let query = AVQuery(className: "FollowAtRemind")
                        query.whereKey("rid", equalTo: self.remindId)
                        if let result = query.findObjects() {
                            for i in result {
                                i.setObject(true , forKey: "changeKey")
                            }
                            AVObject.saveAll(result)
                        }
        
                        
                        //删除LC的RemindTime表中对应该remind的时间
                        let remindTemp = AVObject(withoutDataWithClassName: "Remind", objectId: self.remindId)
                        let queryRemindTime = AVQuery(className: "RemindTime")
                        print(self.remindId)
                        queryRemindTime.whereKey("remindId", equalTo: remindTemp )
                        let temp = queryRemindTime.findObjects()
                        print(queryRemindTime.countObjects())
                        AVObject.deleteAll(temp)
                    }

                    
                    //创建 提醒时间表，把提醒时间逐个加入
                    for i in self.remindTimeArray {
                        let remindTime = AVObject(className: "RemindTime")
                        let timeTemp = i.valueForKey("remindTime") as! String
                        let interval = i.valueForKey("repeatInterval") as! String
                        remindTime.setObject(timeTemp, forKey: "remindTime")
                        remindTime.setObject(interval, forKey: "repeatInterval")
                        remindTime.setObject(self.remindLC, forKey: "remindId")
                        remindTime.save()
                    }
                    



                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    //先删除所有通知
                    //            UIApplication.sharedApplication().cancelAllLocalNotifications()
                    //            //触发通知
                    //            for i in  (user.valueForKey("remindTimeArray") as! NSArray) {
                    //                print(i)
                    //                print(i["remindTime"])
                    //
                    //                let remindTimeString = i["remindTime"] as! String
                    //                let dateFormatter = NSDateFormatter()
                    //                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    //                let remindTime = dateFormatter.dateFromString(remindTimeString)
                    //
                    //                let repeatType: NSCalendarUnit = NSCalendarUnit.Minute   //未完根据界面选项生成
                    //                scheduleLocalNotificationWith(remindTime!, repeated: repeatType )
                    //            }
                    
                } catch {
                    print(error)
                }

                //        self.navigationController?.popViewControllerAnimated(true)

                //        self.performSegueWithIdentifier("segueToRemindListCreateVC", sender: self)
                //        let storyboard = UIStoryboard(name: "Main", bundle: nil);
                //        let vc = storyboard.instantiateViewControllerWithIdentifier("navToRemindCreate") as UIViewController
                //        self.presentViewController(vc, animated: true, completion: nil)
                
            }
        })
        //保存后，要把userDefault的remindTimeArray清空
        self.setUserDefaultNil()

    }
    

    
    @IBAction func tappedCancel(sender: AnyObject) {
        print("tapped cancel")
        self.dismissViewControllerAnimated(true, completion: nil)
        //如果是修改流程，在退出前清理临时记录
        if user.valueForKey("remindId") != nil {
            setUserDefaultNil()
        }
    }
    
    
    func setUserDefaultNil() {
        user.setObject([], forKey: "remindTimeArray")
        user.setObject("", forKey: "remindTitleTemp")
        user.setObject("", forKey: "remindContentTemp")
        user.setObject(nil, forKey: "remindId")
        user.setObject(nil, forKey: "uploadImage")
        user.synchronize()
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
