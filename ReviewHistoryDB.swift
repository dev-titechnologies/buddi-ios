//
//  ReviewHistoryDB+CoreDataClass.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 19/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

@objc(ReviewHistoryDB)
public class ReviewHistoryDB: NSManagedObject {

    class func createReviewEntry(reviewModel: ReviewHistoryModel) {
        
        print("*** Review ID:",reviewModel.reviewId)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ReviewHistoryDB")
        fetchRequest.predicate = NSPredicate(format: "reviewId == %@", reviewModel.reviewId)
        
        do {
            let reviews = try context.fetch(fetchRequest)
            
            if reviews.count > 0 {
                print("Review entry present")
                let review = reviews[0] as! NSManagedObject
                
                review.setValue(reviewModel.reviewId, forKey: "reviewId")
                review.setValue(reviewModel.category, forKey: "category")
                review.setValue(reviewModel.reviewDate, forKey: "reviewDate")
                review.setValue(reviewModel.reviewDescription, forKey: "reviewDescription")
                review.setValue(reviewModel.starRatingValue, forKey: "starRatingValue")
                review.setValue(reviewModel.traineeId, forKey: "traineeId")
                review.setValue(reviewModel.traineeName, forKey: "traineeName")
                review.setValue(reviewModel.trainerId, forKey: "trainerId")
                review.setValue(reviewModel.trainerName, forKey: "trainerName")
                
                appDelegate.saveContext()
            }else{
                print("Review entry not present")
                let review = NSEntityDescription.insertNewObject(forEntityName: "ReviewHistoryDB", into:context) as! ReviewHistoryDB
                
                review.reviewId = reviewModel.reviewId
                review.category = reviewModel.category
                review.reviewDate = reviewModel.reviewDate
                review.reviewDescription = reviewModel.reviewDescription
                review.starRatingValue = reviewModel.starRatingValue
                review.traineeId = reviewModel.traineeId
                review.traineeName = reviewModel.traineeName
                review.trainerId = reviewModel.trainerId
                review.trainerName = reviewModel.trainerName

                appDelegate.saveContext()
            }
            
        }catch {
            fatalError("Failed to create Review Entry: \(error)")
        }
    }
}
