//
//  Appconstants.swift
//  BuddyApp
//
//  Created by Ti Technologies on 17/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import Foundation
import Stripe

let rnnotification = Singleton.sharedInstance.RNNotification
let commonMethods = Singleton.sharedInstance.commonMethods
let appDelegate = Singleton.sharedInstance.appdelegate
let context = Singleton.sharedInstance.context
let privateMoc = Singleton.sharedInstance.privateMoc
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

//For Trainer - Add Location socket
var addLocationTimerSingleton = Singleton.sharedInstance.addLocationTimer

let SERVER_URL = "http://192.168.1.60:9002/"
//let SERVER_URL = "http://git.titechnologies.in:4001/"
//let SERVER_URL = "http://buddiapi.buddiadmin.com/"
//let SERVER_URL = "http://104.236.235.46:9002/"

let SECONDS_CONVERTION_VALUE = 1
//let SECONDS_CONVERTION_VALUE = 60

let STRIPE_PUBLISHER_KEY = "pk_test_66bTUhQFTPY6wY5x2hftqF6l"
//let STRIPE_PUBLISHER_KEY = "pk_live_kThm0Vk9Vmpb6z58SaMrPXpD"

let EXTEND_SESSION_WAITING_TIME = 120
let WAITING_FOR_ACCEPTANCE_TIME = 60 // Currently its based on the Trainers Count

let COUNTRY_DEFAULT_REGION_CODE = "US"
let GOOGLE_API_KEY = "AIzaSyDG9LK6RE-RWtyvRRposjxnxFR90Djk_0g"
let GOOGLE_TRACKER_ID = "UA-106775368-1"
let PAYPAL_PAYMENT_RETURN_URL = "com.titechnologies.BuddyApp.payments"
let GID_CLIENT_ID = "635834235607-h0j2s9gtins29gliuc5jhu6v0dcrqfg2.apps.googleusercontent.com"
let NEW_RELIC_KEY = "AAf5ff3485caac8e2dcd993dcee920d9ab9ba03519"
let TWITTER_CONSUMER_KEY = "HvxI2RuOw573ofkQm9bzfRWWT"
let TWITTER_CONSUMER_SECRET = "2ARSgEGIVBW3pdh8ZnLqg7XUAwKSEzpjGwpAT99jt4bbDe3BBX"

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

struct USER_TYPE {
    static let TRAINER = "trainer"
    static let TRAINEE = "trainee"
}

struct SOCIAL_MEDIA_TYPES {
    static let FACEBOOK = "facebook"
    static let TWITTER = "twitter"
    static let SNAPCHAT = "snapchat"
    static let LINKDIN = "linkdin"
    static let YOUTUBE = "youtube"
    static let INSTAGRAM = "instagram"
}

struct SESSION_DURATIONS{
    static let FOURTY_MINUTES = "40"
    static let SIXTY_MINUTES = "60"
}
