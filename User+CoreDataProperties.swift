//
//  User+CoreDataProperties.swift
//  crowingApp
//
//  Created by michaeltam on 15/10/7.
//  Copyright © 2015年 mike公司. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var email: String?
    @NSManaged var name: String?
    @NSManaged var online: NSNumber?
    @NSManaged var password: String?
    @NSManaged var rr: NSNumber?

}
