//
//  PromoCodeDB+CoreDataProperties.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/01/18.
//  Copyright © 2018 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData


extension PromoCodeDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PromoCodeDB> {
        return NSFetchRequest<PromoCodeDB>(entityName: "PromoCodeDB")
    }

    @NSManaged public var codeId: String?
    @NSManaged public var codeLimit: String?
    @NSManaged public var codeDescription: String?
    @NSManaged public var expiryDate: NSDate?

}
