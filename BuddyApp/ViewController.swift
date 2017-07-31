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
     
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()
        
        if userDefaults.value(forKey: "devicetoken") != nil {
            appDelegate.DeviceToken = userDefaults.value(forKey: "devicetoken") as! String
            print("TOKEN",appDelegate.DeviceToken)
        }else{
            appDelegate.DeviceToken = "1234567890"
        }
        
        let when = DispatchTime.now() + 3 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            self.loginCheck()
        }
        

    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         self.navigationController?.isNavigationBarHidden = false
    }
    
    func networkStatusChanged(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        print(userInfo!)
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
    
    func segueActionsForTrainer() {
        
        let approvedCount = userDefaults.value(forKey: "approvedCategoryCount") as! Int
        let pendingCount = userDefaults.value(forKey: "pendingCategoryCount") as! Int
        
        print("Approved Count:",approvedCount)
        print("Pending Count:",pendingCount)

        if approvedCount > 0 {
            print("*** Approved Categories Present ****")
            //Need to redirect to Home Screen
            self.performSegue(withIdentifier: "tohome", sender: self)
        }
        
        if pendingCount > 0 && approvedCount == 0 {
            print("*** Pending Categories Present ****")
            //Redirect to Waiting for Approval Page
            self.performSegue(withIdentifier: "splashToWaitingForApprovalSegue", sender: self)
        }else if pendingCount == 0 && approvedCount == 0 {
            //Redirect to Choose Category Page
            print("Login to Choose Category Page")
            self.performSegue(withIdentifier: "splashToChooseCategorySegue", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

