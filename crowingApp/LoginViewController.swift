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

        // Do any additional setup after loading the view.
        
        //
        let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let request =  NSFetchRequest(entityName: "User")
        var tempp:[User] = []
        tempp = (try! context.executeFetchRequest(request)) as! [User]
        print("user count：",  tempp.count)
        for i in tempp {
            print("name",i.name ," email",i.email, " pwd", i.password)
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
        
        
        //通过查询刚才是否增加了一个用户
        let request =  NSFetchRequest(entityName: "User")
        var tempp:[User] = []
        tempp = (try! context.executeFetchRequest(request)) as! [User]
        print("user count：",  tempp.count)
      
        
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
