//
//  Appconstants.swift
//  BuddyApp
//
//  Created by Ti Technologies on 17/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import Foundation

let appDelegate = Singleton.sharedInstance.appdelegate
let context = Singleton.sharedInstance.context
let userDefaults = Singleton.sharedInstance.userDefaults
let SERVER_URL  = ""
let SERVER_URL_Local = "http://192.168.1.14:4001/"

struct RESPONSE_STATUS {
    static let SUCCESS = 1
    static let FAIL = 2
    static let SESSION_EXPIRED = 3
}

class Appconstants: NSObject {

}
