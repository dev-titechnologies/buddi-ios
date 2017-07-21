//
//  SubCategoryDB+CoreDataProperties.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 21/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData


extension SubCategoryDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubCategoryDB> {
        return NSFetchRequest<SubCategoryDB>(entityName: "SubCategoryDB")
    }

    @NSManaged public var subCategoryId: String?
    @NSManaged public var subCategoryName: String?

}
