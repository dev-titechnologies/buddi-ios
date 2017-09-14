//
//  ViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 17/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController,FCMTokenReceiveDelegate {
    
    var TimerDict = NSDictionary()
    var numOfDays = Int()
    var TrainerProfileDictionary: NSDictionary!
    let notificationNameFCM = Notification.Name("FCMNotificationIdentifier")
    let AcceptNotification = Notification.Name("AcceptNotification")
    var selectedTrainerProfileDetails : TrainerProfileModal = TrainerProfileModal()
    var ApsBody = String()
   
    //MARK: - VIEW CYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()
           appDelegate.delegateFCM = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()

        NotificationCenter.default.addObserver(self, selector: #selector(self.GoTimerPageInActive_Notification), name: notificationNameFCM, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.AcceptRejactScreenNotification), name: AcceptNotification, object: nil)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         self.navigationController?.isNavigationBarHidden = false
    }
    
    func initilizeSessionChecks() {

        if appDelegate.TrainerProfileDictionary != nil{
            //  BOOKED A SESSION
            

            self.GoTimerPageFromKilledState_Notification(dict:appDelegate.TrainerProfileDictionary)
        }else{
                   
            if userDefaults.value(forKey: "TimerData") != nil {
                
                //   RUNNING SESSION
                TimerDict = userDefaults.value(forKey: "TimerData") as! NSDictionary
                print("TIMERDICT",TimerDict)
                
                let date = ((TimerDict["currenttime"] as! Date).addingTimeInterval(TimeInterval(TimerDict["TimeRemains"] as! Int)))
                
                print("OLD DATE",date)
                print("CURRENT DATE",Date())
                
                if date > Date(){
                    print("ongoing")
                    numOfDays = Date().daysBetweenDate(toDate: date)
                    
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
                        
                        userDefaults.removeObject(forKey: "TimerData")
                        TrainerProfileDetail.deleteBookingDetails()
                        if userDefaults.value(forKey: "devicetoken") != nil {
                            appDelegate.DeviceToken = userDefaults.value(forKey: "devicetoken") as! String
                            print("TOKEN",appDelegate.DeviceToken)
                        }else{
                            appDelegate.DeviceToken = "1234567890"
                        }
                        
                        let when = DispatchTime.now() + 3 
                        DispatchQueue.main.asyncAfter(deadline: when) {
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
                    
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.loginCheck()
                    }
                }
            }else{

            // BOOKED BUT NOT STARTED
            if userDefaults.bool(forKey: "sessionBookedNotStarted"){
                print("SESSION BOOKED NOT STARTED")
                
                if let heroObject = userDefaults.value(forKey: "TrainerProfileDictionary") as? NSData {
                  let hero = NSKeyedUnarchiver.unarchiveObject(with: heroObject as Data) as! NSDictionary
                    self.GoTimerPageFromKilledState_Notification(dict: hero)
                }
            }
            else{
                if userDefaults.value(forKey: "devicetoken") != nil {
                    appDelegate.DeviceToken = userDefaults.value(forKey: "devicetoken") as! String
                    print("TOKEN111",appDelegate.DeviceToken)
                }else{
                    print("TOKEN NILL")
                    appDelegate.DeviceToken = "1234567890"
                }
                let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.loginCheck()
                    }
                }
            }
        }
    }
    
    //MARK: - FCM TOKEN DELEGATE FUNCTION
    
    func tokenReceived() {
        print("======= Token Received Function Call in ViewController =======")
       // CommonMethods.alertView(view:self, title: ALERT_TITLE, message: "tokenReceived", buttonTitle: "Ok")
        initilizeSessionChecks()
    }
    
    //MARK: - OTHER FUNCTIONS
    
    func AcceptRejactScreenNotification(notif: NSNotification) {
        
         self.TrainerProfileDictionary = notif.userInfo!["profiledata"] as! NSDictionary
        
        print("TRAINERPRO DICT",self.TrainerProfileDictionary)
        
        userDefaults.set(true, forKey: "sessionBookedNotStarted")
        userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: self.TrainerProfileDictionary), forKey: "TrainerProfileDictionary")
        
         self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
        
    }
    
    func GoTimerPageInActive_Notification(notif: NSNotification) {
        
      
        
        
        appDelegate.UserId = userDefaults.value(forKey: "user_id") as! Int
        appDelegate.Usertoken = userDefaults.value(forKey: "token") as! String
        appDelegate.USER_TYPE = userDefaults.value(forKey: "userType") as! String
        
        
     
        
        self.TrainerProfileDictionary = CommonMethods.convertToDictionary(text:notif.userInfo!["pushData"] as! String)! as NSDictionary
        
        print("TRAINING DATA",self.TrainerProfileDictionary)
        print("TYPEE",notif.userInfo!["type"]!)
        print("TYPEE121",notif.userInfo!["aps"]!)
        
       
        
        userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: self.TrainerProfileDictionary), forKey: "TrainerProfileDictionary")
        
       
        
        if notif.userInfo!["type"] as! String == "1" {
            //Booking Request Accepted Push received
            
            let trainerProfileModelObj = TrainerProfileModal()
            
            self.selectedTrainerProfileDetails = trainerProfileModelObj.getTrainerProfileModelFromDict(dictionary: self.TrainerProfileDictionary as! Dictionary<String, Any>)
            TrainerProfileDetail.createProfileBookingEntry(TrainerProfileModal: self.selectedTrainerProfileDetails)
            self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
            
        }else if notif.userInfo!["type"] as! String == "5"{
            
             ApsBody = notif.userInfo!["aps"]! as! String
            
            AcceptOrDeclineScreen()
        }
    }
    
    func GoTimerPageFromKilledState_Notification(dict: NSDictionary) {
        if dict["type"] as? String == "1" {

        
        self.TrainerProfileDictionary = dict
        appDelegate.UserId = userDefaults.value(forKey: "user_id") as! Int
        appDelegate.Usertoken = userDefaults.value(forKey: "token") as! String
        appDelegate.USER_TYPE = userDefaults.value(forKey: "userType") as! String
        self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
        }
        else if dict["type"] as? String == "5"{
            
            self.TrainerProfileDictionary = CommonMethods.convertToDictionary(text:dict["pushData"]as! String)! as NSDictionary
          
            appDelegate.UserId = userDefaults.value(forKey: "user_id") as! Int
            appDelegate.Usertoken = userDefaults.value(forKey: "token") as! String
            appDelegate.USER_TYPE = userDefaults.value(forKey: "userType") as! String

            
            userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: self.TrainerProfileDictionary), forKey: "TrainerProfileDictionary")
            
            ApsBody = (dict["aps"]! as! String)
           
            AcceptOrDeclineScreen()
            self.performSegue(withIdentifier: "splashToTrainerHomePageSegue", sender: self)
            
        }
    }
    
    func showTimer(time: Int) {
        appDelegate.UserId = userDefaults.value(forKey: "user_id") as! Int
        appDelegate.Usertoken = userDefaults.value(forKey: "token") as! String
        appDelegate.USER_TYPE = userDefaults.value(forKey: "userType") as! String
        self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
    }
    
    func AcceptOrDeclineScreen(){
       let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "AcceptOrDeclineRequestPage") as! AcceptOrDeclineRequestPage
        
        vc.APSBody = ApsBody
        present(vc, animated: true, completion: nil)
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
                if appDelegate.USER_TYPE == "trainer"{
                    timerPage.TrainerProfileDictionary = self.TrainerProfileDictionary
                }else{
                    timerPage.trainerProfileDetails = selectedTrainerProfileDetails
                }
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
