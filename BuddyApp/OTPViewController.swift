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

    @IBOutlet weak var Otp_txt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //josee
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func ResendCode_action(_ sender: Any) {
    }
    
    @IBAction func changeNumber_action(_ sender: Any) {
    }
    
    @IBAction func Submit_action(_ sender: Any) {
        
        CommonMethods.serverCall(APIURL: "register/sendOTP", parameters: ["mobile":"+919400657618"], headers: nil, onCompletion: { (jsondata) in
            print("1234",jsondata)
            print(jsondata["token"].stringValue)
        })
    }
    
    func OTPCall(){
        CommonMethods.serverCall(APIURL: "register/sendOTP", parameters: ["mobile":"+91 9400657618"], headers: nil, onCompletion: { (jsondata) in
            print("1234",jsondata)
            print(jsondata["token"].stringValue)
        })

    }
}
