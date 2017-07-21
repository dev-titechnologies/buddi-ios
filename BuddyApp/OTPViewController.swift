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

        // Do any additional setup after loading the view.
        //josee
        
        OTPCall()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func ResendCode_action(_ sender: Any) {
        
        print("ok")
    }
    
    @IBAction func changeNumber_action(_ sender: Any) {
    }
    
    @IBAction func Submit_action(_ sender: Any) {
        
        if (Otp_txt.text?.isEmpty)!
        {
            print("pls enter otp")
        }
        else
        {
            
        }
        
        CommonMethods.serverCall(APIURL: "register/verifyOTP", parameters: ["otp":Otp_txt.text!,"mobile":MobileNumber], headers: nil, onCompletion: { (jsondata) in
            print("OTP RESPONSE",jsondata)
           // print(jsondata["token"].stringValue)
           
            if let status = jsondata["status"] as? Int{
                if status == 1{
                    
                    print("okkkk")
                    self.RegistrationAPICall()
                    
                    
                }
            }
        }
            )}
    
    func OTPCall(){
        CommonMethods.serverCall(APIURL: "register/sendOTP", parameters: ["mobile":MobileNumber], headers: nil, onCompletion: { (jsondata) in
            print("1234",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == 1{
                    
                      print("okkkk")
                
                
                }
            }
            
        })

    }
    func RegistrationAPICall()  {
        
        CommonMethods.serverCall(APIURL: "register/register", parameters: DataDictionary as! Dictionary<String, String>, headers: HeaderDict as? HTTPHeaders, onCompletion: { (jsondata) in
            print("REGISTER RESPONSE",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == 1{
                    
                appDelegate.Usertoken = (jsondata["token"] as? String)!
                    
                   CommonMethods.alertView(view: self, title: "SUCCESS", message: "Registration successfull", buttonTitle: "Ok")
                    
                }
                else if status == 2
                {
                     CommonMethods.alertView(view: self, title: "FAIL", message: (jsondata["message"] as? String)!, buttonTitle: "Ok")
                }
            }

            
        })

        
        
    }
    
}
