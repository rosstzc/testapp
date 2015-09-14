//
//  RemindMessage.swift
//  crowingApp
//
//  Created by a a a a a on 15/9/13.
//  Copyright (c) 2015年 mike公司. All rights reserved.
//

import Foundation
import CoreData

class RemindMessage: NSManagedObject {

    @NSManaged var content: String
    @NSManaged var time_remind: NSDate
    @NSManaged var title: String
    @NSManaged var state: NSNumber   //0.not read, 1.readed, 2.delete

}
