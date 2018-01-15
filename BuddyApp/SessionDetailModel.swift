//
//  SessionDetailModel.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 28/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation

class SessionDetailModel {
    
    var bookingId : String = String()
    var trainerId : String = String()
    var trainerName: String = String()
    var traineeId: String = String()
    var traineeName: String = String()
    
    init(){}

    init(bookingid: String, trainerid: String, trainername: String, traineeid: String, traineename: String){
        
        self.bookingId = bookingid
        self.trainerId = trainerid
        self.trainerName = trainername
        self.traineeId = traineeid
        self.traineeName = traineename
    }
}
