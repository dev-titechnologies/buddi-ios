//
//  ProfileImageDB+CoreDataProperties.swift
//  BuddyApp
//
//  Created by Ti Technologies on 26/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData


extension ProfileImageDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfileImageDB> {
        return NSFetchRequest<ProfileImageDB>(entityName: "ProfileImageDB")
    }

    @NSManaged public var imageUrl: String?
    @NSManaged public var imageData: NSData?

}
