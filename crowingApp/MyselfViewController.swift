//
//  MyselfViewController.swift
//  crowingApp
//
//  Created by a a a a a on 15/9/3.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import UIKit

class MyselfViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelUserName: UILabel!
    let userDefaults = NSUserDefaults.standardUserDefaults()


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        labelUserName.text = userDefaults.valueForKey("email") as? String

        // Do any additional setup after loading the view.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
        
    }

    

    @IBAction func btnLogout(sender: AnyObject) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(false, forKey:"logined")
        
        userDefaults.setObject("", forKey: "uid")
        userDefaults.setObject("", forKey: "name")
        userDefaults.setObject("", forKey: "email")
        userDefaults.setObject("", forKey: "password")
        userDefaults.setBool(false, forKey:"fristLaunch") //引导界面完成后设为false
        userDefaults.synchronize()
        
        
        userDefaults.synchronize()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewControllerWithIdentifier("login") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)

    }
    
    

}
