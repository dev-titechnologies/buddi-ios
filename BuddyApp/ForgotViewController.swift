//
//  ForgotViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 31/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class ForgotViewController: UIViewController {
    @IBOutlet weak var Password_txt: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Forgot password"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ResetPW_action(_ sender: Any) {
        
        if Password_txt.text!.isEmpty {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please enter email", buttonTitle: "Ok")
        }else
        {
            ForgotAPI()
        }
        
        
        
    }
    
  func ForgotAPI(){
    
    let parameters = [
    "email": self.Password_txt.text!]
    
    let headers = [
        "device_id": appDelegate.DeviceToken,
        "device_imei": UIDevice.current.identifierForVendor!.uuidString,
        "device_type": "ios",
        ]

        print("parameters",parameters)
        CommonMethods.serverCall(APIURL: "login/forgotPassword", parameters: parameters, headers: headers , onCompletion: { (jsondata) in
            print("FORGOT RESPONSE",jsondata)
            
            CommonMethods.hideProgress()
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SUCCESSFULLY_SENT_PASSWORD, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        
        })
    }
}
