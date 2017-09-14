//
//  TrainerProfileDetail+CoreDataClass.swift
//  BuddyApp
//
//  Created by Ti Technologies on 17/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

@objc(TrainerProfileDetail)
public class TrainerProfileDetail: NSManagedObject {
    
    class func createProfileBookingEntry(TrainerProfileModal: TrainerProfileModal) {
        
        print("*** Review ID:",TrainerProfileModal.userid)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrainerProfileDetail")
        fetchRequest.predicate = NSPredicate(format: "userId == %@", TrainerProfileModal.userid)
        
        do {
            let profiles = try context.fetch(fetchRequest)
            
            if profiles.count > 0 {
                print("profile entry present")
                let profile = profiles[0] as! NSManagedObject
                
                profile.setValue(TrainerProfileModal.firstName, forKey: "firstname")
                profile.setValue(TrainerProfileModal.lastName, forKey: "lastname")
                profile.setValue(TrainerProfileModal.gender, forKey: "gender")
                profile.setValue(TrainerProfileModal.Height, forKey: "height")
                profile.setValue(TrainerProfileModal.Weight, forKey: "weight")
                profile.setValue(TrainerProfileModal.rating, forKey: "rating")
                profile.setValue(TrainerProfileModal.age, forKey: "age")
                profile.setValue(TrainerProfileModal.userid, forKey: "userId")
                profile.setValue(TrainerProfileModal.profileImage, forKey: "profileimage")
                profile.setValue(TrainerProfileModal.Booking_id, forKey: "bookingId")
                profile.setValue(TrainerProfileModal.Trainee_id, forKey: "traineeId")
                profile.setValue(TrainerProfileModal.Trainer_id, forKey: "trainerId")
                profile.setValue(TrainerProfileModal.Lattitude, forKey: "lattitude")
                profile.setValue(TrainerProfileModal.Longitude, forKey: "longitude")
                
                profile.setValue(TrainerProfileModal.PickUpLocation, forKey: "pickuplocation")
                profile.setValue(TrainerProfileModal.PickUpLattitude, forKey: "pickuplattitude")
                profile.setValue(TrainerProfileModal.PickUpLongitude, forKey: "pickuplongitude")
               
                //profile.setValue(profileModel.profileImageData, forKey: "profileImageData")
                
                appDelegate.saveContext()
            }else{
                print("profile entry not present")
                let profile = NSEntityDescription.insertNewObject(forEntityName: "TrainerProfileDetail", into:context) as! TrainerProfileDetail
                profile.setValue(TrainerProfileModal.firstName, forKey: "firstname")
                profile.setValue(TrainerProfileModal.lastName, forKey: "lastname")
                profile.setValue(TrainerProfileModal.gender, forKey: "gender")
                profile.setValue(TrainerProfileModal.Height, forKey: "height")
                profile.setValue(TrainerProfileModal.Weight, forKey: "weight")
                profile.setValue(TrainerProfileModal.rating, forKey: "rating")
                profile.setValue(TrainerProfileModal.age, forKey: "age")
                profile.setValue(TrainerProfileModal.userid, forKey: "userId")
                profile.setValue(TrainerProfileModal.profileImage, forKey: "profileimage")
                profile.setValue(TrainerProfileModal.Booking_id, forKey: "bookingId")
                profile.setValue(TrainerProfileModal.Trainee_id, forKey: "traineeId")
                profile.setValue(TrainerProfileModal.Trainer_id, forKey: "trainerId")
                profile.setValue(TrainerProfileModal.Lattitude, forKey: "lattitude")
                profile.setValue(TrainerProfileModal.Longitude, forKey: "longitude")
                
                profile.setValue(TrainerProfileModal.PickUpLocation, forKey: "pickuplocation")
                profile.setValue(TrainerProfileModal.PickUpLattitude, forKey: "pickuplattitude")
                profile.setValue(TrainerProfileModal.PickUpLongitude, forKey: "pickuplongitude")


                appDelegate.saveContext()
            }
            
        }catch {
            fatalError("Failed to create profile Entry: \(error)")
        }
    }
    class func fetchBookingDetails() -> NSArray? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrainerProfileDetail")
        var fetchResult = NSArray()
        
        do {
            let profiles = try context.fetch(fetchRequest)
            
            
            fetchResult = profiles as NSArray
            print("fetchResult",fetchResult)
            
        } catch{
        }
        return fetchResult
    }
    class func deleteBookingDetails(){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrainerProfileDetail")
        do {
            if let result = try? context.fetch(fetchRequest) {
                for object in result {
                    context.delete(object as! NSManagedObject)
                }
                
                appDelegate.saveContext()
            }
            
        } catch {
            
        }
    }
}
