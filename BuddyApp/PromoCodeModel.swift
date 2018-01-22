//
//  PromoCodeModel.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/01/18.
//  Copyright © 2018 Ti Technologies. All rights reserved.
//

import Foundation

class PromoCodeModel{
    
    var codeId : String = String()
    var codeLimit : String = String()
    var codeDescription : String = String()
    var expiryDate : Date = Date()
    
    init(){}
    
    init(codeId: String, codeLimit: String, codeDescription: String, expiryDate: Date){
        
        self.codeId = codeId
        self.codeLimit = codeLimit
        self.codeDescription = codeDescription
        self.expiryDate = expiryDate
    }

}
