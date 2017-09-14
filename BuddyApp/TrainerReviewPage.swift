//
//  TrainerReviewPage.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 10/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import Alamofire

class TrainerReviewPage: UIViewController{
    

    let reviewDict = TrainerReviewModel()
    var trainerProfileDetails1 = TrainerProfileModal()
    
    @IBOutlet weak var rating_lbl: UILabel!
    @IBOutlet weak var User_type: UILabel!
    @IBOutlet weak var StarRateView: SwiftyStarRatingView!
    @IBOutlet weak var imgTrainerImage: UIImageView!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var txtReviewDescription: UITextView!
    
    var isFromExtendPage = Bool()
    var isFromWaitingForExtendRequestPage = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtReviewDescription.text = "Leave a comment.."
        txtReviewDescription.textColor = UIColor.lightGray
        
       // print(trainerProfileDetails1.firstName)
        lblTrainerName.text = trainerProfileDetails1.firstName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        view?.backgroundColor = UIColor(white: 1, alpha: 0.5)
         starRatingViewValueChange()
        StarRateView.allowsHalfStars = true
        parseTrainerDetails()
    }
    
    func parseTrainerDetails() {
        if appDelegate.USER_TYPE == "trainer" {
            User_type.text = "Trainee"
            rating_lbl.text = "Trainee Rating"
        }else{
            rating_lbl.text = "Trainer Rating"
            User_type.text = "Trainer"
        }
        imgTrainerImage.sd_setImage(with: URL(string: trainerProfileDetails1.profileImage), placeholderImage: UIImage(named: "profileDemoImage"))
    }
    
    func starRatingViewValueChange() {
       print("STAR",StarRateView.value)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func StarRateView_action(_ sender: Any) {
        starRatingViewValueChange()
    }
    
    @IBAction func submitAction(_ sender: Any) {
        self.ReviewAPI()
    }
    
    func ReviewAPI(){
        
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
        var user_id = Int()
        var user_type = String()
        
        if appDelegate.USER_TYPE == "trainer"{
            user_id = Int(trainerProfileDetails1.Trainee_id)!
            user_type = "trainee"
        }else{
            user_id = Int(trainerProfileDetails1.Trainer_id)!
            user_type = "trainer"
        }
        
        let parameters = ["user_type":user_type,
                          "user_id":user_id,
                          "book_id":trainerProfileDetails1.Booking_id,
                          "rating_count":StarRateView.value,
                          "rating_comment":txtReviewDescription.text] as [String : Any]
        
        let headers = [
            "token":appDelegate.Usertoken ]
        
        print("PARAMS",parameters)
        print("HEADER",headers)
        
        CommonMethods.serverCall(APIURL: ADD_REVIEW, parameters: parameters , headers: headers , onCompletion: { (jsondata) in
            print("REVIEW RESPONSE",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    if self.isFromExtendPage{
                        self.performSegue(withIdentifier: "reviewVCToTraineeHomeVCSegue", sender: self)
                    }else if self.isFromWaitingForExtendRequestPage{
                        self.performSegue(withIdentifier: "reviewVCToTrainerHomeVCSegue", sender: self)
                    }else{
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                  
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })

    }
}

extension TrainerReviewPage: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Leave a comment.."
            textView.textColor = UIColor.lightGray
        }
    }
}
