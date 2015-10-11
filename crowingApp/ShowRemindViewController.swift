//
//  ShowRemindViewController.swift
//  crowingApp
//
//  Created by a a a a a on 15/8/29.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData

class ShowRemindViewController: UIViewController {

    @IBOutlet weak var remindTitle: UILabel!
    @IBOutlet weak var remindContent: UILabel!
    @IBOutlet weak var tappedFollow: UIButton!
   
    @IBOutlet weak var checkContent: UITextField!
    
    var remind:Remind? = nil
    var remindId:NSManagedObjectID!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        remindTitle.text = remind?.title
        remindContent.text = remind?.content
        
        
    }

    @IBAction func follow(sender: AnyObject) {
        

    }
    
    @IBAction func submit(sender: AnyObject) {
        //点按钮，触发写入 followAtRemind 表
        let  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let check = NSEntityDescription.insertNewObjectForEntityForName("CheckAtFollowing",inManagedObjectContext: context) as! CheckAtFollowing
        check.remindTitle = remindTitle.text!
        check.content = checkContent.text!
        check.userId = "2"
        check.userName = "mike"
        do {
            //        check.userImage =
            //        check.dbID =
            try context.save()
        } catch _ {
        }
        
        
    }
    
    //输入键盘屏蔽
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        checkContent.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        checkContent.resignFirstResponder()
    }


}
