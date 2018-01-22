//
//  BookingHistoryDB+CoreDataProperties.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 19/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData


extension BookingHistoryDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookingHistoryDB> {
        return NSFetchRequest<BookingHistoryDB>(entityName: "BookingHistoryDB")
    }

    @NSManaged public var rating: NSDate?
    @NSManaged public var bookedDate: NSDate?
    @NSManaged public var bookingId: String?
    @NSManaged public var promoCode: String?
    @NSManaged public var category: String?
    @NSManaged public var location: String?
    @NSManaged public var paymentStatus: String?
    @NSManaged public var traineeId: String?
    @NSManaged public var traineeName: String?
    @NSManaged public var trainerId: String?
    @NSManaged public var trainerName: String?
    @NSManaged public var trainingStatus: String?

}
