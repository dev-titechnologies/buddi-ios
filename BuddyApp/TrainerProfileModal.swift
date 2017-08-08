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
    
    init(profileImage: String, firstName: String, lastName: String, mobile: String, gender: String, userid: String, rating: String, age: String, height: String, weight: String, distance: String, lattitude: String, longittude: String){
        
        self.profileImage = profileImage
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
        
       // model.profileImage =  dictionary["booking_id"] as! String
        
        
        print(dictionary["first_name"] as! String)
        
        
        model.firstName =  dictionary["first_name"] as! String
        model.lastName = dictionary["last_name"] as! String
       // model.mobile = dictionary["trainer_id"] as! String
        model.gender = CommonMethods.checkStringNull(val: dictionary["gender"] as? String)
        model.userid = String(describing: dictionary["user_id"]!)
        model.age = CommonMethods.checkStringNull(val: dictionary["age"] as? String)
        model.rating = String(describing: dictionary["rating"]!)
        model.Height = CommonMethods.checkStringNull(val: dictionary["height"] as? String)
        model.Weight = CommonMethods.checkStringNull(val: dictionary["weight"] as? String)
        model.distance = CommonMethods.checkStringNull(val: dictionary["distance"] as? String)
        model.Lattitude = String(describing: dictionary["latitude"]!)
        model.Longitude = String(describing: dictionary["longitude"]!)

        return model
        
    }
    

    
}

