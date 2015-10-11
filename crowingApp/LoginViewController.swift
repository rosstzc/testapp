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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        
        //
        let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let request =  NSFetchRequest(entityName: "User")
        var tempp:[User] = []
        tempp = (try! context.executeFetchRequest(request)) as! [User]
        print("user count：",  tempp.count)
        for i in tempp {
            print("name",i.name ," email",i.email, " pwd", i.password)
            
        // 当用户已登录，即跳到首页
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
        
        // 把注册信息写到 NSUserDefaults
            //待完善？ 这里应该有网络部分，并且上面写coredata是没有用户的
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let uuid = NSUUID().UUIDString
        userDefaults.setObject(uuid, forKey: "uid")
        userDefaults.setObject(txtName.text, forKey: "name")
        userDefaults.setObject(txtMail.text, forKey: "email")
        userDefaults.setObject(txtPwd.text, forKey: "password")
        userDefaults.setBool(true, forKey:"logined")
        userDefaults.setBool(true, forKey:"fristLaunch") //引导界面完成后设为false
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
      
        self.performSegueWithIdentifier("segueLogin", sender: self)

        
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
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
