//
//  ProfileModel.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation

class ProfileModel{
    
    var profileImage : String = String()
    var name: String = String()
    var email: String = String()
    var mobile: String = String()
    var gender: String = String()
    
    init(){}
    
    init(profileImage: String, name: String, email: String, mobile: String, gender: String){
        
        self.profileImage = profileImage
        self.name = name
        self.email = email
        self.mobile = mobile
        self.gender = gender
    }

}
