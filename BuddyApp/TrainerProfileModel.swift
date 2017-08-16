//
//  TrainerProfileModel.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 14/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation

class TrainerProfileModel {
    
    var profileImage : String = String()
    var firstName: String = String()
    var lastName: String = String()
    var email: String = String()
    var mobile: String = String()
    var age: String = String()
    var height: String = String()
    var weight: String = String()
    var gender: String = String()
    var profileImageData: Data = Data()

    
    func getTrainerProfileModelFromDict(dictionary: NSDictionary) -> TrainerProfileModel {
        
        let profileModel = TrainerProfileModel()
        
        profileModel.profileImage = dictionary["user_image"] as! String
        profileModel.firstName = dictionary["first_name"] as! String
        profileModel.lastName = dictionary["last_name"] as! String
        profileModel.email = dictionary["email"] as! String
        profileModel.mobile = dictionary["mobile"] as! String
        profileModel.age =  CommonMethods.checkStringNull(val: dictionary["age"] as? String)
        profileModel.height = CommonMethods.checkStringNull(val: dictionary["height"] as? String)
        profileModel.weight = CommonMethods.checkStringNull(val: dictionary["weight"] as? String)
        profileModel.gender = dictionary["gender"] as! String
        profileModel.profileImage = dictionary["user_image"] as! String
        
        return profileModel
    }
}
