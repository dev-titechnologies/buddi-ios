//
//  ReviewHistoryDB+CoreDataProperties.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 19/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData


extension ReviewHistoryDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReviewHistoryDB> {
        return NSFetchRequest<ReviewHistoryDB>(entityName: "ReviewHistoryDB")
    }

    @NSManaged public var category: String?
    @NSManaged public var reviewDate: NSDate?
    @NSManaged public var reviewDescription: String?
    @NSManaged public var reviewId: String?
    @NSManaged public var starRatingValue: String?
    @NSManaged public var traineeId: String?
    @NSManaged public var traineeName: String?
    @NSManaged public var trainerId: String?
    @NSManaged public var trainerName: String?
}
