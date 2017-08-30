//
//  BookingHistoryModel.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation

class BookingHistoryModel {
    
    var rating: String = String()
    var bookingId: String = String()
    var traineeId: String = String()
    var trainerId: String = String()
    var trainerName: String = String()
    var traineeName: String = String()
    var trainingStatus: String = String()
    var paymentStatus: String = String()
    var trainedDate: Date = Date()
    var category: String = String()
    var location: String = String()
    var trainerImage: String = String()
    var amount : String = String()
    var categoryImage : String = String()

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
        let trainedDate = CommonMethods.getDateFromString(dateString: dictionary["trained_date"] as! String)
//        let categoryName = CategoryDB.getCategoryByCategoryID(categoryId: String(describing: dictionary["category"]!))
        
        let categArray = dictionary["category"] as! NSArray as Array
        let categoryName = categArray[0]["categoryName"] as! String
        let categoryImage = categArray[0]["categoryBookImage"] as! String
        print(categoryName)
        
        model.bookingId = String(describing: dictionary["booking_id"]!)
        model.trainerId = String(describing: dictionary["trainer_id"]!)
        model.trainedDate = trainedDate
        model.category = categoryName
        model.rating = CommonMethods.checkStringNull(val: String(describing: dictionary["rating"]!))
        
        model.paymentStatus = dictionary["payment_status"] as! String
        model.trainingStatus = dictionary["training_status"] as! String
        model.traineeId = String(describing: dictionary["trainee_id"]!)
        model.traineeName = dictionary["trainee_name"] as! String
        model.trainerName = dictionary["trainer_name"] as! String
        model.location = dictionary["location"] as! String
        model.amount = dictionary["amount"] as! String
        model.categoryImage = categoryImage
        
        return model
    }
    
}
