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

//For Trainee
var choosedCategoryOfTrainee = Singleton.sharedInstance.choosedCategory
var choosedSessionOfTrainee = Singleton.sharedInstance.choosedSession
var choosedTrainerGenderOfTrainee = Singleton.sharedInstance.choosedTrainerGender

//let SERVER_URL = "http://192.168.1.14:4001/"
let SERVER_URL = "http://git.titechnologies.in:4001/"

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

struct GENDER {
    static let MALE = "male"
    static let FEMALE = "female"
}

class Appconstants: NSObject {
    
        

}
