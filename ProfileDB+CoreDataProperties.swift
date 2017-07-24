//
//  ProfileDB+CoreDataProperties.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 19/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData


extension ProfileDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfileDB> {
        return NSFetchRequest<ProfileDB>(entityName: "ProfileDB")
    }

    @NSManaged public var userId: String?
    @NSManaged public var email: String?
    @NSManaged public var gender: String?
    @NSManaged public var mobile: String?
    @NSManaged public var firstname: String?
     @NSManaged public var lastname: String?
     @NSManaged public var profile_desc: String?
    @NSManaged public var profileImageData: NSData?
    @NSManaged public var profileImageURL: String?

}
