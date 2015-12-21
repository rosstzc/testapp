//
//  LoginViewController.swift
//  crowingApp
//
//  Created by a a a a a on 15/9/23.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
    var users:[User] = []

    
    @IBOutlet weak var txtName: UITextField!
    
    @IBOutlet weak var txtMail: UITextField!

    @IBOutlet weak var txtPwd: UITextField!
    let userDefaults = NSUserDefaults.standardUserDefaults()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        

        let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let request =  NSFetchRequest(entityName: "User")
        var tempp:[User] = []
        tempp = (try! context.executeFetchRequest(request)) as! [User]
        print("user count：",  tempp.count)
        for i in tempp {
            print("name",i.name ," email",i.email, " pwd", i.password)
            
        // 上面代码只是用户检查有多少个用户
        }


        
    }
    
    
    
    @IBAction func btnReg(sender: AnyObject) {
        
        let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let user = NSEntityDescription.insertNewObjectForEntityForName("User",inManagedObjectContext: context) as! User
        user.name = txtName.text!
        user.email = txtMail.text!
        user.password = txtPwd.text!
        do {
            //        user.online = false
            try context.save()
        } catch _ {
        }
        
        //到LeanCloud注册
        let userLC = AVUser()
        userLC.email = txtMail.text!
        userLC.username = txtMail.text!
        userLC.password = txtPwd.text!
        userLC.setObject(txtName.text!, forKey: "nickName")
        userLC.signUpInBackgroundWithBlock({(succeeded:Bool, error:NSError?) in
            if (error == nil ) {
                let currentUser = AVUser.currentUser()
                if currentUser != nil {
                    self.performSegueWithIdentifier("segueLogin", sender: self)
                }
            } else  {
            print(error)
            print(error?.code)
                if (error?.code == 125) {
                    //email地址错误
                    
                }
                if (error?.code == 203) {
                    //email已经被占用
                    print("email已被占用")
                    
                }


            }
        })
        
        
        // 考虑使用匿名用户，让用户首次登录
        
        
        
        
        // 把注册信息写到 NSUserDefaults
            //待完善？ 这里应该有网络部分，并且上面写coredata是没有用户的
        let uuid = NSUUID().UUIDString
        let userDict:NSDictionary = ["uid":uuid, "name":txtName.text!, "email":txtMail.text!, "password":txtPwd.text!]
//        userDict.setValue(uuid, forKey: "uid")
        
        userDefaults.setObject(uuid, forKey: "uid")
        userDefaults.setObject(txtName.text, forKey: "name")
        userDefaults.setObject(txtMail.text, forKey: "email")
        userDefaults.setObject(txtPwd.text, forKey: "password")
        userDefaults.setBool(true, forKey:"logined")
        userDefaults.setBool(true, forKey:"fristLaunch") //引导界面完成后设为false
        userDefaults.setObject(userDict, forKey: "\(txtMail.text!)") //用字典把数据保存下来
        
        userDefaults.synchronize()
        
        //测试读取userDefault
        let tst = NSUserDefaults.standardUserDefaults()
        print("read userDefault",tst.valueForKey("name"))
        print("uuid",tst.valueForKey("uid"))
        
        
        //通过查询刚才是否增加了一个用户
        let request =  NSFetchRequest(entityName: "User")
        var tempp:[User] = []
        tempp = (try! context.executeFetchRequest(request)) as! [User]
        print("user count：",  tempp.count)
      
//        self.performSegueWithIdentifier("segueLogin", sender: self)

        
    }
    
    

    @IBAction func btnLogin(sender: AnyObject) {
        let email = txtMail.text
        let passsword = txtPwd.text
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let filter:NSPredicate = NSPredicate(format: " email = %@ && password = %@", email!, passsword!)
        let request =  NSFetchRequest(entityName: "User")
        request.predicate = filter
        var temp:[User] = []
        temp = (try! context.executeFetchRequest(request)) as! [User]
        if temp.count > 0 {
            print("yes")
            for i in temp {
                print("name",i.name ," email",i.email, " pwd", i.password)
                
                let userDict = userDefaults.valueForKey("\(txtMail.text!)")
                
                userDefaults.setObject(userDict?.valueForKey("uid"), forKey: "uid")
                userDefaults.setObject(userDict?.valueForKey("name"), forKey: "name")
                userDefaults.setObject(userDict?.valueForKey("email"), forKey: "email")
                userDefaults.setObject(userDict?.valueForKey("password"), forKey: "password")
                userDefaults.setBool(true, forKey:"logined")
                userDefaults.synchronize()

                self.performSegueWithIdentifier("segueLogin", sender: self)
            }
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        let user = NSUserDefaults.standardUserDefaults()
        print(user.valueForKey("logined"))
        
        if user.valueForKey("logined") as? Bool == true {
        
        print("555")

            
        }
    }
    

    
    
//    //登录成功
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "segueLogin" {
//            let nextVC = segue.destinationViewController as! RemindListViewController
//            
//        }
//        
//    }
    
    
    //for leanCloud
    func filterError(error: NSError?) -> Bool{
        if error != nil {
            print("%@", error!)
            return false
        } else {
            return true
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
