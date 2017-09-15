//
//  WaitingForAcceptancePage.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 06/09/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class WaitingForAcceptancePage: UIViewController {

    @IBOutlet weak var lblLoaderDescription: UILabel!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    var descriptionText = String()
    var forUserType = String()
    
    var isInPage = Bool()
    
    var trainerProfileDetails = TrainerProfileModal()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isInPage = true
        activityIndicatorView.startAnimating()
        activityIndicatorView.type = .ballScaleMultiple
        lblLoaderDescription.text = descriptionText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let notificationName = Notification.Name("FCMNotificationIdentifier")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.triggerDismissWhenNotificationReceived), name: notificationName, object: nil)
        
        let notificationName1 = Notification.Name("SessionNotification")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.triggerDismissWhenNotificationReceived), name: notificationName1, object: nil)

        
        if forUserType == "trainer" {
            triggerDismissPageAfterInterval()
        }else if forUserType == "trainee" {
            //For testing purpose, pls delete below stmnt after use
            triggerDismissPageAfterInterval()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        isInPage = false
    }
    
    func triggerDismissPageAfterInterval() {
        let when = DispatchTime.now() + 30
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            guard self.isInPage else{
                print("Timer Execution suspends 'isInPage' is false")
                return
            }
            
            //Pls remove user type trainee code. only for testing purpose
            if self.forUserType == "trainee" {
//                print("dismissWaitingForAcceptancePage call after 30 seconds")
//                self.dismissWaitingForAcceptancePage()
            }else if self.forUserType == "trainer" {
                print("Booking Action Complete call after 30 seconds")
                self.bookingCompleteAction(action_status: "complete")
            }
        }
    }
    
    func triggerDismissWhenNotificationReceived(notif: NSNotification) {
        
        if notif.userInfo!["type"] as! String == "1" {
            //Receiving for trainee
            print("***** Notification Type Receiving 1 ****")
            dismissWaitingForAcceptancePage()
        }else if notif.userInfo!["type"] as! String == "4" {
            print("***** Notification Type Receiving 4 ****")
            showReviewScreen()
        }
    }
    
    func showReviewScreen(){
        
        print("**** showRateViewScreen *****")
        let trainerReviewPageObj = storyboardSingleton.instantiateViewController(withIdentifier: "TrainerReviewPage") as! TrainerReviewPage
        trainerReviewPageObj.trainerProfileDetails1 = self.trainerProfileDetails
        trainerReviewPageObj.isFromWaitingForExtendRequestPage = true
        
        present(trainerReviewPageObj, animated: true, completion: nil)
    }
    
    func dismissWaitingForAcceptancePage(){
        print("Dismiss Waiting for Acceptance Page while receiving notification")
        userDefaults.set(false, forKey: "isWaitingForTrainerAcceptance")
        
        let presentingViewController: UIViewController! = self.presentingViewController
        self.dismiss(animated: false) {
            presentingViewController.dismiss(animated: false, completion: nil)
        }
    }
    
    func bookingCompleteAction(action_status: String) {
        
        let headers = [
            "token":appDelegate.Usertoken]
        
        let parameters = ["book_id" : trainerProfileDetails.Booking_id,
                          "action" : action_status,
                          "trainer_id" : trainerProfileDetails.Trainer_id
            ] as [String : Any]
        
        print("Header:\(headers)")
        print("Params:\(parameters)")
        
        CommonMethods.serverCall(APIURL: BOOKING_ACTION, parameters: parameters, headers: headers, onCompletion: { (jsondata) in
            
            print("*** Booking Complete Action Result:",jsondata)
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    if let dict = jsondata["data"]  as? NSDictionary {
                        if dict["status"] as! String == "completed" {
                            
                            userDefaults.removeObject(forKey: "TimerData")
                            userDefaults.set(false, forKey: "sessionBookedNotStarted")
                            userDefaults.removeObject(forKey: "TrainerProfileDictionary")
                            
                            TrainerProfileDetail.deleteBookingDetails()
                            appDelegate.timerrunningtime = false

                            self.showReviewScreen()
                        }
                    }
                    
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"]  as? String, buttonTitle: "Ok")
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
