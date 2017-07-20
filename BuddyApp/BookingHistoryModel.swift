//
//  BookingHistoryModel.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation

class BookingHistoryModel {
    
    var bookingId: String = String()
    var traineeId: String = String()
    var trainerId: String = String()
    var trainerName: String = String()
    var traineeName: String = String()
    var trainingStatus: String = String()
    var paymentStatus: String = String()
    var trainedDate: String = String()
    var category: String = String()
    var location: String = String()

    init(){}
    
//    init(bookingId: String, traineeId: String, trainerId: String, trainingStatus: String, paymentStatus: String, trainedDate: String, category: String,traineeName: String, trainerName: String, location: String){
//        
//        self.bookingId = bookingId
//        self.traineeId = traineeId
//        self.trainerId = trainerId
//        self.trainingStatus = trainingStatus
//        self.paymentStatus = paymentStatus
//        self.trainedDate = trainedDate
//        self.category = category
//        self.traineeName = traineeName
//        self.trainerName = trainerName
//        self.location = location
//    }
    
    func getBookingHistoryModelFromDict(dictionary: Dictionary<String, Any>) -> BookingHistoryModel {
        
        let model: BookingHistoryModel = BookingHistoryModel()
        
        model.bookingId = dictionary["bookingId"] as! String
        model.trainerId = dictionary["trainerId"] as! String
        model.trainedDate = dictionary["trainedDate"] as! String
        model.category = dictionary["category"] as! String
        model.paymentStatus = dictionary["paymentStatus"] as! String
        model.trainingStatus = dictionary["trainingStatus"] as! String
        model.traineeId = dictionary["traineeId"] as! String
        model.traineeName = dictionary["traineeName"] as! String
        model.trainerName = dictionary["trainerName"] as! String
        model.location = dictionary["location"] as! String

        return model
    }
    
}
