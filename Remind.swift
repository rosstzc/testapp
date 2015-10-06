//
//  Remind.swift
//  crowingApp
//
//  Created by a a a a a on 15/9/24.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import Foundation
import CoreData

class Remind: NSManagedObject {

    @NSManaged var content: String
    @NSManaged var dbid: NSNumber
    @NSManaged var remind_id: String
    @NSManaged var remind_time: NSDate
    @NSManaged var repeat_type: String
    @NSManaged var schedule: String
    @NSManaged var title: String
    @NSManaged var uid: NSNumber

}
