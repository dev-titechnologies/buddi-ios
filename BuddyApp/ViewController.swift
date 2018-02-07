//
//  ViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 17/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKShareKit


class ViewController: UIViewController,FCMTokenReceiveDelegate {
    
    var TimerDict = NSDictionary()
    var numOfDays = Int()
    var TrainerProfileDictionary: NSDictionary!
    let notificationNameFCM = Notification.Name("FCMNotificationIdentifier")
    let AcceptNotification = Notification.Name("AcceptNotification")
    var selectedTrainerProfileDetails : TrainerProfileModal = TrainerProfileModal()
    var ApsBody = String()
    var notificationType = String()
    var PushChatBool = Bool()
   
    var profileArray = Array<TrainerProfileDetail>()
    var trainerProfileDetails = TrainerProfileModal()
    
    var isFromPushNotificationClick_AppKilledState = Bool()
   

    //MARK: - VIEW CYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDidLoad ViewController")
        
        appDelegate.delegateFCM = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        CommonMethods.googleAnalyticsScreenTracker(screenName: "ViewController Screen")
        let notificationName = Notification.Name("SessionNotification")
        
        let GlobelTimerNotification = Notification.Name("GlobelTimerNotification")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.GlobelTimerNotification), name: GlobelTimerNotification, object: nil)

        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()

        NotificationCenter.default.addObserver(self, selector: #selector(self.GoTimerPageInActive_Notification), name: notificationNameFCM, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.AcceptRejactScreenNotification), name: AcceptNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.GoTimerPageInActive_Notification), name: notificationName, object: nil)
    
        print("***** Internet Connectivity:\(CommonMethods.networkcheck())")
        
//        if isFromPushNotificationClick_AppKilledState {
//            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "isFromPushNotificationClick_AppKilledState", buttonTitle: "OK")
//            initilizeSessionChecks()
//        }
        
//        initilizeSessionChecks()
        
//        if userDefaults.value(forKey: "devicetoken") != nil {
//            print("***** initilizeSessionChecks Call in ViewController ******")
//            initilizeSessionChecks()
//        }

//        if !CommonMethods.networkcheck() && userDefaults.value(forKey: "devicetoken") as! String != "" {
//            print("No Network and Device token is empty in userDefaults")
//            initilizeSessionChecks()
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // self.CancelStopBool = false
         self.navigationController?.isNavigationBarHidden = false
    }
    
    func initilizeSessionChecks() {

        print("***** initilizeSessionChecks Call in ViewController ******")
        
//        guard !userDefaults.bool(forKey: "pushClickSessionStopFromKilledState") else{
//            
//            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "pushClickSessionStopFromKilledState:\(userDefaults.bool(forKey: "pushClickSessionStopFromKilledState"))", buttonTitle: "OK")
//
//            userDefaults.removeObject(forKey: "pushClickSessionStopFromKilledState")
//            self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
//            return
//        }
        
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
                    print("Ongoing")
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
                            print("************ DUMMY DEVICE TOKEN HAS BEEN INSERTED VIEWCONTROLLER PAGE ************")
                            appDelegate.DeviceToken = "1234567890"
                        }
                        
                        let when = DispatchTime.now() + 3 
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            self.loginCheck()
                        }
                    }
                }
//                else if userDefaults.value(forKey: "isShowingWaitingForExtendRequest") != nil{
//                    
//                    let isShowingWaitingForExtendRequest = userDefaults.value(forKey: "isShowingWaitingForExtendRequest") as? Bool
//                    
//                    print("isShowingWaitingForExtendRequest:\(String(describing: isShowingWaitingForExtendRequest))")
//                    
//                    if isShowingWaitingForExtendRequest!{
//                        self.showTimer(time: 0)
//                    }
//                }
                else{
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
                }else{
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
        initilizeSessionChecks()
    }
    
    //MARK: - OTHER FUNCTIONS
    
    func AcceptRejactScreenNotification(notif: NSNotification) {
        
        print("*** AcceptRejactScreenNotification Received ****")
        self.TrainerProfileDictionary = notif.userInfo!["profiledata"] as! NSDictionary
        print("TRAINERPRO DICT",self.TrainerProfileDictionary)
        
        userDefaults.set(true, forKey: "sessionBookedNotStarted")

        userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: self.TrainerProfileDictionary), forKey: "TrainerProfileDictionary")
         self.PushChatBool = false
         self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
    }
    
    //MARK: - NOTIFICATION HANDLERS
    
    func GlobelTimerNotification(notif: NSNotification) {
        
        
        let currentvc = navigationController?.visibleViewController
        print("CURRENT VIEW",currentvc!)
        
        if currentvc is TrainerTraineeRouteViewController{
            
            print("ROUTE PAGE")
        }else{
            print("OTHER PAGE")
            
            print("GlobelTimerNotification")
            
            if appDelegate.USER_TYPE == "trainee" {
            }else{
                // userDefaults.set(true, forKey: "isShowingWaitingForExtendRequest")
            }
            numOfDays = 0
            self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
            
        }
    }
    
    func GoTimerPageInActive_Notification(notif: NSNotification) {
        
         let currentvc = navigationController?.visibleViewController
        print("CURRENT VIEW",currentvc!)
            
            if currentvc is TrainerTraineeRouteViewController{
                
                print("ROUTE PAGE")
            }else{
                print("OTHER PAGE")
            }
        
        print("*** GoTimerPageInActive_Notification ***")
        print("Notification received : \(notif)")
        
//        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "GoTimerPageInActive_Notification", buttonTitle: "OK")
        
        appDelegate.UserId = userDefaults.value(forKey: "user_id") as! Int
        appDelegate.Usertoken = userDefaults.value(forKey: "token") as! String
        appDelegate.USER_TYPE = userDefaults.value(forKey: "userType") as! String
        
        notificationType = notif.userInfo!["type"] as! String
                
        if notificationType == "1" {
            
            //Booking Request Accepted Push received
            
            self.TrainerProfileDictionary = CommonMethods.convertToDictionary(text:notif.userInfo!["pushData"] as! String)! as NSDictionary
            
            print("TRAINING DATA",self.TrainerProfileDictionary)
            userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: self.TrainerProfileDictionary), forKey: "TrainerProfileDictionary")
            
            let trainerProfileModelObj = TrainerProfileModal()
            self.selectedTrainerProfileDetails = trainerProfileModelObj.getTrainerProfileModelFromDict(dictionary: self.TrainerProfileDictionary as! Dictionary<String, Any>)
            
            let profileDict = self.selectedTrainerProfileDetails
            let sessionDuration = self.TrainerProfileDictionary["training_time"] as! String
            let categoryName = CategoryDB.getCategoryByCategoryID(categoryId: String(describing: self.TrainerProfileDictionary["cat_id"]!))
            let trainingLocation = self.TrainerProfileDictionary["pick_location"] as! String

            let socialMediaShareMessage = CommonMethods.socialMediaPostTextForTrainee(sessionDuration: sessionDuration, inCategory: categoryName, firstname: profileDict.firstName, lastname: profileDict.lastName, atLocation: trainingLocation)
            
            //Post Tweet Automatically to Twitter
            if userDefaults.bool(forKey: "isTwitterAutoShare"){
                CommonMethods.postTweetAutomatically(tweetMessage: socialMediaShareMessage, userId: userDefaults.value(forKey: "TwitterUserId") as! String)
            }
            
            //Facebook Post Automatically Test
            if userDefaults.bool(forKey: "isFacebookAutoShare"){
                CommonMethods.postToFacebook(message: socialMediaShareMessage)
            }
            
            TrainerProfileDetail.createProfileBookingEntry(TrainerProfileModal: self.selectedTrainerProfileDetails)
            self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
            
        }else if notificationType == "2"{
            print("** Session has started in Viewcontroller **")
            
            if currentvc is TrainerTraineeRouteViewController{
                
                print("ROUTE PAGE")
            }else{
                print("OTHER PAGE")
                
                
                
                let alert = UIAlertController(title: ALERT_TITLE, message: "Session Started", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                    
                    
                    if let trainerProfileDictData = userDefaults.value(forKey: "TrainerProfileDictionary") as? NSData {
                        let trainerProfileDict = NSKeyedUnarchiver.unarchiveObject(with: trainerProfileDictData as Data) as! NSDictionary
                        print("trainerProfileDict:\(trainerProfileDict)")
                        self.TrainerProfileDictionary = trainerProfileDict
                        
                        print("appDelegate.isInSessionRoutePageAppDelegate:\(appDelegate.isInSessionRoutePageAppDelegate)")
                        if !appDelegate.isInSessionRoutePageAppDelegate {
                            print("** Session Start Notification handling from ViewController **")
                            self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
                        }
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
            
            

//            let trainerProfileModelObj = TrainerProfileModal()
//            self.selectedTrainerProfileDetails = trainerProfileModelObj.getTrainerProfileModelFromDict(dictionary: self.TrainerProfileDictionary as! Dictionary<String, Any>)
//            TrainerProfileDetail.createProfileBookingEntry(TrainerProfileModal: self.selectedTrainerProfileDetails)
//            self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
            
        }else if notificationType == "3"{
            
            if currentvc is TrainerTraineeRouteViewController{
                
                print("ROUTE PAGE")
                appDelegate.CancelStopBool = false
            }else{
                print("OTHER PAGE")
                
                let dict = ((notif.userInfo!["status"] as! NSDictionary)["alert"]! as! NSDictionary)["title"]! as! String
                
                print("dicttt",dict)
                
                
                let alert = UIAlertController(title: ALERT_TITLE, message: dict, preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                    
                    
                    print("** Session stopped or cancelled in Viewcontroller **")
                    
                    
                    if let trainerProfileDictData = userDefaults.value(forKey: "TrainerProfileDictionary") as? NSData {
                        let trainerProfileDict = NSKeyedUnarchiver.unarchiveObject(with: trainerProfileDictData as Data) as! NSDictionary
                        print("trainerProfileDict:\(trainerProfileDict)")
                        self.TrainerProfileDictionary = trainerProfileDict
                        
                        print("appDelegate.isInSessionRoutePageAppDelegate:\(appDelegate.isInSessionRoutePageAppDelegate)")
                        
                        appDelegate.CancelStopBool = true
                        if !appDelegate.isInSessionRoutePageAppDelegate {
                            print("** Session Start Notification handling from ViewController **")
                            self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
                        }
                    }else{
                        print("DATA NIL ")
                        appDelegate.CancelStopBool = false
                    }
                    
                    
                }))
                self.present(alert, animated: true, completion: nil)
                

            }
            
            
            
            
            
            
            
            
            
            
            
            
            //            let trainerProfileModelObj = TrainerProfileModal()
            //            self.selectedTrainerProfileDetails = trainerProfileModelObj.getTrainerProfileModelFromDict(dictionary: self.TrainerProfileDictionary as! Dictionary<String, Any>)
            //            TrainerProfileDetail.createProfileBookingEntry(TrainerProfileModal: self.selectedTrainerProfileDetails)
            //            self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
            
        }
        
        else if notificationType == "5"{
            self.TrainerProfileDictionary = CommonMethods.convertToDictionary(text:notif.userInfo!["pushData"] as! String)! as NSDictionary
            print("TRAINING DATA",self.TrainerProfileDictionary)
            userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: self.TrainerProfileDictionary), forKey: "TrainerProfileDictionary")
            ApsBody = notif.userInfo!["aps"]! as! String
            AcceptOrDeclineScreen()
        }else if notificationType == "6"{
        }
        else if notificationType == "8"{
            
            if appDelegate.chatpushnotificationBool{
                
            }else{
                
                
                // Customizations
                rnnotification.titleFont = UIFont(name: "AvenirNext-Bold", size: 10)!
                rnnotification.titleTextColor = UIColor.blue
                rnnotification.iconSize = CGSize(width: 46, height: 46) // Optional setup
                
                rnnotification.show(withImage: nil,
                                    title: "Buddi",
                                    message: "New message received!",
                                    onTap: {
                                        print("Did tap notification")
                                        
                                        if userDefaults.bool(forKey: "sessionBookedNotStarted"){
                                            print("SESSION BOOKED NOT STARTED")
                                            
                                            if let heroObject = userDefaults.value(forKey: "TrainerProfileDictionary") as? NSData {
                                                let hero = NSKeyedUnarchiver.unarchiveObject(with: heroObject as Data) as! NSDictionary
                                                
                                                self.PushChatBool = true
                                                self.GoTimerPageFromKilledState_Notification(dict: hero)
                                            }
                                        }
                })
                
                
            }
        }

    }
    
    func GoTimerPageFromKilledState_Notification(dict: NSDictionary) {
        
        print("*** GoTimerPageFromKilledState_Notification ***")
        print("Dictionary received:",dict)
        
//        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "GoTimerPageFromKilledState_Notification:\(String(describing: dict["type"] as? String))", buttonTitle: "OK")
        
        appDelegate.UserId = userDefaults.value(forKey: "user_id") as! Int
        appDelegate.Usertoken = userDefaults.value(forKey: "token") as! String
        appDelegate.USER_TYPE = userDefaults.value(forKey: "userType") as! String
        
        if (dict["type"] as? String) != nil {
            
            notificationType = (dict["type"] as? String)!
            
            if notificationType == "2"{
                //Session has been Started
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Notification 2 has been received:\(TrainerProfileDictionary)", buttonTitle: "OK")
                
            }else if notificationType == "5" {

                //Accept or reject training request
                self.TrainerProfileDictionary = CommonMethods.convertToDictionary(text:dict["pushData"]as! String)! as NSDictionary
                
                userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: self.TrainerProfileDictionary), forKey: "TrainerProfileDictionary")
                
                ApsBody = (dict["aps"]! as! String)
                
                AcceptOrDeclineScreen()
                self.performSegue(withIdentifier: "splashToTrainerHomePageSegue", sender: self)

            }else if notificationType == "3" {
                self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
            }
        }else{
            let trainerProfileModelObj = TrainerProfileModal()

            self.TrainerProfileDictionary = dict
            
            if appDelegate.USER_TYPE == "trainer"{
                
            }else{
                //trainee
                self.selectedTrainerProfileDetails = trainerProfileModelObj.getTrainerProfileModelFromDict(dictionary: self.TrainerProfileDictionary as! Dictionary<String, Any>)
            }
           
            self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
        }
    }
    
    func FetchFromDb() {
        
        if let result = TrainerProfileDetail.fetchBookingDetails() {
            self.profileArray = result as! Array<TrainerProfileDetail>
            
            guard self.profileArray.count > 0 else {
                print("Profile array count is 0, hence returns")
                return
            }
            
            let bookingObj = self.profileArray[0]
            print("FROM DB",bookingObj)

            self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
        }
    }
    
    func showTimer(time: Int) {
        appDelegate.UserId = userDefaults.value(forKey: "user_id") as! Int
        appDelegate.Usertoken = userDefaults.value(forKey: "token") as! String
        appDelegate.USER_TYPE = userDefaults.value(forKey: "userType") as! String
        self.performSegue(withIdentifier: "splashToTrainerHomePageSegueRunTime", sender: self)
    }
    
    func AcceptOrDeclineScreen(){
        
        let vc = storyboardSingleton.instantiateViewController(withIdentifier: "AcceptOrDeclineRequestPage") as! AcceptOrDeclineRequestPage
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
//                print("*** Redirecting to Show trainers page")
//                self.performSegue(withIdentifier: "splashToShowTrainersPageSegue", sender:self)
                
                //Latest change. If payment success and killed the app. user will be again launch to home page for next booking with the previous payment details.
                self.performSegue(withIdentifier: "toTraineeHomeSegue", sender:self)
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
            // JOSE 2-2-2018
           //  timerPage.CancelStopBool = self.CancelStopBool
            ////
            
            print("*** Prepare for Segue splashToTrainerHomePageSegueRunTime ****")
            if userDefaults.value(forKey: "TimerData") != nil {
                print("** Timer Data check in ViewController is : True")
                timerPage.seconds = numOfDays
                timerPage.TIMERCHECK = true
                
            }else{
                print("** Timer Data check in ViewController is : False")
                if appDelegate.USER_TYPE == "trainer"{
                    timerPage.TrainerProfileDictionary = self.TrainerProfileDictionary
                }else{
                    timerPage.trainerProfileDetails = selectedTrainerProfileDetails
                }
                
                let secondsCopy = Int(self.TrainerProfileDictionary["training_time"] as! String)! * 60
                print("secondsCopy:\(secondsCopy)")
                timerPage.seconds = secondsCopy
                print("SECONDSSSS",timerPage.seconds)
                print("PUSHCHAT BOOL VIEWCONTROLLER",self.PushChatBool)
                
                timerPage.FromPushChatBool = self.PushChatBool

                
//                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Timer Data check in ViewController is : False", buttonTitle: "OK")

                if notificationType == "2" {
                    timerPage.seconds = CommonMethods.tempSecondsChange(session_time: String(secondsCopy/60))
                    timerPage.isSessionStartedNotificationFromViewController = true
                    timerPage.TIMERCHECK = true
                }else if notificationType == "3"{
//                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Timer Data check in ViewController is : False", buttonTitle: "OK")
                    
                   
                    timerPage.isOpenedFromSessionStoppedNotification = true
                }
            }
            //self.CancelStopBool = false
           
        }
    }
    
    func fbShareContentURL() {
        
        let content = FBSDKShareLinkContent()
        content.contentTitle = "TEST CONTENT"
        content.contentDescription = "TEST DESC"
        content.quote = "CONTENT QUOTE"
        content.contentURL = URL(string: "https://desktime.com/app/my")
        
        FBSDKShareAPI.share(with: content, delegate: nil)
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

//MARK: - FACEBOOK SHARING FUNCTIONS & DELEGATES

extension TrainerTraineeRouteViewController: FBSDKSharingDelegate {
    
    
    func btnPostPhoto(sender: UIButton) {
        if FBSDKAccessToken.current().hasGranted("publish_actions") {
            let content = FBSDKSharePhotoContent()
            content.photos = [FBSDKSharePhoto(image: #imageLiteral(resourceName: "profileImage"), userGenerated: true)]
            //[FBSDKSharePhoto(imag , userGenerated: true)]
            FBSDKShareAPI.share(with: content, delegate: self)
        } else {
            print("require publish_actions permissions")
        }
    }
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print("didCompleteWithResults")
        
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        print("didFailWithError")
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print("sharerDidCancel")
    }
}
