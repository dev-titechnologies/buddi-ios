//
//  CategoryDB+CoreDataProperties.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 20/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData


extension CategoryDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryDB> {
        return NSFetchRequest<CategoryDB>(entityName: "CategoryDB")
    }

    @NSManaged public var categoryId: String?
    @NSManaged public var categoryName: String?
    @NSManaged public var categoryDesc: String?
    @NSManaged public var categoryImage: String?

}
