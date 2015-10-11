//
//  Remind+CoreDataProperties.swift
//  crowingApp
//
//  Created by michaeltam on 15/10/11.
//  Copyright © 2015年 mike公司. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Remind {

    @NSManaged var content: String?
    @NSManaged var remindId: String?
    @NSManaged var remindTime: NSDate?
    @NSManaged var repeatType: String?
    @NSManaged var schedule: String?
    @NSManaged var title: String?
    @NSManaged var uid: String?
    

}
