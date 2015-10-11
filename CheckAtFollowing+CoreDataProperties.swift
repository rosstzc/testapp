//
//  CheckAtFollowing+CoreDataProperties.swift
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

extension CheckAtFollowing {

    @NSManaged var content: String?
    @NSManaged var dbId: String?
    @NSManaged var remindTitle: String?
    @NSManaged var uid: String?
    @NSManaged var userId: String?
    @NSManaged var userImage: NSData?
    @NSManaged var userName: String?

}
