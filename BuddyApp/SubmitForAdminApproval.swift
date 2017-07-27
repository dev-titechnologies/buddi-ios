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
    var videoURLs : [Any] = [Any]()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("Categories",selectedCategoriesSingleton)
        print("SubCategories",selectedSubCategoriesAmongSingleton)
        
        for i in 0..<subCategoryVideoURLsSingleton.count{
            print("SubCategory Video URL \(i):",subCategoryVideoURLsSingleton[i].videoURL)
        }
        
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
        loadVideoURLs()
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
    
    func loadVideoURLs(){
        
        for i in 0..<subCategoryVideoURLsSingleton.count{
            
            var sub_category_dict = [String: String]()
            sub_category_dict["subCat_name"] = subCategoryVideoURLsSingleton[i].subCategoryName
            sub_category_dict["video_url"] = subCategoryVideoURLsSingleton[i].videoURL
            sub_category_dict["subCat_id"] = subCategoryVideoURLsSingleton[i].subCategoryId
            videoURLs.append(sub_category_dict)
        }
        print("Sub Category Video URL Dict:",videoURLs)
    }
    
    func loadQuestionsArray() {
        
        questionsDict = ["weight":trainerTestAnswers.currentWeight,
                         "pounds" : (trainerTestAnswers.lostOrGainWeightInSixMonths ? "yes" : "no"),
                         "certified_trainer" : (trainerTestAnswers.isCertifiedTrainer ? "yes" : "no"),
                         "zipcode" : trainerTestAnswers.zipCode,
                         "military_installations" : (trainerTestAnswers.isHavingMilitaryInstallations ? "yes" : "no"),
                         "competed_category" : (trainerTestAnswers.categoryTrainingCompletion ? "yes" : "no"),
                         "training_exp" : trainerTestAnswers.trainingExperience,
                         "gym_subscriptions" : trainerTestAnswers.gymSubscriptions,
                         "coached_anybody" : (trainerTestAnswers.isAnybodyCoachedCategory ? "yes" : "no")
                         ]
    }
    
    func toJSONString(from object: Any) -> String? {
        if let objectData = try? JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions(rawValue: 0)) {
            let objectString = String(data: objectData, encoding: .utf8)
            return objectString
        }
        return nil
    }

    
    @IBAction func submitForApprovalAction(_ sender: Any) {
        
        //"video_data":{"subCat_name":"Snatch","video_url":"http:\/\/192.168.1.14:4001\/video\/c3104aa7-f94c-48e0-845e-400f382ec12c.mkv"}
        
        let parameters = ["user_type":appDelegate.Usertoken,
                          "user_id":"17",
                          "cat_ids": toJSONString(from: categoryIDs)!,
                          "gym_id":"TestIDGYM",
                          "military":"TESTMilitary",
                          "questions":toJSONString(from: questionsDict)!,
                          "video_data" : toJSONString(from: videoURLs)!

        ] as [String : Any]
        
        print("PARAMETERS:",parameters)
        
        let headers = [
            "token":appDelegate.Usertoken]
        
        CommonMethods.serverCall(APIURL: ADD_TRAINER_CATEGORIES_URL, parameters: parameters, headers: headers) { (response) in
            
            print(response)
            if let status = response["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    self.performSegue(withIdentifier: "afterSubmitForApprovalSegue", sender: self)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
