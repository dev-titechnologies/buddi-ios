//
//  ReviewHistoryModel.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation

class ReviewHistoryModel {
    
    var reviewId : String = String()
    var traineeId : String = String()
    var traineeName : String = String()
    var reviewDescription : String = String()
    var reviewDate : Date = Date()
    var starRatingValue : String = String()
    var category : String = String()
    var trainerId : String = String()
    var trainerName : String = String()

    init(){}
    
    init(traineeId: String, traineeName: String, reviewDescription: String, reviewDate: Date, starRatingValue: String, category: String,reviewId: String, trainerId: String, trainerName: String){
        
        self.reviewId = reviewId
        self.traineeId = traineeId
        self.traineeName = traineeName
        self.reviewDescription = reviewDescription
        self.reviewDate = reviewDate
        self.starRatingValue = starRatingValue
        self.category = category
        self.trainerId = trainerId
        self.trainerName = trainerName

    }

    func getReviewHistoryModelFromDict(dictionary: Dictionary<String, Any>) -> ReviewHistoryModel {
        
        let model: ReviewHistoryModel = ReviewHistoryModel()
        let trainedDate = CommonMethods.getDateFromString(dateString: dictionary["review_date"] as! String)
        let categoryName = CategoryDB.getCategoryByCategoryID(categoryId: String(describing: dictionary["category"]!))
        
        model.reviewId = String(describing: dictionary["review_id"]!)
        model.traineeId = String(describing: dictionary["trainee_id"]!)
        model.traineeName = dictionary["trainee_name"] as! String
        model.reviewDescription = dictionary["review_desc"] as! String
        model.reviewDate = trainedDate
        model.starRatingValue = String(describing: dictionary["rating_count"]!)
        model.category = categoryName
        model.trainerId = String(describing: dictionary["trainer_id"]!)
        model.trainerName = dictionary["trainer_name"] as! String
        
        return model
    }

}
