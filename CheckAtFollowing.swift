//
//  CheckAtFollowing.swift
//  crowingApp
//
//  Created by a a a a a on 15/8/29.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import Foundation
import CoreData

class CheckAtFollowing: NSManagedObject {

    @NSManaged var content: String
    @NSManaged var dbID: NSNumber
    @NSManaged var remindTitle: String
    @NSManaged var uid: NSNumber
    @NSManaged var userID: NSNumber
    @NSManaged var userImage: NSData
    @NSManaged var userName: String

}
