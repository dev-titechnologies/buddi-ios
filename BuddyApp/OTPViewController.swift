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

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func ResendCode_action(_ sender: Any) {
        
        print("Resend OTP Call")
        OTPCall()
    }
    
    @IBAction func changeNumber_action(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToRegister", sender: self)
    }
    
    func OTPCall(){
        CommonMethods.serverCall(APIURL: SEND_OTP, parameters: ["mobile":MobileNumber], headers: nil, onCompletion: { (jsondata) in
            print("1234",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    print("OTP Sent Successfully")
                }else if status == RESPONSE_STATUS.FAIL{
                    print("OTP Call Failed")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    print("OTP Call Session Expired")
                }
            }
        })
    }
    
    @IBAction func Submit_action(_ sender: Any) {
        
        if (Otp_txt.text?.isEmpty)! {
            print("pls enter otp")
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_ENTER_OTP, buttonTitle: "OK")
        }else {
            CommonMethods.serverCall(APIURL: VERIFY_OTP, parameters: ["otp":Otp_txt.text!,"mobile":MobileNumber], headers: nil, onCompletion: { (jsondata) in
                print("OTP RESPONSE",jsondata)
                
                if let status = jsondata["status"] as? Int{
                    if status == RESPONSE_STATUS.SUCCESS{
                        print("okkkk")
                        self.RegistrationAPICall()
                    }
                }
            })
        }
    }
    
    func RegistrationAPICall()  {
        
        CommonMethods.serverCall(APIURL: REGISTER_URL, parameters: DataDictionary as! Dictionary<String, String>, headers: HeaderDict as? HTTPHeaders, onCompletion: { (jsondata) in
            print("REGISTER RESPONSE",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    appDelegate.Usertoken = (jsondata["token"] as? String)!
                    CommonMethods.alertView(view: self, title: "SUCCESS", message: "Registration successfull", buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.FAIL{
                     CommonMethods.alertView(view: self, title: "FAIL", message: (jsondata["message"] as? String)!, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    print("Session Expired")
                }
            }
        })
    }
}
