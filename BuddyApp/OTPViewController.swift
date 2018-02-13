//
//  OTPViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 20/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import Alamofire

class OTPViewController: UIViewController {

    var MobileNumber = String()
    var DataDictionary: NSDictionary!
    var HeaderDict: NSDictionary!
    @IBOutlet weak var Otp_txt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = PAGE_TITLE.OTP_CODE
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func ResendCode_action(_ sender: Any) {
        
        print("Resend OTP Call")
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
        OTPCall()
    }
    
    @IBAction func changeNumber_action(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToRegister", sender: self)
    }
    
    func OTPCall(){
        CommonMethods.serverCall(APIURL: SEND_OTP, parameters: ["mobile":MobileNumber], onCompletion: { (jsondata) in
            print("1234",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    print("OTP Sent Successfully")
                }else if status == RESPONSE_STATUS.FAIL{
                    print("OTP Call Failed")
                    
                      CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                    
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    print("OTP Call Session Expired")
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    @IBAction func Submit_action(_ sender: Any) {
        
        if (Otp_txt.text?.isEmpty)! {
            print("pls enter otp")
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_ENTER_OTP, buttonTitle: "OK")
        }else {
            
            guard CommonMethods.networkcheck() else {
                
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
                return
            }
            
            CommonMethods.serverCall(APIURL: VERIFY_OTP, parameters: ["otp":Otp_txt.text!,"mobile":MobileNumber], onCompletion: { (jsondata) in
                print("OTP RESPONSE",jsondata)
                
                if let status = jsondata["status"] as? Int{
                    if status == RESPONSE_STATUS.SUCCESS{
                        print("okkkk")
                        self.RegistrationAPICall()
                    }else if status == RESPONSE_STATUS.FAIL{
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                    }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                        self.dismissOnSessionExpire()
                    }
                }
            })
        }
    }
    
    func RegistrationAPICall()  {
        
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
        CommonMethods.showProgress()

        print("Parameters in Registration API:", DataDictionary)
        CommonMethods.serverCallCopy(APIURL: REGISTER_URL, parameters: DataDictionary as! Dictionary<String, String>, headers: HeaderDict as? HTTPHeaders, onCompletion: { (jsondata) in
            print("REGISTER RESPONSE",jsondata)
            
            CommonMethods.hideProgress()
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    appDelegate.userName = (self.DataDictionary["first_name"] as? String)! + " " + (self.DataDictionary["last_name"] as? String)!
                    
                    appDelegate.Usertoken = (jsondata["token"] as? String)!
                    appDelegate.UserId = Int((jsondata["user_id"] as? String)!)!
                    
                    userDefaults.set(appDelegate.userName, forKey: "userName")
                    userDefaults.set(self.DataDictionary["email"]!, forKey: "userEmailId")
                    userDefaults.set(appDelegate.USER_TYPE, forKey: "userType")
                    userDefaults.set(Int((jsondata["user_id"] as? String)!)!, forKey: "user_id")
                    userDefaults.set((jsondata["token"] as? String)!, forKey: "token")
                    userDefaults.set(self.DataDictionary["mobile"]!, forKey: "userMobileNumber")

                    print("User ID", appDelegate.UserId)
                    
                    userDefaults.set("0.0", forKey: "walletBalance")

                    //Check whether user type is Trainer and Trainee
                    if appDelegate.USER_TYPE == "trainer"{
                        print("***** Trainer Registraion ***** ")
                        self.performSegue(withIdentifier: "initialLaunchForTrainerSegue", sender: self)
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SUCCESSFULLY_REGISTERED_AS_TRAINER, buttonTitle: "Ok")
                        
                    }else if appDelegate.USER_TYPE == "trainee"{
                        print("***** Trainee Registraion ***** ")
                        self.performSegue(withIdentifier: "toTraineeHomeAfterRegistrationSegue", sender: self)
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SUCCESSFULLY_REGISTERED_AS_TRAINEE, buttonTitle: "Ok")
                    }
                    
                }else if status == RESPONSE_STATUS.FAIL{
                     CommonMethods.alertView(view: self, title: ALERT_TITLE, message: (jsondata["message"] as? String)!, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    print("Session Expired")
                    self.dismissOnSessionExpire()
                }
            }else{
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: REQUEST_TIMED_OUT, buttonTitle: "OK")
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "initialLaunchForTrainerSegue" {
            let chooseCategoryPage =  segue.destination as! CategoryListVC
            chooseCategoryPage.isBackButtonHidden = true
            chooseCategoryPage.isInitialLaunch = true

        }else if segue.identifier == "toTraineeHomeAfterRegistrationSegue" {
            let traineeHomePage =  segue.destination as! TraineeHomePage
            traineeHomePage.isInitialLaunch = true

        }
    }
}
