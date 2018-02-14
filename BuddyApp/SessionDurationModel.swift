//
//  SessionDurationModel.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 14/02/18.
//  Copyright © 2018 Ti Technologies. All rights reserved.
//

import Foundation

class SessionDurationModel: NSObject, NSCoding {
    
    var sessionDuration : String = String()
    var amount : String = String()
    var sessionTitle : String = String()
    
    required init(coder aDecoder: NSCoder) {   }
    
    override init(){}
    
    func encode(with aCoder: NSCoder) {   }

}
