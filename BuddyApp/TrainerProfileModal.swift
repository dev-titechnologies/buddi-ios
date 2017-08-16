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
    var Trainer_id: String = String()
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
    
    
    init(){}
    
    init(profileImage: String, firstName: String, lastName: String, mobile: String, gender: String, userid: String, rating: String, age: String, height: String, weight: String, distance: String, lattitude: String, longittude: String, bookingId: String, trainerId: String){
        
        self.profileImage = profileImage
        self.Booking_id = bookingId
        self.Trainer_id = trainerId
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
    }
    
    func getTrainerProfileModelFromDict(dictionary: Dictionary<String, Any>) -> TrainerProfileModal {
        
        let model: TrainerProfileModal = TrainerProfileModal()
        
        let trainerDetailsDict = dictionary["trainer_details"] as! Dictionary<String, Any>
        print("Trainer Basic Details:\(trainerDetailsDict)")
        
        model.firstName =  trainerDetailsDict["trainer_first_name"] as! String
        model.lastName = trainerDetailsDict["trainer_last_name"] as! String
        model.Booking_id = String(dictionary["book_id"] as! Int)
        model.Trainer_id = String(dictionary["trainer_id"] as! Int)
        model.gender = CommonMethods.checkStringNull(val: trainerDetailsDict["trainer_gender"] as? String)
        model.userid = String(describing: dictionary["trainer_id"]!)
        model.age = CommonMethods.checkStringNull(val: trainerDetailsDict["trainer_age"] as? String)
        model.rating = CommonMethods.checkStringNull(val: trainerDetailsDict["trainer_rating"] as? String)
        model.Height = CommonMethods.checkStringNull(val: trainerDetailsDict["trainer_height"] as? String)
        model.Weight = CommonMethods.checkStringNull(val: trainerDetailsDict["trainer_weight"] as? String)
        model.distance = CommonMethods.checkStringNull(val: trainerDetailsDict["trainer_distance"] as? String)
        model.Lattitude = String(describing: trainerDetailsDict["trainer_latitude"]!)
        model.Longitude = String(describing: trainerDetailsDict["trainer_longitude"]!)
        
        print("Creating Model for Trainer:\(model)")

        return model
    }
    
}

