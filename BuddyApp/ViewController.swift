//
//  ViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 17/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
     
        
               
        
        
        if userDefaults.value(forKey: "devicetoken") != nil {
            appDelegate.DeviceToken = userDefaults.value(forKey: "devicetoken") as! String
            print("TOKEN",appDelegate.DeviceToken)
        }else{
            appDelegate.DeviceToken = "1234567890"
        }
        
//        let when = DispatchTime.now() + 5 // change 2 to desired number of seconds
//        DispatchQueue.main.asyncAfter(deadline: when) {
//            // Your code with delay
//            self.loginCheck()
//        }

    }
    override func viewWillAppear(_ animated: Bool) {
          self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func logincheck_action(_ sender: Any) {
        
        self.loginCheck()
    }
    
    func loginCheck() {
        
        if userDefaults.value(forKey: "user_id") != nil{
            appDelegate.UserId = userDefaults.value(forKey: "user_id") as! Int
            appDelegate.Usertoken = userDefaults.value(forKey: "token") as! String
            appDelegate.USER_TYPE = userDefaults.value(forKey: "userType") as! String
            self.performSegue(withIdentifier: "tohome", sender:self)
        }else{
            self.performSegue(withIdentifier: "regorlogin", sender:self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

