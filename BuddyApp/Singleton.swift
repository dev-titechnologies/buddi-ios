//
//  Singleton.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 25/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import Alamofire
import RNNotificationView

class Singleton {
    
    var RNNotification = RNNotificationView()
    var commonMethods = CommonMethods()
    var userDefaults = UserDefaults()
    var appdelegate = AppDelegate()
    var storyboardSingleton = UIStoryboard()
    var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    var privateMoc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

    var selectedCategories : [CategoryModel] = [CategoryModel]()
    var selectedSubCategories : [SubCategoryModel] = [SubCategoryModel]()
    var selectedSubCategoriesAmong : [SubCategoryModel] = [SubCategoryModel]()
    var trainerTestAnswers: TrainerTestAnswersModel = TrainerTestAnswersModel()
    var approvedOrPendingCategories = [String]()
    var approvalPendingCategories = [Int]()
    var subCategoryVideoURLs = [VideoURLModel]()
    
    //For Trainee
    var choosedCategory: CategoryModel = CategoryModel()
    var choosedSession = String()
    var choosedTrainerGender = String()
    
    //For online availability
    var onlineavailabilty = Bool()
    
    //For Trainee Settings Preference
    var choosedCategoryPreference: CategoryModel = CategoryModel()
    var choosedSessionPreference = String()
    var choosedTrainerGenderPreference = String()
    var choosedTrainingLocationPreference = String()
    
    //Timer for addlocation for the Trainer. which is used in the home page of trainer profile.
    var addLocationTimer : Timer?

    static let sharedInstance : Singleton = {
        let instance = Singleton()
        return instance
    }()
    
    init() {
        
        RNNotification = RNNotificationView()
        commonMethods = CommonMethods()
        userDefaults = UserDefaults.standard
        appdelegate = UIApplication.shared.delegate as! AppDelegate
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        privateMoc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        selectedSubCategories = [SubCategoryModel]()
        storyboardSingleton = UIStoryboard(name: "Main", bundle: nil)
        onlineavailabilty = true
        addLocationTimer = Timer()
    }
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
   }
