//
//  GymModel.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 01/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation

class GymModel{
    
    var gymId : String = String()
    var gymName : String = String()
    var gymStatus : String = String()
    var gymLat : String = String()
    var gymLong : String = String()
    
    
    func gymModelFromDict(dictionary: Dictionary<String, Any>) -> GymModel {
        
        let model: GymModel = GymModel()
        
        model.gymId = String(describing: dictionary["gym_id"]!)
        model.gymName = dictionary["gym_name"] as! String
        model.gymStatus = String(describing: dictionary["status"]!)
        model.gymLat = dictionary["latitude"] as! String
        model.gymLong = dictionary["longitude"] as! String

        return model
    }

}
