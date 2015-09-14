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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textContent.delegate = self
        self.textTitle.delegate = self
        // Do any additional setup after loading the view.
    }



    @IBAction func tappedSave(sender: AnyObject) {
        saveCoreData(textTitle.text, content: textContent.text)
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    @IBAction func tappedCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    func saveCoreData(title: String, content: String ) {
        var  context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        var remind = NSEntityDescription.insertNewObjectForEntityForName("Remind",inManagedObjectContext: context) as! Remind
        remind.title = title
        remind.content = content
        context.save(nil)
        
    }

    
    
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
    
}
