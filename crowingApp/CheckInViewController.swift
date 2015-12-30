//
//  CheckInViewController.swift
//  crowingApp
//
//  Created by michaeltam on 15/12/29.
//  Copyright © 2015年 mike公司. All rights reserved.
//

import UIKit
import CoreData


class CheckInViewController: UIViewController,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIAlertViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoOutlet: UIButton!
    @IBOutlet weak var content: UITextView!
    
    var imageUpload:UIImage? = nil
    var remindId = ""
    var remindTitle = ""
    var user = NSUserDefaults.standardUserDefaults()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.content.delegate = self
        content.text = "#\(remindTitle)#打卡"

        imageView.image = UIImage(named: "fangbingbing")  //默认icon
    }
    
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "segueSave" {
            //如果未选择时间，或者标题为空，就阻止segue跳转
            let checkIn = AVObject(className: "CheckIn")
            let remind = AVObject(withoutDataWithClassName: "Remind", objectId: remindId)
            let currentUser = AVUser.currentUser()
            

            checkIn.setObject(content.text, forKey: "content")
            checkIn.setObject(currentUser, forKey: "uid")
            checkIn.setObject(remind, forKey: "rid")
            if imageUpload != nil  {
                let fileData = saveImageToLC(imageUpload!)
                checkIn.setObject(fileData, forKey: "image")
            }
            
            if content.text != "" || imageUpload != nil {
                checkIn.saveInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
                    if (error != nil) {
                        print(error)
                    } else {
                        remind.incrementKey("checks")
                        remind.saveInBackground()
                        //同步时间线
                        sendStatus("checkIn", index: checkIn.objectId)
                    }
                    
                    
                })
            }
        }
        
        
        if identifier == "segueCancel" {
            //如果未选择时间，或者标题为空，就阻止segue跳转
            

                    }
        return true
    }
    
    
    

    
    
    
    @IBAction func addPhotoAction(sender: AnyObject) {
        
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
        
        imageView.image = image
        imageUpload = image
        picker.dismissViewControllerAnimated(true, completion: nil)
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
