//
//  ExtendSessionRequestPage.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 13/09/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import Alamofire
import Braintree
import BraintreeDropIn

class ExtendSessionRequestPage: UIViewController {

    @IBOutlet weak var btnYesExtend: UIButton!
    @IBOutlet weak var btnNoExtend: UIButton!
    @IBOutlet weak var btnSession40Minutes: UIButton!
    @IBOutlet weak var btnSession1Hour: UIButton!
    
    @IBOutlet weak var extendAlertView: CardView!
    @IBOutlet weak var sessionAlertView: CardView!
    
    var extendingSessionDuration = String()
    var isExtending = Bool()
    
    var bookingId = String()
    var trainerId = String()
    
    //Payment Variables
    var isPaymentSuccess = Bool()
    var transactionId = String()
    var transactionAmount = String()
    var transactionStatus = String()
    
    var trainerProfileDetails = TrainerProfileModal()
    let notificationName = Notification.Name("SessionNotification")

    //MARK: - VIEW CYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        addingShadow()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedPushNotification), name: notificationName, object: nil)

//        let when = DispatchTime.now() + 30
//        DispatchQueue.main.asyncAfter(deadline: when) {
//            self.dismissExtendSessionRequestPage()
//        }
    }
    
    func receivedPushNotification(notif: NSNotification){
        
        print("Notification Received in Waiting for Acceptance Page:\(notif)")
        if notif.userInfo!["pushData"] as! String == "4"{
            showReviewScreen()
        }
    }
    
    func addingShadow() {
        btnYesExtend.addShadowView()
        btnNoExtend.addShadowView()
        btnSession40Minutes.addShadowView()
        btnSession1Hour.addShadowView()
    }

    @IBAction func extendYesAction(_ sender: Any) {
        sessionAlertView.isHidden = false
        extendAlertView.isHidden = true
    }
    
    @IBAction func extendNoAction(_ sender: Any) {
        
        bookingCompleteAction(action_status: "complete")
    }
    
    @IBAction func session40MinutesAction(_ sender: Any) {
        extendingSessionDuration = "40"
        btnSession40Minutes.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        btnSession1Hour.backgroundColor = .white
    }
    
    @IBAction func session1HourAction(_ sender: Any) {
        extendingSessionDuration = "60"
        btnSession40Minutes.backgroundColor = .white
        btnSession1Hour.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
    }
    
    @IBAction func extendSessionCancelAction(_ sender: Any) {
       // dismissExtendSessionRequestPage()
        showReviewScreen()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        (isPaymentSuccess ? extendSession() : getClientToken())
    }
    
    func dismissExtendSessionRequestPage(){
        print("*** Dismiss Extend Session Request Page on click NO")
        
        let presentingViewController: UIViewController! = self.presentingViewController
        self.dismiss(animated: false) {
            presentingViewController.dismiss(animated: false, completion: nil)
            self.showReviewScreen()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - PAYMENT FUNCTIONS
    
    func getClientToken() {
      
        if let clientToken = userDefaults.value(forKey: "clientTokenForPayment") as? String{
            fetchExistingPaymentMethod(clientToken: clientToken)
        }else{
            print("**** Client token not present catch in extend session page")
        }
    }
    
    func fetchExistingPaymentMethod(clientToken: String) {
        
        print("***** Fetch Existing payment method *****")
        CommonMethods.showProgress()
        BTDropInResult.fetch(forAuthorization: clientToken, handler: { (result, error) in
            if (error != nil) {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PAYMENT_METHOD_FETCH_ERROR, buttonTitle: "OK")
                print("ERROR")
            } else if let result = result {
                
                let selectedPaymentOptionType = result.paymentOptionType
                let selectedPaymentMethod = result.paymentMethod
                let selectedPaymentMethodIcon = result.paymentIcon
                let selectedPaymentMethodDescription = result.paymentDescription
                
                print("Method: \(String(describing: selectedPaymentMethod))")
                print("paymentOptionType: \(selectedPaymentOptionType.rawValue)")
                print("paymentDescription: \(selectedPaymentMethodDescription)")
                print("paymentIcon: \(selectedPaymentMethodIcon)")
                
                if selectedPaymentMethod == nil{
                    CommonMethods.hideProgress()
                    return
                }
                
                let nounce = result.paymentMethod?.nonce
                CommonMethods.hideProgress()
                print("New Received nonce:\(String(describing: nounce))")
                self.postNonceToServer(paymentMethodNonce: nounce!)
            }
        })
    }
    
    func postNonceToServer(paymentMethodNonce: String) {
        
        //DEMO NONCE :"fake-valid-nonce"
        print("Nounce:\(paymentMethodNonce)")
        let headers = [
            "token":appDelegate.Usertoken]
        
        let parameters =  ["nonce" : paymentMethodNonce,
                           "training_time" : extendingSessionDuration
            ] as [String : Any]
        print("PARAMS: \(parameters)")
        
        let FinalURL = SERVER_URL + PAYMENT_CHECKOUT
        print("Final Server URL:",FinalURL)
        
        CommonMethods.showProgress()
        Alamofire.request(FinalURL, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON {
            response in
            print("Checkout page Response:\(response)")
            
            CommonMethods.hideProgress()
            if let jsondata = response.value as? [String: AnyObject] {
                print(jsondata)
                
                if let status = jsondata["status"] as? Int{
                    if status == RESPONSE_STATUS.SUCCESS{
                        
                        self.navigationItem.hidesBackButton = true
                        
                        self.isPaymentSuccess = true
                        let transactionDict = jsondata["data"]  as! NSDictionary
                        self.transactionId = transactionDict["transactionId"] as! String
                        self.transactionAmount = transactionDict["amount"] as! String
                        self.transactionStatus = transactionDict["status"] as! String
                        
                        let alert = UIAlertController(title: ALERT_TITLE, message: PAYMENT_SUCCESSFULL, preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                            self.extendSession()
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    }else if status == RESPONSE_STATUS.FAIL{
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                    }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                        self.dismissOnSessionExpire()
                    }
                }else{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: REQUEST_TIMED_OUT, buttonTitle: "OK")
                }
            }
        }
    }
    
    //MARK: - EXTEND SESSION SERVER CALL
    
    func extendSession() {
        
        let headers = [
            "token":appDelegate.Usertoken]
        
        let parameters =  ["book_id" : bookingId,
                           "transaction_id" : transactionId,
                           "extended_time" : extendingSessionDuration
            ] as [String : Any]
        
        print("PARAMS: \(parameters)")
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: EXTEND_SESSION, parameters: parameters, headers: headers, onCompletion: { (jsondata) in
            
            print("*** Extend Session Result:",jsondata)
            
            CommonMethods.hideProgress()
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{

                    self.dismissExtendSessionRequestPage()
                
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    //MARK: - BOOKING COMPLETE ACTION
    
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
//                            self.dismissExtendSessionRequestPage()
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
    
    func showReviewScreen(){
        
        print("**** showRateViewScreen *****")
        let trainerReviewPageObj = storyboardSingleton.instantiateViewController(withIdentifier: "TrainerReviewPage") as! TrainerReviewPage
        trainerReviewPageObj.trainerProfileDetails1 = self.trainerProfileDetails
        trainerReviewPageObj.isFromExtendPage = true
        
        present(trainerReviewPageObj, animated: true, completion: nil)
    }
}


