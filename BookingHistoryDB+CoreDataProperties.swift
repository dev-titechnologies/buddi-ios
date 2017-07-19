//
//  BookingHistoryDB+CoreDataProperties.swift
//  
//
//  Created by Jithesh Xavier on 19/07/17.
//
//

import Foundation
import CoreData


extension BookingHistoryDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookingHistoryDB> {
        return NSFetchRequest<BookingHistoryDB>(entityName: "BookingHistoryDB")
    }

    @NSManaged public var bookedDate: NSDate?
    @NSManaged public var bookingId: String?
    @NSManaged public var category: String?
    @NSManaged public var location: String?
    @NSManaged public var paymentStatus: String?
    @NSManaged public var traineeId: String?
    @NSManaged public var traineeName: String?
    @NSManaged public var trainerId: String?
    @NSManaged public var trainerName: String?
    @NSManaged public var trainingStatus: String?

}
