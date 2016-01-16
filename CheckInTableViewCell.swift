//
//  CheckInTableViewCell.swift
//  crowingApp
//
//  Created by michaeltam on 16/1/16.
//  Copyright © 2016年 mike公司. All rights reserved.
//

import UIKit

@IBDesignable class CheckInTableViewCell: UITableViewCell {

    @IBOutlet weak var imageCheckInHeight: NSLayoutConstraint!
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var content: UITextView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var comment: UIButton!
    
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
//    @IBAction func likeCheckIn(sender: AnyObject) {
//        
//        print("333")
//    }
//    
    func  likeCheckIntemp(sender:AnyObject) {
        print("33366")
        
    }

}
