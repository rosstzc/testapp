//
//  RemindMessage+CoreDataProperties.swift
//  crowingApp
//
//  Created by michaeltam on 15/10/12.
//  Copyright © 2015年 mike公司. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension RemindMessage {

    @NSManaged var content: String?
    @NSManaged var remindId: String?
    @NSManaged var state: NSNumber?
    @NSManaged var timeRemind: NSDate?
    @NSManaged var title: String?
    @NSManaged var uid: String?

}
