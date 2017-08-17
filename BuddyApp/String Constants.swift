//
//  String Constants.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 20/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation

let ALERT_TITLE = "Buddi"
let SERVER_NOT_RESPONDING = "Server not responding"
let PLEASE_ENTER_ZIPCODE = "Please enter ZipCode"
let PLEASE_ENTER_VALID_ZIPCODE = "Please enter valid ZipCode"
let PLEASE_ANSWER_ABOVE_QUESTIONS = "Please answer to all questions"
let VIDEO_UPLOADED_SUCCESSFULLY = "Video uploaded successfully"
let PLEASE_ENTER_OTP = "Please enter OTP code"
let SESSION_EXPIRED = "Session Expired"
let PLEASE_CHECK_INTERNET = "Please check your internet connectivity"
let SUCCESSFULLY_SENT_PASSWORD = "A link to reset your password has been sent to your Email address"
let SUCCESSFULLY_LOGGED_IN = "Welcome user"
let UPLOAD_VIDEO_MINIMUM_DURATION = "Please upload a video of 30 seconds minimum duration"
let UPLOAD_VIDEO_MAXIMUM_DURATION = "Please upload a video of 90 seconds maximum duration"
let REQUEST_TIMED_OUT = "Request timed out"
let ARE_YOU_SURE_WANT_TO_LOGOUT = "Are you sure you want to log out?"
let PAYMENT_METHOD_FETCH_ERROR = "Could not fetch payment methods"
let PLEASE_ADD_PAYMENT_METHOD = "Please add payment method"
let PAYMENT_COULD_NOT_PROCESSED = "Payment could not be processed, please try again."
let PAYMENT_SUCCESSFULL = "Payment successfull"
let PROFILE_UPDATED_SUCCESSFULLY = "Profile updated successfully"

let VIDEO_DESC = "*Videos should be no longer than 90 seconds. Try to keep them as short and to the point as possible.It would be beneficial to have someone record the videos for you."

let SQUAT_MALE_DESC = "Video 1: Record yourself doing 1 rep with 135lb on the bar from 2 different angles.\nVideo 2: Record yourself doing 1 rep with your bodyweight on the bar from 2 different angles."
let SQUAT_FEMALE_DESC = "Video 1: Record yourself doing 1 rep with 95lb on the bar from 2 different angles.\nVideo 2: Record yourself doing 1 rep with your bodyweight on the bar form 2 different angles."

let DEADLIFT_MALE_DESC = "Video 1: Record yourself doing 1 rep with 155lb on the bar from 2 different angles.\nVideo 2: Record yourself doing 1 rep with your bodyweight on the bar from 2 different angles."

let DEADLIFT_FEMALE_DESC = "Video 1: Record yourself doing 1 rep with 135lb on the bar from 2 different angles. \nVideo 2: Record yourself doing 1 rep with your bodyweight on the bar from 2 different angles. "

let BENCH_PRESS_MALE_DESC = "Video 1: Record yourself doing 1 rep with 135lb on the bar from 2 different angles. \nVideo 2: Record yourself doing 1 rep with your bodyweight on the bar from 2 different angles."

let BENCH_PRESS_FEMALE_DESC = "Video 1: Record yourself doing 1 rep with 65lb on the bar from 2 different angles. \nVideo 2: Record yourself doing 1 rep with 951b. on the bar from 2 different angles."

let SNACH_MALE_DESC = "Video 1: Record yourself doing 1 rep with 135lb on the bar from 2 different angles. \nVideo 2: Record yourself doing 1 rep with your bodyweight on the bar from 2 different angles."

let SNACH_FEMALE_DESC = "Video 1: Record yourself doing 1 rep with 95lb on the bar from 2 different angles. \nVideo 2: Record yourself doing 1 rep with your body weight on the bar from 2 different angles. "

let CLEAN_JERK_MALE_DESC = "Video 1: Record yourself doing 1 rep with your bodyweight on the bar from 2 different angles. \nVideo 2: Record yourself doing 1 rep with 1.5 your bodyweight on the bar from 2 different angles."

let CLEAN_JERK_FEMALE_DESC = "Video 1: Record yourself doing 1 rep with 95lb on the bar from 2 different angles. \nVideo 2: Record yourself doing 1 rep with your body weight on the bar from 2 different angles."

// 9 Values
let leftMenuTrainee = ["Home",
                       "Settings",
                       "Become a Trainer",
                       "Payment Method",
                       "Training History",
                       "Invite Friends",
                       "Help",
                       "Legal",
                       "Logout"]

// 8 Values
let leftMenuTraineeAndTrainerAlso = ["Home",
                                    "Settings",
                                    "Payment Method",
                                    "Training History",
                                    "Invite Friends",
                                    "Help",
                                    "Legal",
                                    "Logout"]

// 8 Values
let leftMenuTrainer = ["Home",
                       "Settings",
                       "Add Category",
                       "Training History",
                       "Invite Friends",
                       "Help",
                       "Legal",
                       "Logout"]

// 8 Values
let ImageArrayTrainer = ["ic_home",
                         "ic_settings",
                         "ic_payment",
                         "ic_history",
                         "ic_people",
                         "ic_help",
                         "ic_notifications",
                         "ic_exit_to_app"]

// 9 Values
let ImageArrayTrainee = ["ic_home",
                         "ic_settings",
                         "ic_payment",
                         "ic_check_circle",
                         "ic_history",
                         "ic_people",
                         "ic_help",
                         "ic_notifications",
                         "ic_exit_to_app"]

// 8 Values
let ImageArrayTraineeAndTrainerAlso = ["ic_home",
                         "ic_settings",
                         "ic_payment",
                         "ic_history",
                         "ic_people",
                         "ic_help",
                         "ic_notifications",
                         "ic_exit_to_app"]

let weightRangeArray = ["60 - 65",
                        "66 - 70",
                        "71 - 75",
                        "76 - 80",
                        "81 - 85",
                        "86 - 90",
                        "91 - 95",
                        "96 - 100",
                        "101 - 105",
                        "106 - 110"]

let trainingExperienceArray = ["< 1","1 - 2","2 - 3","3 - 4","4 - 5","5 - 6", "6 - 7", "7 - 8", "8 - 9", "9 - 10", "> 10"]

let trainingExperienceOrderedSet = NSMutableOrderedSet(array: trainingExperienceArray, copyItems: true)
let weightRangeOrderedSet = NSMutableOrderedSet(array: weightRangeArray, copyItems: true)

let trainingDurationArray = ["40 Minutes", "1 Hour"]

let trainingExperienceYearsArray = ["1","2","3","4","5","6","7","8","9","10","10+"]
let trainingExperienceMonthsArray = Array(0...12)

let currentWeightONEArray = [100,200,300,400]
let currentWeightSecondArray = Array(1..<100)

let exerciseNutritionArray = ["Not at all", "Somewhat knowledgeable", "Extremely knowledgeable"]


