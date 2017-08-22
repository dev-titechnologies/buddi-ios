//
//  ViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 17/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var TimerDict = NSDictionary()
    var numOfDays = Int()
    var TrainerProfileDictionary = NSDictionary()
    let notificationNameFCM = Notification.Name("FCMNotificationIdentifier")
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
//        let calendar = Calendar.current
        
//        let hour = calendar.component(.hour, from: date)
//        let minutes = calendar.component(.minute, from: date)
//        let seconds = calendar.component(.second, from: date)
        print("hours ",date)

        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()
        
        // Define identifier
        let notificationName = Notification.Name("FCMNotificationIdentifier")
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: notificationName, object: nil)

        
        if userDefaults.value(forKey: "TimerData") != nil {
            
            TimerDict = userDefaults.value(forKey: "TimerData") as! NSDictionary
            print("TIMERDICT",TimerDict)
            
            let date = ((TimerDict["currenttime"] as! Date).addingTimeInterval(TimeInterval(TimerDict["TimeRemains"] as! Int)))
            
            print("OLD DATE",date)
            print("CURRENT DATE",Date())
            
            
            if date > Date(){
                print("ongoing")
                 numOfDays = Date().daysBetweenDate(toDate: date)
                
                print("DIFFERENCE",numOfDays)
                self.showTimer(time: numOfDays)
            }else{
                print("completed")
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
        }else{
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
    }
    func methodOfReceivedNotification(notif: NSNotification) {
        
//        
//        self.navigationController!.pushViewController(self.storyboard!.instantiateViewController(withIdentifier: "TrainerTraineeRouteViewController") as UIViewController, animated: true)
        
      //  let notificationName = Notification.Name("FCMNotificationIdentifier")
       // NotificationCenter.default.removeObserver(self, name: notificationNameFCM, object: nil);
        
        self.TrainerProfileDictionary = CommonMethods.convertToDictionary(text: notif.userInfo!["pushData"] as! String)! as NSDictionary
        
       
        
        appDelegate.UserId = userDefaults.value(forKey: "user_id") as! Int
        appDelegate.Usertoken = userDefaults.value(forKey: "token") as! String
        appDelegate.USER_TYPE = userDefaults.value(forKey: "userType") as! String
        self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
       
    }
   
    func showTimer(time: Int) {
        appDelegate.UserId = userDefaults.value(forKey: "user_id") as! Int
        appDelegate.Usertoken = userDefaults.value(forKey: "token") as! String
        appDelegate.USER_TYPE = userDefaults.value(forKey: "userType") as! String
        self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
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
    
    func loginCheck() {
        
        if userDefaults.value(forKey: "user_id") != nil{
            appDelegate.UserId = userDefaults.value(forKey: "user_id") as! Int
            appDelegate.Usertoken = userDefaults.value(forKey: "token") as! String
            appDelegate.USER_TYPE = userDefaults.value(forKey: "userType") as! String
            
            if appDelegate.USER_TYPE == "trainer"{
                segueActionsForTrainer()
            }else if appDelegate.USER_TYPE == "trainee"{
                segueActionsForTrainee()
            }
        }else{
            self.performSegue(withIdentifier: "regorlogin", sender:self)
        }
    }
    
    func segueActionsForTrainee() {
        
        //Need to check if payment done and the session has not been started yet
        if let paymentStatus = userDefaults.value(forKey: "backupIsTransactionSuccessfull") as? Bool{
            print("Payment Status from backup:\(paymentStatus)")
            
            if paymentStatus {
                print("*** Redirecting to Show trainers page")
                self.performSegue(withIdentifier: "splashToShowTrainersPageSegue", sender:self)
            }
        }else{
            print("**** TEST Payment Check")
            self.performSegue(withIdentifier: "toTraineeHomeSegue", sender:self)
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
            self.performSegue(withIdentifier: "splashToTrainerHomePageSegue", sender: self)
        }else if pendingCount > 0 && approvedCount == 0 {
            print("*** Pending Categories Present ****")
            //Redirect to Waiting for Approval Page
            self.performSegue(withIdentifier: "splashToWaitingForApprovalSegue", sender: self)
        }else if pendingCount == 0 && approvedCount == 0 {
            //Redirect to Choose Category Page
            print("Login to Choose Category Page")
            self.performSegue(withIdentifier: "splashToChooseCategorySegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "splashToChooseCategorySegue" {
            let chooseCategoryPage =  segue.destination as! CategoryListVC
            chooseCategoryPage.isBackButtonHidden = true
        }else if segue.identifier == "splashToShowTrainersPageSegue"{
            let showTrainersOnMapPage =  segue.destination as! ShowTrainersOnMapVC
            showTrainersOnMapPage.isFromSplashScreen = true
        }else if segue.identifier == "splashToTrainerHomePageSegueRunTime" {
            let timerPage =  segue.destination as! TrainerTraineeRouteViewController
            if userDefaults.value(forKey: "TimerData") != nil {
                timerPage.seconds = numOfDays
                timerPage.TIMERCHECK = true
            }else{
                timerPage.TrainerProfileDictionary = self.TrainerProfileDictionary
                timerPage.seconds = Int(self.TrainerProfileDictionary["training_time"] as! String)!*60
                print("SECONDSSSS",timerPage.seconds)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension Date {
    func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.second], from: self, to: toDate)
        return components.second ?? 0
    }
}
