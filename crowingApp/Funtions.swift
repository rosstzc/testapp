//
//  Funs.swift
//  crowingApp
//
//  Created by michaeltam on 15/10/26.
//  Copyright © 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData

let siteUrl:String = "http://"

func temp2() {
    print("666")
}


//使用RGB的16进制颜色
func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

// 获得我喜欢过的checkIn的like标记 （行位置）
func getMarkForCurrentUserLikeCheck(queryCheckIn:AVQuery, checkIns:[AnyObject], user:AnyObject) ->[AnyObject]{
    print("34")
    // 找到我喜欢过的checkin (like记录)
    let query2 = AVQuery(className: "Comment")
    query2.whereKey("uid", equalTo: user)
    query2.whereKey("cid", matchesQuery: queryCheckIn)
    query2.whereKey("type", equalTo: "likeCheckIn")
    let likes = query2.findObjects()  //增加一个查询多1s
    
    
    //标记我喜欢过的 （重用于单个提醒页）
    var x = 0
    var markForCurrentUserLikeCheck:[AnyObject] = []
    for i in checkIns {
//        print(i.valueForKey("createdAt"))
        markForCurrentUserLikeCheck.append(0)
//        print(markForCurrentUserLikeCheck   )
        markForCurrentUserLikeCheck[x] = 0
        for j in likes {
            if (i.objectId as String) == (j.valueForKey("cid")!.objectId) {
//                print("1")
                markForCurrentUserLikeCheck[x] = 1
            }
        }
        x = x + 1
    }
    return markForCurrentUserLikeCheck
}




//获取点赞所在行和cell
func getCellRow(sender:AnyObject, tableView:UITableView) ->[AnyObject] {
    var row:Int = 0
    var selectCell:UITableViewCell = UITableViewCell()
    if let button = sender as? UIButton {
        if let superview = button.superview {
            if let cell = superview.superview as? UITableViewCell {
                row = (tableView.indexPathForCell(cell)?.row)!
                print(row)
                selectCell = cell
            }
        }
    }
    var temp:[AnyObject] = []
    temp.append(row)
    temp.append(selectCell)
    return temp
}


// 展示点赞按钮
func showLikeButton(checkIn:AnyObject, button:UIButton, indexPath:NSIndexPath, mark:[AnyObject]) -> UIButton{
    var markForCurrentUserLikeCheck:[AnyObject] = []
    markForCurrentUserLikeCheck = mark
    
    //有人赞过
    if var likeCount = checkIn.valueForKey("likes") {
        likeCount = checkIn.valueForKey("likes") as! Int
        
        //我赞过的

        if (markForCurrentUserLikeCheck[indexPath.row]) as! Int == 1 {
            print("position:\(markForCurrentUserLikeCheck[indexPath.row])")
            print("index: \(indexPath.row)")
            print(markForCurrentUserLikeCheck[indexPath.row])
            button.setTitle("已赞 \(likeCount)", forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        //我未赞过
        } else {
            button.setTitle("赞 \(likeCount)", forState: UIControlState.Normal)
            if likeCount as! NSObject == 0 {
                button.setTitle("赞 ", forState: UIControlState.Normal)
            }
            button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        }
        //从来没有被赞
    } else {
        button.setTitle("赞 ", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
    }

    
    return button
}




//点赞按钮（事件触发）
func changeLikeButton(checkIn:AVObject, currentUser:AnyObject, button:UIButton) -> UIButton {
    //        let checkIn = self.checkIns[row]
    let likeButton = button
    let rUid = checkIn.valueForKey("uid") as! AVObject
    let query = AVQuery(className: "Comment")
    query.whereKey("uid", equalTo: currentUser)
    query.whereKey("rUid", equalTo: rUid)
    query.whereKey("cid", equalTo: checkIn)
    query.whereKey("type", equalTo: "likeCheckIn")
    let result = query.findObjects()
    var likeCount:Int = 0
    if checkIn.valueForKey("likes") != nil {
        likeCount = checkIn.valueForKey("likes") as! Int
    }
    
    //检查是否已点赞
    if result.count >= 1 {
        likeCount = likeCount - 1
        likeButton.setTitle("赞 \(likeCount)", forState: UIControlState.Normal)
        likeButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        
        let oid = result[0].valueForKey("objectId") as! String
        let likeTemp = AVObject(withoutDataWithClassName: "Comment", objectId: oid)
        likeTemp.deleteInBackground()
        checkIn.incrementKey("likes", byAmount: -1)
        checkIn.saveInBackground()
    } else {
        //刷新为“已赞”
        likeCount = likeCount + 1
        likeButton.setTitle("已赞 \(likeCount)", forState: UIControlState.Normal)
        likeButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        
        let likeCheckIn = AVObject(className: "Comment")
        likeCheckIn.setObject(checkIn, forKey: "cid")
        likeCheckIn.setObject(currentUser, forKey: "uid")
        likeCheckIn.setObject(rUid, forKey: "rUid")
        likeCheckIn.setObject("likeCheckIn", forKey: "type")
        likeCheckIn.setObject("赞", forKey: "content")
        likeCheckIn.saveInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
            if error == nil {
                checkIn.incrementKey("likes")  //刷新累计值
                checkIn.save()
            }else {
                
            }
        })
    }
    return likeButton
}





//同步发布时间线内容 (type： checkIn、shareRemind、createRemind、shareCheckIn)
func sendStatus(type:String, cid:AnyObject, rid:AnyObject) {
    let status = AVStatus()
    //        var data:NSMutableDictionary
    //        data = [
    //            "type222" : "checkIn",
    //            "data" : ["objectId: 333"],
    //        ]
    //用户发动态(自定义的分类type和对应id，方便后续获取对应数据)
    if cid.isEqual("")  {
        status.data = ["statusType":type, "rid":rid]
    } else {
        status.data = ["statusType":type, "cid":cid, "rid":rid]
    }
    AVStatus.sendStatusToFollowers(status, andCallback: {(succeeded: Bool, error: NSError?) in
        if (error != nil) {
            print(error)
        } else {
        }
    })
}


// 删除一个remind
func deleteOneRemind(uid:String, rid:String) {
    let condition = "uid = '\(uid)' && remindId = '\(rid)'"
    deleteRemindMessage(condition)
    deleteRemind(condition)
    deleteLCInstallation(rid)
    deleteRemindLC(rid) //如果只有创建者1人订阅，删除时也删除LC上记录
}




//如果只有创建者1人订阅，删除时也删除LC上记录
func deleteRemindLC(rid:String) {
    let query = AVQuery(className: "FollowAtRemind")
    query.whereKey("rid", equalTo: rid)
    if query.countObjects() == 0 {
        let remind = AVObject(withoutDataWithClassName: "Remind", objectId: rid)
        remind.deleteInBackground()
    }
    
}



//从userDefault获取remindId
func getRemindId(user: NSUserDefaults) -> String?{
    var remindId:String = ""
    if user.valueForKey("remindId") != nil {
        remindId = user.valueForKey("remindId") as! String
        return remindId
    } else {
        return nil
    }
}

//删除LC上的图片
func deleteImageFromLC(className:String, objectId:String) {
    let query = AVQuery(className: className)
    let object = query.getObjectWithId(objectId)
    if let imageFile = object.objectForKey("image") as? AVFile {
        imageFile.deleteInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
            if error == nil {
            
            } else {
                print(error)
            }
        })
    }
}

//从LC获取图片(前台获取)
func getImageFromLC(className:String, objectId:String) -> UIImage?{
    //从LC获取图片
    print(objectId)
    let query = AVQuery(className: className)
    query.cachePolicy = AVCachePolicy.CacheElseNetwork
    query.maxCacheAge = 1 //缓存时间，单位秒
    let object = query.getObjectWithId(objectId)
    var imageData:NSData? = nil
    if let imageFile = object.objectForKey("image") as? AVFile {
        imageData = imageFile.getData()
        return UIImage(data: imageData!)!
    } else {
        return nil
    }
}


//从LC获取图片(后台获取)
func getImageBackgroundFromLC(className:String, objectId:String) -> UIImage?{
    //从LC获取图片
    print(objectId)
    let query = AVQuery(className: className)
    query.cachePolicy = AVCachePolicy.CacheElseNetwork
    query.maxCacheAge = 3600 //缓存时间，单位秒
    let object = query.getObjectWithId(objectId)
    var image:UIImage? = nil
    if let imageFile = object.objectForKey("image") as? AVFile {
        imageFile.getDataInBackgroundWithBlock({(data: NSData?, error: NSError?) in
            print(error)
            if error == nil {
                //let image: UIImage = UIImage(data: data!, scale: UIScreen.mainScreen().scale)!
                image = UIImage(data: data!)!
                //            self.showImage(image)
                //            self.log("成功得到图片: \(image.description)")
            }
            },progressBlock:{(percentDone: Int) in
                //            self.log("加载进度: \(percentDone)%%")
            print("")
        })
        return image
    } else {
        
    }
    return nil
}






//把照片保存到AVFile
func saveImageToLC(image:UIImage) -> AVFile{
    let temp = compressImage2(image)
    let imageFile = AVFile(name: "image.jpg", data: temp)
    imageFile.save()
    return imageFile
}


//按目前逻辑，只要从本地能查到的remind，都能保证最新； 只有在本地去不到然后才需要到LC上查，因此segue那个页面操作，比如动态页，不在这个页面获取数据
func getRemindFromLC(rid:String, uid: String ) -> Remind{
    var remind:Remind! = nil
    let reminds = getOneRemind("uid = '\(uid)' && remindId = '\(rid)'")
    if reminds.count > 0 {
        remind = reminds[0] as Remind
    } else {
        let remindLC = AVObject(withoutDataWithClassName: "Remind", objectId: rid )
        remind.content = remindLC.objectForKey("content") as? String
        remind.remindTimeArray = remindLC.objectForKey("remindTimeArray") as! NSArray
        remind.title = (remindLC.objectForKey("title") as! String)
        remind.updateTime = remindLC.objectForKey("updatedAt") as? NSDate
        
        //        remind.createNot = remindLC.objectForKey(String!)
        //        remind.schedule = remindLC.objectForKey(<#T##key: String!##String!#>)
        //        remind.uid = remindLC.objectForKey(<#T##key: String!##String!#>)
        //        remind.updateTime = remindLC.objectForKey(<#T##key: String!##String!#>)
        //        remind.sentTime = remindLC.objectForKey(<#T##key: String!##String!#>)
    }
    return remind
    
}


// 在主页每次更新关注提醒的信息
func updateFollowRemind(uid: String) {
    
    
//    var reminds:[Remind]! = []
////    reminds = getOneRemind("uid = '\(uid)' && create = '0'")
//    var ridArray = [String]()
//    for i in reminds {
//        ridArray.append(i.remindId!)
//    }
    //从LC找到最近有更新的关注提醒项目 （这里有个前提是每次在LC上的remind更新都会触发FollowAtRemind表的changeKey），更新本地内容
    let query = AVQuery(className: "FollowAtRemind")
    query.whereKey("changeKey", equalTo: true)
    query.whereKey("uid", equalTo: uid)
    query.includeKey("rid")
    let result = query.findObjects()
    
    if query.countObjects() > 0 {
        
        //把LC最新的remind（关注的提醒）信息 copy到本地
        for i in result {
            let remindLC = i.objectForKey("rid")
            
            let ridTemp = remindLC!.objectForKey("rid") as! String
            let title = remindLC!.objectForKey("title") as! String
            let content = remindLC!.objectForKey("content") as! String
            let remindTimeArray = remindLC!.objectForKey("remindTimeArray") as! NSArray
            let updateTime = remindLC!.objectForKey("updatedAt") as! NSDate

            let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
            let request = NSFetchRequest(entityName: "Remind")
            request.predicate = NSPredicate(format: "remindId = '\(ridTemp)' && uid = '\(uid)' && createNot = '0'")
            let temp = (try! context.executeFetchRequest(request)) as! [Remind]
            if temp.count > 0  {
                let remind = temp[0]
                remind.title = title
                remind.content = content
                remind.remindTimeArray = remindTimeArray
                remind.updateTime = updateTime
                
                do {
                    try context.save()
                }catch {
                    print(error)
                }
                // 把处理了的项目的标记设置为false
                i.setObject(false, forKey: "changeKey")
            }
        }
        AVObject.saveAllInBackground(result)  //批量保存LC
    }
    
    
    

}


func getOneRemind(condition:String) -> [Remind]{
    let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    let request = NSFetchRequest(entityName: "Remind")
    request.predicate = NSPredicate(format: condition)
    let reminds = (try! context.executeFetchRequest(request)) as! [Remind]
    return reminds
}


func addLCInstallation(remindId:String) {
    let currentInstallation = AVInstallation.currentInstallation()
    currentInstallation.addUniqueObject(remindId, forKey: "channels")
    currentInstallation.save()
}


func deleteLCInstallation(remindId:String) {
    let currentInstallation = AVInstallation.currentInstallation()
    currentInstallation.removeObject(remindId, forKey: "channels")
    currentInstallation.save()
}


func deleteRemind(condition:String) {
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    print(condition)
    let request =  NSFetchRequest(entityName: "Remind")
    request.predicate = NSPredicate(format: condition)
    print(condition)
    var temp:[Remind] = []
    temp = (try! context.executeFetchRequest(request)) as! [Remind]
    if temp.count > 0 {
        for i in temp {
            context.deleteObject(i)
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
}


func deleteRemindMessage(condition:String) {
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    print(condition)
    let request =  NSFetchRequest(entityName: "RemindMessage")
    request.predicate = NSPredicate(format: condition)
    var temp:[RemindMessage] = []
    temp = (try! context.executeFetchRequest(request)) as! [RemindMessage]
    if temp.count > 0 {
        for i in temp {
            //            i.state = 2 //表示删除，但不真实删除，可能以后有用
            context.deleteObject(i)
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
}



func addRemindMessage(remind:Remind, uid:String, time:NSDate, state:Int = 0) {
    // 写入提醒信息
    let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    let Message = NSEntityDescription.insertNewObjectForEntityForName("RemindMessage",inManagedObjectContext: context) as! RemindMessage
    Message.title = remind.title
    Message.content = remind.content
    Message.timeRemind = time
    Message.remindId = remind.remindId
    Message.uid = uid
    Message.state = state
    do {
        //                    remind.repeat_type = "e   / 未完，需要在界面选择
        try context.save()
//        return true
    } catch _ {
//        return false
    }
    
}


func dateFromStringWithFormat(timeString:String, format:String = "yyyy-MM-dd HH:mm:ss") -> NSDate{
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = format
    let time = dateFormatter.dateFromString(timeString)
    return time!
}


func stringFromDateWithFormat(time:NSDate, format:String = "yyyy-MM-dd") -> String{
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = format
    let timeString = dateFormatter.stringFromDate(time)
    return timeString
}


//指定格式显示时间
func timeStringForMessage(time:NSDate, type:String = "message") ->String{
    var timeStamp = ""
    let nowTime = NSDate()
    let gapTime =  Int(nowTime.timeIntervalSinceDate(time))
    
    let interval:NSTimeInterval = 24*60*60
    let yesterday:NSDate  = nowTime.dateByAddingTimeInterval(-interval)
    let beforeYesterday:NSDate = nowTime.dateByAddingTimeInterval(-interval*2)
    
    let timeString = stringFromDateWithFormat(time)
    let nowTimeString = stringFromDateWithFormat(nowTime)
    let yesterdayString = stringFromDateWithFormat(yesterday)
    let beforeYesterdayString = stringFromDateWithFormat(beforeYesterday)
    
    //五分钟内显示刚刚
    if (gapTime < 300) {
        timeStamp = "刚刚"
    }
        //五分钟以上且一个小时之内的，显示“多少分钟前”，例如“5分钟前”
    else if (300 < gapTime && gapTime < 60*60) {
        timeStamp = "\(gapTime/60)分钟前"
    }
        
        
        //显示今天时间
    else if (timeString == nowTimeString ) {
        
        if type == "message" {
            let temp = Int(stringFromDateWithFormat(time, format: "H"))
            if (0 <= temp && temp <= 11) {
                timeStamp = ("\(stringFromDateWithFormat(time, format: "h:mm"))")
            }else {
                timeStamp = ("下午\(stringFromDateWithFormat(time, format: "h:mm"))")
            }
        }
        
        //当在timeline显示时，采用最近24小时方式展示
        if type == "timeline" {
            timeStamp = "\(gapTime/3600)小时前"
        }
        
        
    }
        //显示昨天
    else if (timeString == yesterdayString) {
        timeStamp = "昨天"
        //        当在timeline显示时，采用最近24小时方式展示
        if (type == "timeline" && gapTime < 24*60*60) {
            timeStamp = "\(gapTime/3600)小时前"
        }
        
    }
        //显示前天
    else if (timeString == beforeYesterdayString) {
        timeStamp = "前天"
    }
        //显示日期
    else{
        timeStamp = stringFromDateWithFormat(time, format: "yy/M/d")
        
    }
    return timeStamp
}



//图片压缩 ->jpg
func compressImage(image: UIImage) -> UIImage {
    var actualHeight : CGFloat = image.size.height
    var actualWidth : CGFloat = image.size.width
    let maxHeight : CGFloat = 600.0
    let maxWidth : CGFloat = 800.0
    var imgRatio : CGFloat = actualWidth/actualHeight
    let maxRatio : CGFloat = maxWidth/maxHeight
    let compressionQuality : CGFloat = 0.5 //50 percent compression
    
    if ((actualHeight > maxHeight) || (actualWidth > maxWidth)){
        if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth
            actualHeight = imgRatio * actualHeight
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight
            actualWidth = maxWidth
        }
    }
    
    let rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight)
    UIGraphicsBeginImageContext(rect.size)
    image.drawInRect(rect)
    let img : UIImage = UIGraphicsGetImageFromCurrentImageContext()
    let imageData = UIImageJPEGRepresentation(img, compressionQuality)
    UIGraphicsEndImageContext()
    
    return UIImage(data: imageData!)!
}


//图片压缩 -> jpg

func compressImage2(image:UIImage) -> NSData {
    // Reducing file size to a 10th
    var actualHeight : CGFloat = image.size.height
    var actualWidth : CGFloat = image.size.width
    let maxHeight : CGFloat = 1136.0
    let maxWidth : CGFloat = 640.0
    var imgRatio : CGFloat = actualWidth/actualHeight
    let maxRatio : CGFloat = maxWidth/maxHeight
    var compressionQuality : CGFloat = 0.5
    
    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight
            actualWidth = imgRatio * actualWidth
            actualHeight = maxHeight
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth
            actualHeight = imgRatio * actualHeight
            actualWidth = maxWidth
        }
        else{
            actualHeight = maxHeight
            actualWidth = maxWidth
            compressionQuality = 1
        }
    }
    
    let rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight)
    UIGraphicsBeginImageContext(rect.size)
    image.drawInRect(rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    let imageData = UIImageJPEGRepresentation(img, compressionQuality)
    UIGraphicsEndImageContext()
    
    return imageData!
}






class Functions: UIViewController, UIPickerViewDelegate {
    class func temp() ->String {
        print("2222")
        return "34"
    }
    
    class func abc() -> String {
        print("123")
        return "123"
    }

    
    class func dateFromString(timeString:String) -> NSDate{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let time = dateFormatter.dateFromString(timeString)
        return time!
    }
    
    class func stringFromDate(time:NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timeString = dateFormatter.stringFromDate(time)
        return timeString
    }
    
    
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}




//重排数组  --自己实现但没有用

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

