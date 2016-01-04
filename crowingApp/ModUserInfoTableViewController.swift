//
//  ModUserInfoTableViewController.swift
//  keenbrace
//
//  Created by michaeltam on 15/10/15.
//  Copyright © 2015年 mike公司. All rights reserved.
//

import UIKit
//import ActionSheetPicker_3_0


class ModUserInfoTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate{
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var genderText: UITextField!
    @IBOutlet weak var heightText: UITextField!
    @IBOutlet weak var weightText: UITextField!
    @IBOutlet weak var birthText: UITextField!
    @IBOutlet weak var introduceTextView: UITextView!
    
    @IBOutlet  var genderPicker:UIPickerView! = UIPickerView()
    @IBOutlet  var heightPicker:UIPickerView! = UIPickerView()
    @IBOutlet  var weightPicker:UIPickerView! = UIPickerView()
    @IBOutlet  var birthPicker:UIDatePicker! = UIDatePicker()
    
    
    
    
    var user = NSUserDefaults.standardUserDefaults()
    
    var genderSelection = ["男", "女", "不限"]
    var heightSelection = ["100"]
    var weightSelection = ["20"]
    
    @IBOutlet weak var avatar: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        genderPicker.delegate = self
        genderPicker.dataSource = self
        self.genderText.inputView = genderPicker
        
        heightPicker.delegate = self
        heightPicker.dataSource = self
        self.heightText.inputView = heightPicker
        
        weightPicker.delegate = self
        weightPicker.dataSource = self
        self.weightText.inputView = weightPicker
        
        weightPicker.delegate = self
        weightPicker.dataSource = self
        
        
        self.birthText.inputView = self.birthPicker
        
        
        
        
        name.text = user.valueForKey("name") as? String
        //        var row = user.valueForKey("gender") as? NSInteger
        
        
        //身高
        var i:Int = 100
        while i < 240 {
            i = i + 1
            heightSelection.append(String(i))
        }
        let height = user.valueForKey("height") as? String
        heightText.text = (height)! + "cm"
        
        //体重
        i = 20
        while i < 200 {
            i = i + 1
            weightSelection.append(String(i))
        }
        let weight = user.valueForKey("weight") as? String
        weightText.text = (weight)! + "kg"
        
        genderText.text = user.valueForKey("gender") as? String
        
        if (user.valueForKey("avatar") != nil) {
            avatar.image = UIImage(data: user.valueForKey("avatar") as! NSData, scale: 1.0)
        }
        
        
        //生日
        birthText.text = user.valueForKey("birth") as? String
        birthPicker.datePickerMode = UIDatePickerMode.Date
        birthPicker.addTarget(self, action: "changeText", forControlEvents: UIControlEvents.ValueChanged)
        
        introduceTextView.text = user.valueForKey("introduce") as? String
        //        introduceTextView.text = "444"
        
        // 初始化picker，让默认值与userDefault一致
        var row:Int
        if height != "" {
            row = heightSelection.indexOf(height!)!
            heightPicker.selectRow(row, inComponent: 0, animated: true)
        }
        if weight != "" {
            row = weightSelection.indexOf(weight!)!
            weightPicker.selectRow(row, inComponent: 0, animated: true)
        }
        if genderText.text != "" {
            row = genderSelection.indexOf(genderText.text!)!
            genderPicker.selectRow(row, inComponent: 0, animated: true)
        }
        
        if birthText.text != "" {
            let date = dateFromString(birthText.text!)
            birthPicker.setDate(date, animated: true)
        }
        
    }
    
    
    
    func changeText() {
        birthText.text = stringFromDate(birthPicker.date)
        
    }
    
    
    //
    //    //触发生日text的datePicker
    //    @IBAction func dp(sender: UITextField) {
    //
    //        birthPicker.datePickerMode = UIDatePickerMode.Date
    //        sender.inputView = birthPicker
    //        birthPicker.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
    //    }
    //
    //    func handleDatePicker(sender: UIDatePicker) {
    //        let dateFormatter = NSDateFormatter()
    //        dateFormatter.dateFormat = "yyyy年MM月dd日"
    //        birthText.text = dateFormatter.stringFromDate(sender.date)
    //    }
    
    
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        name.resignFirstResponder()
        genderText.resignFirstResponder()
        heightText.resignFirstResponder()
        weightText.resignFirstResponder()
        birthText.resignFirstResponder()
        introduceTextView.resignFirstResponder()
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        //        var temp:AnyObject
        if pickerView.isEqual(genderPicker) {
            return genderSelection.count
        }
        if pickerView.isEqual(heightPicker) {
            return heightSelection.count
            
        }
        if pickerView.isEqual(weightPicker) {
            return weightSelection.count
        }
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        if pickerView.isEqual(genderPicker) {
            return genderSelection[row]
        }
        if pickerView.isEqual(heightPicker) {
            return heightSelection[row]
            
        }
        if pickerView.isEqual(weightPicker) {
            return weightSelection[row]
        }
        return ""
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.isEqual(genderPicker) {
            genderText.text = genderSelection[row]
        }
        if pickerView.isEqual(heightPicker) {
            heightText.text = heightSelection[row] + "cm"
        }
        if pickerView.isEqual(weightPicker) {
            weightText.text = weightSelection[row] + "kg"
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            
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
        avatar.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    //    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    //
    //    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        // #warning Incomplete implementation, return the number of rows
    //        return 0
    //    }
    
    @IBAction func save(sender: AnyObject) {
        
        user.setObject(name.text, forKey: "name")
        user.setObject(genderText.text, forKey:"gender")
        
        //保存前删除单位字符
        heightText.text = deleteCharacter(heightText.text!)
        weightText.text = deleteCharacter(weightText.text!)
        
        user.setObject(heightText.text, forKey: "height")
        user.setObject(weightText.text, forKey: "weight")
        
        user.setObject(birthText.text, forKey: "birth")
        user.setObject(introduceTextView.text, forKey: "introduce")
        
        
        if (avatar.image != nil) {
            //            let temp = UIImagePNGRepresentation(avatar.image!) //
            let temp = UIImageJPEGRepresentation(avatar.image!, 95)
            print("save image")
            user.setObject(temp, forKey: "avatar")
            
        }
        
        
        //        user.setObject(introduction.text, forKey: "introduction")
        user.synchronize()
        
        //        print(user.valueForKey("avatar") as! UIImage)
        //        self.performSegueWithIdentifier("testt", sender: self)
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    func deleteCharacter(var text:String) -> String {
        text = text.stringByReplacingOccurrencesOfString("c", withString: "", options:  NSStringCompareOptions.LiteralSearch, range: nil)
        text = text.stringByReplacingOccurrencesOfString("m", withString: "", options:  NSStringCompareOptions.LiteralSearch, range: nil)
        text = text.stringByReplacingOccurrencesOfString("kg", withString: "", options:  NSStringCompareOptions.LiteralSearch, range: nil)
        print(text)
        return text
    }
    
    
    
    @IBAction func cancel(sender: AnyObject) {
        
        print("")
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
        
    }
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
    
    // Configure the cell...
    
    return cell
    }
    */
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}


