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
    
    let appDelegateObj = UIApplication.shared.delegate as! AppDelegate

    class func createBookingEntry(bookingModel: BookingHistoryModel) {

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookingHistoryDB")
        fetchRequest.predicate = NSPredicate(format: "bookingId == %@", bookingModel.bookingId)
        
        do {
            print("TEST DO")
            let alarms = try context.fetch(fetchRequest)
//            if alarms.count > 0 {
//                
//                let alarm = alarms[0] as! NSManagedObject
//                alarm.setValue(title, forKey: "title")
//                alarm.setValue(date, forKey: "date")
//                alarm.setValue(enabled, forKey: "enabled")
//                alarm.setValue(repeatdays, forKey: "repeatdays")
//                alarm.setValue(repeatdayslabel, forKey: "repeatDaysLabel")
//                alarm.setValue(tone, forKey: "tone")
//                
//                appDelegate.saveContext()
            
            }else{
                print("TEST ELSE")
//                let alarm = NSEntityDescription.insertNewObject(forEntityName: "AlarmDB", into:context) as! AlarmDB
//                
//                alarm.title = title
//                alarm.date = date
//                alarm.enabled = enabled
//                alarm.repeatdays = repeatdays
//                alarm.uuid = uuid
//                alarm.repeatDaysLabel = repeatdayslabel
//                alarm.tone = tone
//                
//                appDelegate.saveContext()
//            }
        
        }catch {
            fatalError("Failed to create Alarms: \(error)")
        }

    }
}
