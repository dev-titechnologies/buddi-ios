//
//  BookingHistoryDB+CoreDataClass.swift
//
//
//  Created by Jithesh Xavier on 19/07/17.
//
//

import Foundation
import CoreData
import UIKit

@objc(BookingHistoryDB)
public class BookingHistoryDB: NSManagedObject {
    
    class func createBookingEntry(bookingModel: BookingHistoryModel) {
        
        print("*** Booking ID:",bookingModel.bookingId)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookingHistoryDB")
        fetchRequest.predicate = NSPredicate(format: "bookingId == %@", bookingModel.bookingId)
    
        do {
            let bookings = try context.fetch(fetchRequest)
            
            if bookings.count > 0 {
                print("Booking entry present")
                let booking = bookings[0] as! NSManagedObject
                
                booking.setValue(bookingModel.rating, forKey: "rating")
                booking.setValue(bookingModel.trainedDate, forKey: "bookedDate")
                booking.setValue(bookingModel.bookingId, forKey: "bookingId")
                booking.setValue(bookingModel.category, forKey: "category")
                booking.setValue(bookingModel.location, forKey: "location")
                booking.setValue(bookingModel.paymentStatus, forKey: "paymentStatus")
                booking.setValue(bookingModel.traineeId, forKey: "traineeId")
                booking.setValue(bookingModel.traineeName, forKey: "traineeName")
                booking.setValue(bookingModel.trainerId, forKey: "trainerId")
                booking.setValue(bookingModel.trainerName, forKey: "trainerName")
                booking.setValue(bookingModel.trainingStatus, forKey: "trainingStatus")

                appDelegate.saveContext()
            }else{
                print("Booking entry not present")
                let booking = NSEntityDescription.insertNewObject(forEntityName: "BookingHistoryDB", into:context) as! BookingHistoryDB

                //Need to Convert String to Date
                booking.bookedDate = bookingModel.trainedDate as NSDate
                booking.bookingId = bookingModel.bookingId
                booking.category = bookingModel.category
                booking.location = bookingModel.location
                booking.paymentStatus = bookingModel.paymentStatus
                booking.traineeId = bookingModel.traineeId
                booking.traineeName = bookingModel.traineeName
                booking.trainerId = bookingModel.trainerId
                booking.trainerName = bookingModel.trainerName
                booking.trainingStatus = bookingModel.trainingStatus

                appDelegate.saveContext()
            }
            
        }catch {
            fatalError("Failed to create Booking Entry: \(error)")
        }
        
    }
}
