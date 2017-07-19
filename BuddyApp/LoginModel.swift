//
//  LoginModel.swift
//  BuddyApp
//
//  Created by Ti Technologies on 19/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
class LoginModel{
    
    
    var username: String = String()
    var password: String = String()
    var userid: String = String()
    var usertoken: String = String()
    
    init(){}
    
    init(username: String, password: String, userid: String, usertoken: String){
        
        
        self.username = username
        self.password = password
        self.userid = userid
        self.usertoken = usertoken
    }
    func getBookingHistoryModelFromDict(dictionary: Dictionary<String, Any>) -> LoginModel {
        
        let model: LoginModel = LoginModel()
        
        model.username = dictionary["username"] as! String
        model.password = dictionary["password"] as! String
        model.userid = dictionary["userid"] as! String
        model.usertoken = dictionary["usertoken"] as! String
        
        return model
    }
 
}
