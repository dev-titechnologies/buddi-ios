//
//  ReviewHistoryModel.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation

class ReviewHistoryModel {
    
    var traineeId : String = String()
    var traineeName : String = String()
    var reviewDescription : String = String()
    var reviewDate : String = String()
    var starRatingValue : String = String()
    var category : String = String()

    init(){}
    
    init(traineeId: String, traineeName: String, reviewDescription: String, reviewDate: String, starRatingValue: String, category: String){
        
        self.traineeId = traineeId
        self.traineeName = traineeName
        self.reviewDescription = reviewDescription
        self.reviewDate = reviewDate
        self.starRatingValue = starRatingValue
        self.category = category
    }


    func getReviewHistoryModelFromDict(dictionary: Dictionary<String, Any>) -> ReviewHistoryModel {
        
        let model: ReviewHistoryModel = ReviewHistoryModel()
        
        print("111",dictionary)
        print(dictionary["traineeId"] as! String)
        
        model.traineeId = dictionary["traineeId"] as! String
        model.traineeName = dictionary["traineeName"] as! String
        model.reviewDescription = dictionary["reviewDesc"] as! String
        model.reviewDate = dictionary["reviewDate"] as! String
        model.starRatingValue = dictionary["starRatingValue"] as! String
        model.category = dictionary["category"] as! String
        
        return model
    }

}
