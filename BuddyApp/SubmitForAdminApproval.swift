//
//  SubmitForAdminApproval.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 25/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class SubmitForAdminApproval: UIViewController {
    
    var categoryIDs: [String] = [String]()
    var questionsDict = [String:String]()
    var subCategoryIDs: [String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("Categories",selectedCategoriesSingleton)
        print("SubCategories",selectedSubCategoriesAmongSingleton)
        
        print("Trainer Test Answers")
        print("====================")
        print("ZipCode:",trainerTestAnswers.zipCode)
        print("Subscriptions:",trainerTestAnswers.gymSubscriptions)
        print("Access Military:",trainerTestAnswers.isHavingMilitaryInstallations)
        print("How long Training:",trainerTestAnswers.trainingExperience)
        print("Category Completion status:",trainerTestAnswers.categoryTrainingCompletion)
        print("Anybody Coached:",trainerTestAnswers.isAnybodyCoachedCategory)
        print("Certified Personal Trainer:",trainerTestAnswers.isCertifiedTrainer)
        print("Current Weight:",trainerTestAnswers.currentWeight)
        print("Lost or Gain Weight in 6 Months:",trainerTestAnswers.lostOrGainWeightInSixMonths)
        
        loadCategoryIDs()
        loadSubCategoryIDs()
        loadQuestionsArray()
    }
    
    func loadCategoryIDs() {
        for category in selectedCategoriesSingleton{
            categoryIDs.append(category.categoryId)
        }
    }
    
    func loadSubCategoryIDs() {
        for subCategory in selectedSubCategoriesAmongSingleton{
            subCategoryIDs.append(subCategory.subCategoryId)
        }
    }
    
    func loadQuestionsArray() {
        
//        questionsDict = ["weight":trainerTestAnswers.currentWeight,
//                         "pounds" : trainerTestAnswers.lostOrGainWeightInSixMonths,
//                         "certified_trainer" : trainerTestAnswers.isCertifiedTrainer,
//                         "zipcode" : trainerTestAnswers.zipCode,
//                         "military_installations" : trainerTestAnswers.isHavingMilitaryInstallations,
//                         "competed_category" : trainerTestAnswers.categoryTrainingCompletion,
//                         "training_exp" : trainerTestAnswers.trainingExperience,
//                         "gym_subscriptions" : trainerTestAnswers.gymSubscriptions
//                         ]
    }
    
    @IBAction func submitForApprovalAction(_ sender: Any) {
        
        let parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId,
                          "cat_ids":categoryIDs,
                          "gym_id":"TestIDGYM",
                          "military":"TESTMilitary",
                          "questions":questionsDict,
                          "cat_subs": subCategoryIDs
        ] as [String : Any]
        
        print("PARAMETERS:",parameters)
        
        let headers = [
            "token":appDelegate.Usertoken]
        
        CommonMethods.serverCall(APIURL: ADD_TRAINER_CATEGORIES_URL, parameters: parameters, headers: headers) { (response) in
            
            print(response)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
