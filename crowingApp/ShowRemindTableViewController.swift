//
//  ShowRemindTableViewController.swift
//  crowingApp
//
//  Created by michaeltam on 15/12/9.
//  Copyright © 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage
//import Alamofire

class ShowRemindTableViewController: UITableViewController {

    @IBOutlet weak var imageHeightContraint:NSLayoutConstraint?
    

    
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var remindTitle: UILabel!
    @IBOutlet weak var remindContent: UITextView!
    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var checkContent: UITextField!
    
    @IBOutlet weak var tableHeadView: UIView!
    
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
        tableView.dataSource = self
        tableView.delegate  = self
        
        //显示toolbar，用程序增加toolbar
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.remindContent.editable = false
        
        self.remindContent.dataDetectorTypes = UIDataDetectorTypes.All  //检查textView的链接等
        

        
        self.navigationItem.title = remind.title
        remindContent.scrollEnabled = false
        
        

        
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
        
        //有图片的情况
        if imageView.image != nil {
            //图片的实际尺寸
            let imageHeight = imageView.image?.size.height
            let imageWidth = imageView.image?.size.width
            let imageRatio = imageWidth! / imageHeight!
            
            let rect = UIScreen.mainScreen().bounds.size.width //手机窗口的实际尺寸，通过这个计算imageView的高度
            var imageViewHeight = imageView.frame.size.height
            
            imageViewHeight = (rect - 20) / imageRatio
            imageHeightContraint?.constant = imageViewHeight // 在手机显示的实际高度
        } else {
            imageHeightContraint?.constant = 0  //通过设置高度为0来隐藏，但这里有有问题是距离边框的高度空位还是有
        }

        
     
        //
        if remind != nil {
            remindTitle.text = remind?.title
            remindContent.text = remind?.content
            if remindContent.text == "" {
                remindContent.hidden = true
            }
            
            author.text = currentUser.valueForKey("name") as? String
        }
        
        remindTitle.sizeToFit()  //label多行时刷新高度
        let s = tableHeadView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) //重新计算view内所有元素的高度
        print(s.height)
        tableHeadView.frame.size.height = s.height  //刷新headview的高度
        
        //用于行高，与下面的estimatedHeight一并使用
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0; // 设置为一个接近“平均”行高的值

        
        
        //获取checkIn的数据
        let remindLC = AVObject(withoutDataWithClassName: "Remind", objectId: rid)
        let query = AVQuery(className: "CheckIn")
        query.whereKey("rid", equalTo: remindLC)
        query.includeKey("uid")
        query.includeKey("image")
        query.orderByDescending("createdAt")
        query.limit = 100
//        let result = query.findObjects()
//        self.checkInCount = result.count
//        self.checkIns = result!

        query.findObjectsInBackgroundWithBlock({(objects:[AnyObject]? , error:NSError?)  in
            if (error != nil) {
                print("错误")
            } else {
                self.checkInCount = objects!.count
                self.checkIns = objects!
                print(objects?.count)
                
                //把图片写入alamofire的cache
//                let imageCache = AutoPurgingImageCache()
//                for i in self.checkIns {
//                   let  urlString = i.valueForKey("image")?.valueForKey("url") as! String
//                    
//                    let URLRequest = NSURLRequest(URL: NSURL(string: urlString)!)
//                    let avatarImage = UIImage(named: "avatar")!.af_imageRoundedIntoCircle()
//                    // Add
//                    imageCache.addImage(
//                        avatarImage,
//                        forRequest: URLRequest,
//                        withAdditionalIdentifier: "circle")
//                }
                

                
            }
        })
        
        markForCurrentUserLikeCheck = getMarkForCurrentUserLikeCheck(query, checkIns: checkIns, user: currentUser)
        
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
        if segue.identifier == "segueToComment" {
            let nextVC = segue.destinationViewController as! CommentTableViewController
            var cellRow = getCellRow(sender!, tableView: self.tableView)
            let row = cellRow[0] as! Int
            nextVC.checkIn = self.checkIns[row] as! AVObject
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
        changeLikeButton(self.checkIns[row] as! AVObject, currentUser: currentUser, button: likeButton)
        
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
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        checkContent.resignFirstResponder()
//        return true
//    }
//    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        checkContent.resignFirstResponder()
//    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.checkInCount
    }

    //每行加载时都执行一次
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        
//        let cell = tableView.dequeueReusableCellWithIdentifier("checkInCell")!
//        
//        let s = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) //重新计算view内所有元素的高度
//        print(s.height)
//        //        cell.frame.size.height = s.height  //刷新headview的高度
//        return 1 + s.height
//    }
    
    //view加载时执行
//    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let cell = tableView.dequeueReusableCellWithIdentifier("checkInCell")!
//        
//        let s = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) //重新计算view内所有元素的高度
//        print(s.height)
//        //        cell.frame.size.height = s.height  //刷新headview的高度
//        return 1 + s.height
//    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("checkInCell")!
        let cell = tableView.dequeueReusableCellWithIdentifier("checkInCell", forIndexPath: indexPath)
        let checkIn = checkIns[indexPath.row]
        
        let avatarView = cell.viewWithTag(10) as! UIImageView
        let username = cell.viewWithTag(11) as! UILabel
        let time = cell.viewWithTag(12) as! UILabel
        let imageView = cell.viewWithTag(13) as! UIImageView
        
        let content = cell.viewWithTag(18) as! UITextView
        content.scrollEnabled = false
        content.editable = false

        var likeButton  = cell.viewWithTag(15) as! UIButton
        let comment = cell.viewWithTag(16) as! UIButton
//        let report = cell.viewWithTag(17) as! UIButton

        
//        avatar.image = UIImage(named: <#T##String#>)
        username.text = checkIn.valueForKey("uid")!.valueForKey("username") as? String
        time.text = timeStringForMessage(checkIn.valueForKey("createdAt") as! NSDate)
        content.text = checkIn.valueForKey("content") as? String
//        content.sizeToFit()
        likeButton = showLikeButton(checkIn, button: likeButton, indexPath: indexPath, mark: markForCurrentUserLikeCheck)
        if let commentCount = checkIn.valueForKey("commentCount") {
            comment.setTitle("评论 \(commentCount as! Int)", forState: .Normal)

        }
        
        
        
        //头像缩略图
        if checkIn.valueForKey("uid")!.valueForKey("image") != nil {
            var urlString = checkIn.valueForKey("uid")!.valueForKey("image")?.valueForKey("url") as! String
            urlString = urlString + "?imageView/1/w/200/h/200"
//            print(urlString)
            let url = NSURL(string: urlString)
            avatarView.af_setImageWithURL(url!)
            print(avatarView)
        }else {
//            print("no")
        }
        
        //checkIn插图
        var urlString = ""
        imageView.image = nil
        if checkIn.valueForKey("image") != nil {
//            print(checkIn.valueForKey("image")?.valueForKey("url") as! String)
            urlString = checkIn.valueForKey("image")?.valueForKey("url") as! String
            let url = NSURL(string: urlString)
            imageView.af_setImageWithURL(url!)
            
            //处理图片加载错乱问题
            let updateCell = tableView.cellForRowAtIndexPath(indexPath)
            if ((updateCell) != nil) {
                updateCell?.imageView?.image = imageView.image
            }
            
            
//            print(imageView.image)
//            print(imageView.image?.size.height)
//            print(imageView.image?.size.width)
//            print(imageView.frame.size.height )
//            print(imageView.frame.size.width )
        
//            if imageView.image?.size.height != nil {
//                print("image is not nil ")
//                print(imageView.image?.size.height)
//                print(imageView.image?.size.width)
//            }

//            let test = UIImageView()
//            cell.addSubview(test)
//            test.frame = CGRectMake(13, 40, 100, 100)
//            test.af_setImageWithURL(url!)
            
            
//            let ratio = ((imageView.image?.size.height)! as CGFloat) / ((imageView.image?.size.width)! as CGFloat)
//            let imageViewWidth = imageView.frame.size.width as CGFloat
//            let imageViewHeight = imageViewWidth * ratio
//
            
            //重新设置高度限制
//            let test = imageView.constraints
//            print(test)
//            for i in test {
//                imageView.removeConstraint(i)
//            }
//            cell.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal,
//                toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:100))
//            print(imageView.frame.size.height   )

//            imageView.hidden = true
//            imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y
//                ,imageView.frame.size.width
//                ,0)
//            print(imageView.frame.size.height)
            
//
//            let s = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) //重新计算view内所有元素的高度
//            print(s.height)
//            cell.frame.size.height = s.height  //刷新headview的高度
//        
        }
        else {
            print("no")
//            imageView.frame.size.height = 200
//                imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y
//                ,imageView.frame.size.width
//                ,0)
//            print(imageView.frame.size.height)
            
        }
        
        
     return cell
        
    }
    

    func  getImageByHaneke() {
//        let cache = Share
    }


}
