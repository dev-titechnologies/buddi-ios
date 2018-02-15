//
//  SessionDurationModel.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 14/02/18.
//  Copyright © 2018 Ti Technologies. All rights reserved.
//

import Foundation

class SessionDurationModel: NSObject, NSCoding  {
    
    var sessionDuration: String?
    var amount: String?
    var sessionTitle: String?

    override init() {}

    
    required init?(coder aDecoder: NSCoder) {
        if let session_title = aDecoder.decodeObject(forKey: "sessionTitle") as? String {
            self.sessionTitle = session_title
        }
        if let amountCopy = aDecoder.decodeObject(forKey: "amount") as? String {
            self.amount = amountCopy
        }
        if let session_duration = aDecoder.decodeObject(forKey: "sessionDuration") as? String {
            self.sessionDuration = session_duration
        }
    }
    
    func encode(with aCoder: NSCoder) {
        if let session_title = self.sessionTitle {
            aCoder.encode(session_title, forKey: "sessionTitle")
        }
        if let amountCopy = self.amount {
            aCoder.encode(amountCopy, forKey: "amount")
        }
        if let session_duration = self.sessionDuration {
            aCoder.encode(session_duration, forKey: "sessionDuration")
        }
    }
}
