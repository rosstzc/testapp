//
//  User.swift
//  crowingApp
//
//  Created by a a a a a on 15/9/24.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var email: String
    @NSManaged var name: String
    @NSManaged var online: NSNumber
    @NSManaged var password: String
    @NSManaged var rr: NSNumber

}
