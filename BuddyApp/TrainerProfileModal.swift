//
//  TrainerProfileModal.swift
//  BuddyApp
//
//  Created by Ti Technologies on 07/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
class TrainerProfileModal{
    
    var profileImage : String = String()
    var Booking_id: String = String()
    var categoryId: String = String()
    var Trainer_id: String = String()
    var Trainee_id: String = String()
    var firstName: String = String()
    var lastName: String = String()
    var mobile: String = String()
    var gender: String = String()
    var userid: String = String()
    var distance: String = String()
    var Height: String = String()
    var Weight: String = String()
    var rating: String = String()
    var age: String = String()
    var Lattitude: String = String()
    var Longitude: String = String()
    var PickUpLongitude: String = String()
    var PickUpLattitude: String = String()
    var PickUpLocation: String = String()
    
    
    init(){}
    
    init(profileImage: String, firstName: String, lastName: String, mobile: String, gender: String, userid: String, rating: String, age: String, height: String, weight: String, distance: String, lattitude: String, longittude: String, bookingId: String, trainerId: String,traineeId: String,pickup_lattitude: String,pickup_longitude: String,pickup_location: String){
        
        self.profileImage = profileImage
        self.Booking_id = bookingId
        self.Trainer_id = trainerId
        self.Trainee_id = traineeId
        self.firstName = firstName
        self.lastName = lastName
        self.mobile = mobile
        self.gender = gender
        self.userid = userid
        self.age = age
        self.rating = rating
        self.Height = height
        self.Weight = weight
        self.distance = distance
        self.Lattitude = lattitude
        self.Longitude = longittude
        self.PickUpLattitude = pickup_lattitude
        self.PickUpLongitude = pickup_longitude
        self.PickUpLocation = pickup_location
    }
    
    func getTrainerProfileModelFromDict(dictionary: Dictionary<String, Any>) -> TrainerProfileModal {
        
        let model: TrainerProfileModal = TrainerProfileModal()
        
        let trainerDetailsDict = dictionary["trainer_details"] as! Dictionary<String, Any>
        print("Trainer Basic Details:\(trainerDetailsDict)")
        
        model.profileImage = CommonMethods.checkStringNull(val:trainerDetailsDict["trainer_user_image"] as? String)
        model.firstName =  trainerDetailsDict["trainer_first_name"] as! String
        model.lastName = trainerDetailsDict["trainer_last_name"] as! String
        model.Booking_id = String(dictionary["book_id"] as! Int)
        model.categoryId = String(dictionary["cat_id"] as! Int)
        model.Trainer_id = String(trainerDetailsDict["trainer_id"] as! Int)
        model.Trainee_id = String(appDelegate.UserId)
        model.gender = CommonMethods.checkStringNull(val: trainerDetailsDict["trainer_gender"] as? String)
        model.userid = String(appDelegate.UserId)
        model.age = CommonMethods.checkStringNull(val: trainerDetailsDict["trainer_age"] as? String)
        model.rating = CommonMethods.checkStringNull(val: trainerDetailsDict["trainer_rating"] as? String)
        model.Height = CommonMethods.checkStringNull(val: trainerDetailsDict["trainer_height"] as? String)
        model.Weight = CommonMethods.checkStringNull(val: trainerDetailsDict["trainer_weight"] as? String)
        model.distance = CommonMethods.checkStringNull(val: trainerDetailsDict["trainer_distance"] as? String)
        model.Lattitude = String(describing: trainerDetailsDict["trainer_latitude"]!)
        model.Longitude = String(describing: trainerDetailsDict["trainer_longitude"]!)
        model.PickUpLattitude = String(dictionary["pick_latitude"] as! String)
        model.PickUpLongitude = String(dictionary["pick_longitude"] as! String)
        model.PickUpLocation = String(dictionary["pick_location"] as! String)

        
        print("Creating Model for Trainer:\(model)")

        return model
    }
    
}

