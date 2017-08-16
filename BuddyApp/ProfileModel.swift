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
    var firstName: String = String()
    var lastName: String = String()
    var email: String = String()
    var mobile: String = String()
    var gender: String = String()
    var userid: String = String()
    var profileImageData: Data = Data()
    
    init(){}
    
    init(profileImage: String, firstName: String, lastName: String, email: String, mobile: String, gender: String, userid: String){
        
        self.profileImage = profileImage
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.mobile = mobile
        self.gender = gender
        self.userid = userid
    }
}
