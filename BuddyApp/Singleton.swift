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

class Singleton {
    
    var userDefaults = UserDefaults()
    var appdelegate = AppDelegate()
    var storyboardSingleton = UIStoryboard()
    var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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
    
    static let sharedInstance : Singleton = {
        let instance = Singleton()
        return instance
    }()
    
    init() {
        userDefaults = UserDefaults.standard
        appdelegate = UIApplication.shared.delegate as! AppDelegate
        context = appdelegate.persistentContainer.viewContext
        selectedSubCategories = [SubCategoryModel]()
        storyboardSingleton = UIStoryboard(name: "Main", bundle: nil)
        onlineavailabilty = true
    }
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
    //    func listenForReachability() {
    //        self.reachabilityManager?.listener = { status in
    //            print("Network Status Changed: \(status)")
    //            switch status {
    //            case .NotReachable
    //            //Show error state
    //            case .Reachable(_), .Unknown: break
    //                //Hide error state
    //            }
    //        }
    //
    //        self.reachabilityManager?.startListening()
    //    }
    
}
