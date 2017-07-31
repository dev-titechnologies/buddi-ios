//
//  CategoryVideoUploadVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 24/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import Alamofire
import MobileCoreServices
import AVFoundation

class CategoryVideoUploadVC: UIViewController,UINavigationControllerDelegate {

    let imagePickerController = UIImagePickerController()
    var videoURL: NSURL?
    var subcategories = [SubCategoryModel]()
    var subCategoryIndex = Int()
    let imagePicker = UIImagePickerController()
    var movieData = NSData()
    var ResponseVideoURL = String()

    @IBOutlet weak var lblSubCategoryTitle: UILabel!
    @IBOutlet weak var lblMainDescription: UILabel!
    @IBOutlet weak var lblMalesDescription: UILabel!
    @IBOutlet weak var lblFemalesDescription: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    
    //For Admin Approval
    var categoryIDs: [String] = [String]()
    var questionsDict = [String:String]()
    var subCategoryIDs: [String] = [String]()
    var videoURLs : [Any] = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subCategoryIndex = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        btnNext.isEnabled = false
        subcategories = selectedSubCategoriesAmongSingleton
        lblMainDescription.text = VIDEO_DESC
        loadSubCategoryDetailsInitially()
    }
    
    func loadSubCategoryDetailsInitially() {
        
        displayDetails(subCategoryName: subcategories[subCategoryIndex].subCategoryName)
    }
    
    func displayDetails(subCategoryName: String) {
        
        switch subCategoryName {
            
        case SUB_CATEGORY_TITLES.SQUAT:
            print("SQUAT")
            lblSubCategoryTitle.text = SUB_CATEGORY_TITLES.SQUAT
            lblMalesDescription.text = SQUAT_MALE_DESC
            lblFemalesDescription.text = SQUAT_FEMALE_DESC
            
        case SUB_CATEGORY_TITLES.DEAD_LIFT:
            print("DEAD_LIFT")
            lblSubCategoryTitle.text = SUB_CATEGORY_TITLES.DEAD_LIFT
            lblMalesDescription.text = DEADLIFT_MALE_DESC
            lblFemalesDescription.text = DEADLIFT_FEMALE_DESC

        case SUB_CATEGORY_TITLES.BENCH_PRESS:
            print("BENCH_PRESS")
            lblSubCategoryTitle.text = SUB_CATEGORY_TITLES.BENCH_PRESS
            lblMalesDescription.text = BENCH_PRESS_MALE_DESC
            lblFemalesDescription.text = BENCH_PRESS_FEMALE_DESC
            
        case SUB_CATEGORY_TITLES.SNACH:
            print("SNACH")
            lblSubCategoryTitle.text = SUB_CATEGORY_TITLES.SNACH
            lblMalesDescription.text = SNACH_MALE_DESC
            lblFemalesDescription.text = SNACH_FEMALE_DESC
            
        case SUB_CATEGORY_TITLES.CLEAN_JERK:
            print("CLEAN_JERK")
            lblSubCategoryTitle.text = SUB_CATEGORY_TITLES.CLEAN_JERK
            lblMalesDescription.text = CLEAN_JERK_MALE_DESC
            lblFemalesDescription.text = CLEAN_JERK_FEMALE_DESC
            
        default:
            print("Sub Category not Defined")
        }
    }
    
    @IBAction func pickVideoFromGalleryAction(_ sender: Any) {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePickerController.mediaTypes = ["public.image", "public.movie"]
        
        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func subCategoryNextButton(_ sender: Any) {
        
        subCategoryIndex += 1
        if subCategoryIndex == subcategories.count{
//            performSegue(withIdentifier: "afterVideoUploadSegue", sender: self)
            
            //Server call for Submit for Admin Approval
            initializaionForAdminApproval()
        }else{
            btnNext.isEnabled = false
            displayDetails(subCategoryName: subcategories[subCategoryIndex].subCategoryName)
        }
    }
    
    @IBAction func camera_action(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.mediaTypes = [kUTTypeMovie as NSString as String]
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker,
                animated: true,
                completion: nil)
    }
    
    func initializaionForAdminApproval() {
        
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
        submitForApprovalAction()
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
    
    func submitForApprovalAction() {
        
        let parameters = ["user_type":appDelegate.Usertoken,
                          "user_id": appDelegate.UserId,
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
                    self.performSegue(withIdentifier: "waitingForAdminApprovalSegue", sender: self)
                }
                else if status == RESPONSE_STATUS.SESSION_EXPIRED
                    
                {
                    self.dismissOnSessionExpire()
                }
                else
                {
                     CommonMethods.alertView(view: self, title: ALERT_TITLE, message: response["message"] as? String, buttonTitle: "Ok")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func UploadVideoAPI() {

        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please check your internet connectivity", buttonTitle: "Ok")
            return
        }
        
        CommonMethods.showProgress()
        
        let headers = [
            "token":appDelegate.Usertoken]
        
        let parameters = ["file_type":"vid",
                          "upload_type":"other"]
        
        print("PARAMS",parameters)
        print("HEADERS",headers)
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                
                print("PARAMETER1",value)
                print("PARAMETER11",key)
                multipartFormData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
            }
            multipartFormData.append(self.movieData as Data, withName: "file_name", fileName: "video.mov", mimeType: "video/mov")
        }, to: "http://192.168.1.14:4001/upload/upload",
           method:.post,
           headers:headers,
           
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    debugPrint(response)
                    print("Video Upload Response:",response)
                    
                    if let jsonDic = response.result.value as? NSDictionary{
                        print("DICT ",jsonDic)
                        
                        if let status = jsonDic["status"] as? Int{
                            if status == RESPONSE_STATUS.SUCCESS{
                                self.ResponseVideoURL = (jsonDic["Url"] as? String)!
                                self.loadSubCategoryURLToSingletonArray(videoURL: self.ResponseVideoURL)
                                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: VIDEO_UPLOADED_SUCCESSFULLY, buttonTitle: "Ok")
                                self.btnNext.isEnabled = true
                            }else if status == RESPONSE_STATUS.FAIL{
                                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsonDic["message"] as? String, buttonTitle: "OK")
                            }else if status == RESPONSE_STATUS.SESSION_EXPIRED {
                                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SESSION_EXPIRED, buttonTitle: "OK")
                                self.dismissOnSessionExpire()
                            }

                        }
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    func loadSubCategoryURLToSingletonArray(videoURL: String) {
        
        let videoURLModelObj = VideoURLModel()
        videoURLModelObj.subCategoryId = subcategories[subCategoryIndex].subCategoryId
        videoURLModelObj.subCategoryName = subcategories[subCategoryIndex].subCategoryName
        videoURLModelObj.videoURL = videoURL
        
        subCategoryVideoURLsSingleton.append(videoURLModelObj)
    }
}

extension CategoryVideoUploadVC : UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        videoURL = info["UIImagePickerControllerMediaURL"] as? NSURL
        print("URLL",videoURL!)
        
        do {
            let video = try NSData(contentsOf: (info["UIImagePickerControllerMediaURL"] as? NSURL)! as URL, options: .mappedIfSafe)
            movieData = video
            print("Total bytes \(movieData.length/(1000*1000))")
        } catch {
            print(error)
            return
        }
        
        dismiss(animated: true, completion: nil)
        UploadVideoAPI()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


extension CategoryVideoUploadVC: AVCaptureFileOutputRecordingDelegate {
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        guard let data = NSData(contentsOf: outputFileURL as URL) else {
            return
        }
        
        print("File size before compression1: \(Double(data.length / 1048576)) mb")
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
        compressVideo(inputURL: outputFileURL as URL, outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
                
                print("File size after compression1: \(Double(compressedData.length / 1048576)) mb")
            case .failed:
                break
            case .cancelled:
                break
            }
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
}
