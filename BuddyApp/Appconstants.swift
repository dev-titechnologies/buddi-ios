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
let trainerTestAnswers = Singleton.sharedInstance.trainerTestAnswers
var selectedCategoriesSingleton = Singleton.sharedInstance.selectedCategories
var selectedSubCategoriesSingleton = Singleton.sharedInstance.selectedSubCategories
var selectedSubCategoriesAmongSingleton = Singleton.sharedInstance.selectedSubCategoriesAmong
var approvedCategories = Singleton.sharedInstance.approvedCategories
var approvalPendingCategories = Singleton.sharedInstance.approvalPendingCategories
var subCategoryVideoURLsSingleton = Singleton.sharedInstance.subCategoryVideoURLs


let SERVER_URL  = ""
<<<<<<< HEAD
//let SERVER_URL_Local = "http://192.168.1.14:4001/"
=======
>>>>>>> 414bc18ef66c879e430ed35fe1c42899a0f6b0dc
let SERVER_URL_Local = "http://git.titechnologies.in:4001/"

struct RESPONSE_STATUS {
    static let SUCCESS = 1
    static let FAIL = 2
    static let SESSION_EXPIRED = 3
}

struct SUB_CATEGORY_TITLES {
    static let SQUAT = "Squat"
    static let DEAD_LIFT = "Deadlift"
    static let BENCH_PRESS = "Bench Press"
    static let SNACH = "Snatch"
    static let CLEAN_JERK = "Clean & Jerk"
}

struct REGISTER_TYPE {
    static let FACEBOOK = "facebook"
    static let GOOGLE = "google"
    static let NORMAL = "normal"
}


class Appconstants: NSObject {
    
        

}
