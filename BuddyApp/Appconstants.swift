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
let storyboardSingleton = Singleton.sharedInstance.storyboardSingleton
let userDefaults = Singleton.sharedInstance.userDefaults
let trainerTestAnswers = Singleton.sharedInstance.trainerTestAnswers
var selectedCategoriesSingleton = Singleton.sharedInstance.selectedCategories
var selectedSubCategoriesSingleton = Singleton.sharedInstance.selectedSubCategories
var selectedSubCategoriesAmongSingleton = Singleton.sharedInstance.selectedSubCategoriesAmong
var approvedOrPendingCategoriesSingleton = Singleton.sharedInstance.approvedOrPendingCategories
var approvalPendingCategories = Singleton.sharedInstance.approvalPendingCategories
var subCategoryVideoURLsSingleton = Singleton.sharedInstance.subCategoryVideoURLs

//For Trainee
var choosedCategoryOfTrainee = Singleton.sharedInstance.choosedCategory
var choosedSessionOfTrainee = Singleton.sharedInstance.choosedSession
var choosedTrainerGenderOfTrainee = Singleton.sharedInstance.choosedTrainerGender

var onlineavailabilty = Singleton.sharedInstance.onlineavailabilty
//For Trainee Preference Settings
var choosedCategoryOfTraineePreference = Singleton.sharedInstance.choosedCategoryPreference
var choosedSessionOfTraineePreference = Singleton.sharedInstance.choosedSessionPreference
var choosedTrainerGenderOfTraineePreference = Singleton.sharedInstance.choosedTrainerGenderPreference
var choosedTrainingLocationPreference = Singleton.sharedInstance.choosedTrainingLocationPreference


//let SERVER_URL = "http://192.168.1.20:9002/"
let SERVER_URL = "http://git.titechnologies.in:4001/"
let COUNTRY_DEFAULT_REGION_CODE = "IN"
let GOOGLE_API_KEY = "AIzaSyDG9LK6RE-RWtyvRRposjxnxFR90Djk_0g"
//AIzaSyCSZe_BrUnVvqOg4OCQUHY7fFem6bvxOkc
let GOOGLE_TRACKER_ID = "UA-106775368-1"
let PAYPAL_PAYMENT_RETURN_URL = "com.titechnologies.BuddyApp.payments"
let GID_CLIENT_ID = "635834235607-h0j2s9gtins29gliuc5jhu6v0dcrqfg2.apps.googleusercontent.com"

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
