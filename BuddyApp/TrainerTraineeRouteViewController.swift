//
//  TrainerTraineeRouteViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 07/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import Firebase
import UserNotifications
import NVActivityIndicatorView
import FBSDKLoginKit
import FBSDKShareKit
import TwitterKit
import Reachability

class TrainerTraineeRouteViewController: UIViewController {
    
    @IBOutlet weak var timer_lbl: UILabel!
    @IBOutlet weak var mapview: GMSMapView!
    @IBOutlet weak var collectionview: UICollectionView!
    
//    var sessionDetailModel: SessionDetailModel = SessionDetailModel()
    let window = UIApplication.shared.keyWindow!
    var v = UIView()
    
    var TrainerProfilePage: TrainerProfilePage!
  
    var frompushBool = Bool()
    var TIMERCHECK = Bool()
    var locationManager: CLLocationManager!
    var lat = Float()
    var long = Float()
    var trainerProfileDetails = TrainerProfileModal()
    var TrainerProfileDictionary: NSDictionary!
    var DistanceTrainerTrainee : Float!
    
    var TimerDict = NSDictionary()
    var numOfDays = Int()

    var parameterdict = NSMutableDictionary()
    var datadict = NSMutableDictionary()
    var parameterdict1 = NSMutableDictionary()
    var datadict1 = NSMutableDictionary()
    
    let imagearray = ["close","play","man","message"]
    let imagearrayDark = ["close-dark","play-dark","man","message-dark"]
    let MenuLabelArray = ["Cancel","Start","Profile","Message"]
    
    var cell1 = MapBottamButtonCell()
    var indexpath1 = NSIndexPath()
    var BoolArray: [Bool] = [false,false,false,false]

    var profileArray = Array<TrainerProfileDetail>()
    //TIMER
    var TimeDict = NSMutableDictionary()
    var myMutableString = NSMutableAttributedString()
    var seconds = Int()
    var timer : Timer?
    var isTimerRunning = false
    
    var isExtendedCheck = Bool()
    var extendedSessionDuration = String()
    
    
    
    
    
    //Cancel Alert View
    @IBOutlet weak var cancelAlertView: CardView!
    @IBOutlet weak var btnNoCancelAlert: UIButton!
    @IBOutlet weak var btnYesCancelAlert: UIButton!
    @IBOutlet weak var cancelAlertViewTitle: UILabel!
    @IBOutlet weak var txtCancelReason: UITextView!

    var isInSessionRoutePage = Bool()
    var isShowingLoadingView = Bool()
    
    var categoryId = String()
    var isOpenedFromSessionStoppedNotification = Bool()
    var FromPushChatBool = Bool()
    
    //Draw Route Objects
    var polyline = GMSPolyline()
    var animationPolyline = GMSPolyline()
    var path = GMSPath()
    var animationPath = GMSMutablePath()
    var i: UInt = 0
    var timerMapDraw: Timer!
    
    var isSessionStartedNotificationFromViewController = Bool()
    
    var unreadMessageCount = Int()
    let reachability = Reachability()!
    
    //MARK: - VIEW CYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtCancelReason.text = "Type here..."
        txtCancelReason.textColor = UIColor.lightGray
        txtCancelReason.delegate = self
        
        print("**** viewDidLoad ****")
        v = UIView(frame: CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height))
        
        appDelegate.TrainerProfileDictionary = nil
        frompushBool = false
        
        
        print("Trainer Profile Details : \(trainerProfileDetails.firstName)")
        print("***** Received Trainer Profile Dict1:\(TrainerProfileDictionary)")
        
        //For Temporary Display
        printTrainerProfileDetails()
        
        self.title = PAGE_TITLE.TRAINING_SESSION
        
        collectionview.delegate = self
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 170, height: 70)
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        collectionview.collectionViewLayout = flowLayout
        
        //Stopping Timer for adding locations for Trainer
        if appDelegate.USER_TYPE == USER_TYPE.TRAINER {
            CommonMethods.stopAddLocationTimer(availableStatus: "booked")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("**** viewWillAppear *****",appDelegate.CancelStopBool)
        print("***** Received Trainer Profile Dict2:\(TrainerProfileDictionary)")
        
//        reachabilityCheck()

        isInSessionRoutePage = true
        appDelegate.isInSessionRoutePageAppDelegate = true
        UIApplication.shared.isIdleTimerDisabled = true
        
        if appDelegate.USER_TYPE == USER_TYPE.TRAINER {
            startSessionFromPushNotificationClick_AppKilledState()
        }
       
        
        if appDelegate.USER_TYPE == "trainer"{
            let viewcontrollers = navigationController?.viewControllers
            var socketbool = Bool()
            for viewcontroller in viewcontrollers! {
                if viewcontroller is TrainerProfilePage{
                    print("GOT IT")
                    socketbool = true
                }else{
                    socketbool = false
                }
            }
            if socketbool{
                socketListener()
            }else{
                SocketIOManager.sharedInstance.OnSocket()
                socketListener()
                SocketIOManager.sharedInstance.establishConnection()
                getSocketConnected()
            }
        }else{
            
            SocketIOManager.sharedInstance.OnSocket()
            socketListener()
            SocketIOManager.sharedInstance.establishConnection()
            getSocketConnected()

        }
        

        
        

        initializeSessionCheck()
        self.RunningTimeData()
        
        print("PushChatBool",FromPushChatBool)
        
        if FromPushChatBool{
            FromPushChatBool = false
            
            performSegue(withIdentifier: "fromSessionPageToMessagingSegue", sender: self)
            
        }else{
            
        }
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: NSNotification.Name.UIApplicationDidEnterBackground, object:nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: NSNotification.Name.UIApplicationWillEnterForeground, object:nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: NSNotification.Name.UIApplicationWillResignActive, object:nil)           
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: NSNotification.Name.UIApplicationDidBecomeActive, object:nil)
        
        let notificationName = Notification.Name("SessionNotification")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.SessionTimerNotification), name: notificationName, object: nil)
        
        btnNoCancelAlert.addShadowView()
        btnYesCancelAlert.addShadowView()
        
        getCurrentLocationDetails()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("**** viewDidAppear ****")
       //  appDelegate.CancelStopBool = false
        isInSessionRoutePage = true
        appDelegate.isInSessionRoutePageAppDelegate = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("**** viewDidDisappear ****")

        UIApplication.shared.isIdleTimerDisabled = false
        isInSessionRoutePage = false
        appDelegate.isInSessionRoutePageAppDelegate = false
        stopTimer()
       // self.timerMapDraw.invalidate()
        locationManager.stopUpdatingLocation()
        reachability.stopNotifier()
    }
    
    //MARK: - REACHABILITY NOTIFIER
    func reachabilityCheck(){
        reachability.whenReachable = { reachability in
            
            CommonMethods.hideProgress()
            self.RunningTimeData()
            
            SocketIOManager.sharedInstance.OnSocket()
            self.socketListener()
            SocketIOManager.sharedInstance.establishConnection()
            self.getSocketConnected()
            
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            CommonMethods.showProgressWithStatus(statusMessage: NETWORK_CONNECTION_HAS_BEEN_LOST)
            print("Not reachable")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    //MARK: - PUSH NOTIFICATION CLICK ACTIONS
    
    func startSessionFromPushNotificationClick_AppKilledState() {
        
        if let isSessionStartedFromPush_AppKilledState = userDefaults.value(forKey: "isSessionStartedFromPush_AppKilledState"){
            
            print("isSessionStartedFromPush_AppKilledState:\(isSessionStartedFromPush_AppKilledState)")
            if (isSessionStartedFromPush_AppKilledState as? Bool)!{
                //This is for testing purpose. Session has been started push click check
                let ProfileDictionary = NSMutableDictionary()
                if let unarchivedData = userDefaults.value(forKey: "TrainerProfileDictionary") as? NSData {
                    let unarchivedDict = NSKeyedUnarchiver.unarchiveObject(with: unarchivedData as Data) as! NSDictionary
                    print("UnArchivedDict:\(unarchivedDict)")
                    ProfileDictionary.setDictionary(unarchivedDict as! [AnyHashable : Any])
                    print("*** Profile Dict when Booking request Received: \(ProfileDictionary)")
//                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Seconds:\(seconds),ProfileDictionary:\(ProfileDictionary)", buttonTitle: "OK")
                    getTraineeProfileModel(profileDict: ProfileDictionary)
                    
                    seconds = Int(ProfileDictionary["training_time"] as! String)!*60
                    seconds = CommonMethods.tempSecondsChange(session_time: String(seconds/60))

                    let sessionStartedTime = UserDefaults.standard.object(forKey: "sessionStartedPushReceivedTime") as? Date
                    let expectedTimeOfCompletion = (sessionStartedTime?.addingTimeInterval(TimeInterval(seconds)))
                    
                    print("sessionStartedTime",String(describing: sessionStartedTime))
                    print("expectedTimeOfCompletion",String(describing: expectedTimeOfCompletion))
                    print("Current Time :\(Date())")
                    
                    if expectedTimeOfCompletion! > Date(){
                        print("Session Ongoing")
                        numOfDays = Date().daysBetweenDate(toDate: expectedTimeOfCompletion!)
                        print("Remaining Time in Seconds:\(numOfDays)")
                        
//                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "seconds:\(numOfDays),sessionStartedTime:\(String(describing: sessionStartedTime)),expectedTimeOfCompletion:\(String(describing: expectedTimeOfCompletion)),Current Time:\(Date())", buttonTitle: "OK")
                        
                        //600 seconds has been added because of the time difference.
                        seconds = numOfDays + 600

                        self.SessionStartAPI()
                        self.BoolArray.insert(true, at: 1)
                        self.TIMERCHECK = true
                        self.collectionview.reloadData()

                    }else{
                        print("completed")
                        self.performSegue(withIdentifier: "trainingCancelledToTrainerHomeSegue", sender: self)
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Session has been completed", buttonTitle: "OK")
                    }
                    
                    userDefaults.removeObject(forKey: "isSessionStartedFromPush_AppKilledState")
                    userDefaults.removeObject(forKey: "sessionStartedPushReceivedTime")
                }
            }
        }
    }
    
    func getTraineeProfileModel(profileDict: NSMutableDictionary) {
        
        let Trainee_Dict = profileDict["trainee_details"] as! Dictionary<String, Any>
        
        trainerProfileDetails = TrainerProfileModal.init(
            profileImage: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_user_image"] as? String),
            firstName: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_first_name"] as? String),
            lastName: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_last_name"] as? String),
            mobile: "91456456",
            gender: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_gender"] as? String),
            userid: String(appDelegate.UserId),
            rating: "3",
            age: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_age"] as? String),
            height: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_height"] as? String),
            weight: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_weight"] as? String),
            distance: "456",
            lattitude: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_latitude"] as? String),
            longittude: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_longitude"] as? String),
            bookingId: String(TrainerProfileDictionary["book_id"] as! Int) ,
            categoryId: "12342352352358",
            trainerId: String(TrainerProfileDictionary["trainer_id"] as! Int),
            traineeId: String(TrainerProfileDictionary["trainee_id"] as! Int),
            pickup_lattitude: String(TrainerProfileDictionary["pick_latitude"] as! String),
            pickup_longitude: String(TrainerProfileDictionary["pick_longitude"] as! String),
            pickup_location: String(TrainerProfileDictionary["pick_location"] as! String)
        )
    }
   
    //MARK: - UNWIND SEGUE
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        print("****************** Unwind Segue Catch with Identifier ****************** \(String(describing: segue.identifier))")
        isInSessionRoutePage = true
        appDelegate.isInSessionRoutePageAppDelegate = true

        if segue.identifier == "unwindToRouteVCSegue" {
            if self.isExtendedCheck{
                print("**** Session Extended Check YES in Unwind segue ****")
                extendedSessionDuration = userDefaults.value(forKey: "backupTrainingSessionChoosed") as! String
                initializeSession()
                runTimer()
            }else{
                print("**** Session Extended Check NO in Unwind segue ****")
                self.BookingAction(Action_status: "complete")
            }
        }else if segue.identifier == "unwindSegueToRoutePageFromTrainerProfile" {
            print("**** unwindToVC1 when SEGUE : unwindSegueToRoutePageFromTrainerProfile ***")
        }else if segue.identifier == "unwindSegueToRoutePageFromMessageVC" {
            print("**** unwindToVC1 when SEGUE : unwindSegueToRoutePageFromMessageVC ***")
            unreadMessageCount = 0
            self.collectionview.reloadData()
        }
    }
    
    //MARK: - INITIALIZE SESSION ACTION
    
    func initializeSessionCheck(){
        
        print("***** initializeSessionCheck ******")

        if TIMERCHECK {
            print("***** Timer Check in Route Page initializeSessionCheck ******")
           // locationManager.stopUpdatingLocation()
            
            FetchFromDb()
            
            if let isShowingWaitingForExtendRequest = userDefaults.value(forKey: "isShowingWaitingForExtendRequest") as? Bool{
                if isShowingWaitingForExtendRequest {
                    NewLoadingView()
                }else{
                    print("=== RunTimer 1 ===")
                    print("Seconds:\(seconds)")
//                    seconds = CommonMethods.tempSecondsChange(session_time: String(seconds/60))
                    if appDelegate.CancelStopBool{
                        sessionStoppedNotificationReceived()
                        
                    }else{
                        print("=== RunTimer 1.1 ===")
                        self.runTimer()
                    }                }
            }else{
                if appDelegate.CancelStopBool{
                    sessionStoppedNotificationReceived()
                    
                }else{
                    print("=== RunTimer 2 ===")
                    self.runTimer()
                }
            }
        }else{
            
            initializeSession()
        
        }
    }
    
    func initializeSession() {
        
        print("*** TIMER CHECK FALSE ***")
        if appDelegate.USER_TYPE == "trainee"{
            var sessionTime = String()
            if choosedSessionOfTrainee == ""{
                if let backup_session_choosed = userDefaults.value(forKey: "backupTrainingSessionChoosed") as? String {
                    sessionTime = backup_session_choosed
                }else{
                    sessionTime = String(seconds/60)
                }
            }else if choosedSessionOfTrainee != "" {
                sessionTime = choosedSessionOfTrainee
            }else{
                sessionTime = String(seconds/60)
            }
//            seconds = Int(sessionTime)!*60
            print("========== Session Duration Seconds:\(sessionTime)")
            
            //For testing purpose
            seconds = CommonMethods.tempSecondsChange(session_time: sessionTime)
            timer_lbl.text = String(seconds/60) + ":" + "00"
        }else if appDelegate.USER_TYPE == "trainer" {
           
            //For testing purpose
            
            print("Seconds1:\(seconds)")
            seconds = CommonMethods.tempSecondsChange(session_time: String(seconds/60))
            print("Seconds2:\(seconds)")
            timer_lbl.text = String(seconds/60) + ":" + "00"
            
            print("TrainerProfileDictionary 1234: \(TrainerProfileDictionary)")
            let Trainee_Dict = TrainerProfileDictionary["trainee_details"] as! Dictionary<String, Any>
            
            trainerProfileDetails = TrainerProfileModal.init(
                 profileImage: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_user_image"] as? String),
                 firstName: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_first_name"] as? String),
                 lastName: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_last_name"] as? String),
                 mobile: "91456456",
                 gender: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_gender"] as? String),
                 userid: String(appDelegate.UserId),
                 rating: "3",
                 age: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_age"] as? String),
                 height: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_height"] as? String),
                 weight: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_weight"] as? String),
                 distance: "456",
                 lattitude: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_latitude"] as? String),
                 longittude: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_longitude"] as? String),
                 bookingId: String(TrainerProfileDictionary["book_id"] as! Int) ,
                 categoryId: "12342352352358",
                 trainerId: String(TrainerProfileDictionary["trainer_id"] as! Int),
                 traineeId: String(TrainerProfileDictionary["trainee_id"] as! Int),
                 pickup_lattitude: String(TrainerProfileDictionary["pick_latitude"] as! String),
                 pickup_longitude: String(TrainerProfileDictionary["pick_longitude"] as! String),
                 pickup_location: String(TrainerProfileDictionary["pick_location"] as! String)
            )
            
        }
        
        TrainerProfileDetail.createProfileBookingEntry(TrainerProfileModal: self.trainerProfileDetails)
        
        
        if appDelegate.CancelStopBool{
            sessionStoppedNotificationReceived()
            
        }else{
            
        }
        
        
        if isOpenedFromSessionStoppedNotification{
            print("isOpenedFromSessionStoppedNotification:\(isOpenedFromSessionStoppedNotification)")
//            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "isOpenedFromSessionStoppedNotification = true", buttonTitle: "OK")
            sessionStoppedNotificationReceived()
        }
    }
    
    func printTrainerProfileDetails() {
        print("===========================")
        print("Booking ID: \(trainerProfileDetails.Booking_id)")
        print("Category ID: \(trainerProfileDetails.categoryId)")
        print("Trainee ID: \(trainerProfileDetails.Trainee_id)")
        print("Trainer ID: \(trainerProfileDetails.Trainer_id)")
        print("First Name: \(trainerProfileDetails.firstName)")
        print("Last Name: \(trainerProfileDetails.lastName)")
        print("===========================")
    }
    
    func createSessionDetailModel(detailsDict : TrainerProfileModal) -> SessionDetailModel {
        
        print("createSessionDetailModel From:\(detailsDict)")
        
        let session_detail_model_obj = SessionDetailModel()
        
        session_detail_model_obj.bookingId = detailsDict.Booking_id
        session_detail_model_obj.traineeId = detailsDict.Trainee_id
        session_detail_model_obj.trainerId = detailsDict.Trainer_id
        
        if appDelegate.USER_TYPE == "trainer" {
            session_detail_model_obj.trainerName = (userDefaults.value(forKey: "userName") as? String)!
            session_detail_model_obj.traineeName =  detailsDict.firstName + " " + detailsDict.lastName
        }else if appDelegate.USER_TYPE == "trainee" {
            session_detail_model_obj.trainerName = detailsDict.firstName + " " + detailsDict.lastName
            session_detail_model_obj.traineeName = (userDefaults.value(forKey: "userName") as? String)!
        }
        
        return session_detail_model_obj
    }
    
    func SessionTimerNotification(notif: NSNotification){
       
        print("Notification Received in Trainer Trainee Route VC:\(notif)")
        print("isInSessionRoutePage Value : \(self.isInSessionRoutePage)")
        
        guard self.isInSessionRoutePage else{
            print("******** Suspended Notification received execution in Trainer Trainee RounteVC ********")
            return
        }
        
        if notif.userInfo!["pushData"] as! String == "2"{
            
            print("*** Notification Type 2 Received : START SESSION *******")
            frompushBool = true
            print("OK")
            print("START CLICK")
            locationManager.stopUpdatingLocation()
            self.SessionStartAPI()
            self.BoolArray.insert(true, at: 1)
            self.TIMERCHECK = true
            self.collectionview.reloadData()
            
           //  CommonMethods.alertView(view: self, title: ALERT_TITLE, message: trainerProfileDetails.firstName, buttonTitle: "Ok")
//        
//            let alertController = UIAlertController(title: ALERT_TITLE, message: "Session has started", preferredStyle: UIAlertControllerStyle.alert)
//        
//            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
//                (result : UIAlertAction) -> Void in
//                print("OK")
//                print("START CLICK")
//                self.SessionStartAPI()
//                self.BoolArray.insert(true, at: 1)
//                self.TIMERCHECK = true
//                self.collectionview.reloadData()
//            }
//            alertController.addAction(okAction)
//            self.present(alertController, animated: true, completion: nil)
        }else if notif.userInfo!["pushData"] as! String == "3"{

            print("*** Notification Type 3 Received : CENCEL SESSION *******")
            TimerModel.sharedTimer.internalTimer?.invalidate()
            sessionStoppedNotificationReceived()
           // self.BookingAction(Action_status: "cancel")
            
        }else if notif.userInfo!["pushData"] as! String == "4"{
            
            print("***** Session have been Completed ******")
            print("*** Notification Type 4 Received : COMPLETED SESSION *******")
            self.stopTimer()
            
            //Removing userdefault values of transaction details
            print("***** removeTransactionDetailsFromUserDefault *******")
            CommonMethods.removeTransactionDetailsFromUserDefault(sessionDuration: choosedSessionOfTrainee)
            
            self.timer_lbl.text = "00" + ":" + "00"
            userDefaults.removeObject(forKey: "TimerData")
            self.TIMERCHECK = false
            userDefaults.set(false, forKey: "isCurrentlyInTrainingSession")
            
            appDelegate.timerrunningtime = false
            TrainerProfileDetail.deleteBookingDetails()
            
            hideLoadingView()

            self.RateViewScreen(cancelStatus: false)
            
            if appDelegate.USER_TYPE == "trainer" {
                self.performSegue(withIdentifier: "trainingCancelledToTrainerHomeSegue", sender: self)
            }else if appDelegate.USER_TYPE == "trainee" {
                self.performSegue(withIdentifier: "trainingCancelledToTraineeHomeSegue", sender: self)
            }
           // self.BookingAction(Action_status: "complete")
        }else if notif.userInfo!["pushData"] as! String == "6"{
            
            //EXTEND
            // userDefaults.removeObject(forKey: "TimerData")
            userDefaults.set(false, forKey: "sessionBookedNotStarted")
            
            self.TIMERCHECK = false
            
            hideLoadingView()
            let extentedTimeDict = CommonMethods.convertToDictionary(text:notif.userInfo!["data"] as! String)! as NSDictionary
            
            print(extentedTimeDict["extend_time"]!)
            
            seconds = Int(extentedTimeDict["extend_time"]! as! String)!*60
            seconds = CommonMethods.tempSecondsChange(session_time: String(seconds/60))
            
            timer_lbl.text = String(seconds/60) + ":" + "00"
           // initializeSession()
            self.runTimer()
        }
    }
    
    func sessionStoppedNotificationReceived() {
        
        TimerModel.sharedTimer.internalTimer?.invalidate()
         appDelegate.CancelStopBool = false
        
        if self.TIMERCHECK{
            
            self.RateViewScreen(cancelStatus: false)
            
        }else{
            self.RateViewScreen(cancelStatus: true)
        }
        
        
        self.stopTimer()
        self.timer_lbl.text = "00" + ":" + "00"
        self.TIMERCHECK = false
        userDefaults.removeObject(forKey: "TimerData")
        userDefaults.set(false, forKey: "isCurrentlyInTrainingSession")
        userDefaults.removeObject(forKey: "TrainerProfileDictionary")
        appDelegate.timerrunningtime = false
        TrainerProfileDetail.deleteBookingDetails()
       
        hideLoadingView()
        
        
        
        if appDelegate.USER_TYPE == "trainer" {
            self.performSegue(withIdentifier: "trainingCancelledToTrainerHomeSegue", sender: self)
        }else if appDelegate.USER_TYPE == "trainee" {
            self.performSegue(withIdentifier: "trainingCancelledToTraineeHomeSegue", sender: self)
        }
    }
    
    //MARK: - SHOW/HIDE LOADING VIEW
    
    func NewLoadingView(){
        
      //  let v = UIView(frame: CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height))
        
        let v1 = NVActivityIndicatorView(frame:  CGRect(x: (window.frame.width - 150)/2, y: (window.frame.height - 150)/2, width: 150, height: 150), type:.ballSpinFadeLoader, color: UIColor.white, padding: NVActivityIndicatorView.DEFAULT_PADDING)
        
         v.backgroundColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 0.5)
        
        v1.startAnimating()
        
        //TEXT LABEL 
        
        let label = UILabel(frame: CGRect(x: 0, y: v1.frame.origin.y + v1.frame.height + 30, width: window.frame.width, height: 21))
       // label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = WAITING_FOR_TRAINEE_EXTEND_REQUEST_ACTION
        
        v.addSubview(v1)
        v.addSubview(label)
        window.addSubview(v)
        isShowingLoadingView = true
        autoDismissLoadingView()
    }
    
    func autoDismissLoadingView() {
        
        let when = DispatchTime.now() + 60
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            print("isShowingLoadingView Value:\(self.isShowingLoadingView)")
            guard self.isShowingLoadingView else{
                print("Suspend dismiss loading view call in autoDismissLoadingView")
                return
            }
            
            print("****** autoDismissLoadingView after timeout 60 Seconds ******")
            self.BookingAction(Action_status: "complete")
            self.hideLoadingView()
        }
    }
    
    func hideLoadingView() {
        isShowingLoadingView = false
        userDefaults.set(false, forKey: "isShowingWaitingForExtendRequest")
        v.removeFromSuperview()
    }
    
    func RunningTimeData(){
        
        if userDefaults.value(forKey: "TimerData") != nil {
            
            TimerDict = userDefaults.value(forKey: "TimerData") as! NSDictionary
            print("TIMERDICT",TimerDict)
            
            let date = ((TimerDict["currenttime"] as! Date).addingTimeInterval(TimeInterval(TimerDict["TimeRemains"] as! Int)))
            
            print("OLD DATE",date)
            print("CURRENT DATE",Date())
            
            if date > Date(){
                print("ongoing")
                numOfDays = Date().daysBetweenDate(toDate: date)
                seconds = numOfDays
                self.runTimer()
                print("DIFFERENCE",numOfDays)
                //self.showTimer(time: numOfDays)
            }else{
                print("completed")
            }
        }
    }
    
    func methodOfReceivedNotification(notif: NSNotification) {
        
      print("ENTER FORGROUND",notif.name.rawValue)
        
        if notif.name.rawValue == "UIApplicationWillEnterForegroundNotification"{
            self.RunningTimeData()
        }else if notif.name.rawValue == "UIApplicationDidEnterBackgroundNotification"{
            self.stopTimer()
        }else if notif.name.rawValue == "UIApplicationWillResignActiveNotification"{
            self.stopTimer()
        }
    }

    func getCurrentLocationDetails() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestAlwaysAuthorization()
            self.mapview?.isMyLocationEnabled = true
            locationManager.startUpdatingLocation()
        }
    }
    
    //MARK: - FETCHING FROM DB
    
    func FetchFromDb() {
        
        if let result = TrainerProfileDetail.fetchBookingDetails() {
            self.profileArray = result as! Array<TrainerProfileDetail>
            
            guard self.profileArray.count > 0 else {
                print("Profile array count is 0, hence returns")
                return
            }
       
            let bookingObj = self.profileArray[0]
            
            print("FROM DB",bookingObj)
            
            trainerProfileDetails = TrainerProfileModal.init(profileImage: bookingObj.value(forKey: "profileimage") as! String,
                firstName: CommonMethods.checkStringNull(val: bookingObj.value(forKey:"firstname") as? String) ,
                lastName: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"lastname") as? String),
                mobile: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"mobile") as? String),
                gender: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"gender") as? String),
                userid: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"userId") as? String),
                rating: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"rating") as? String),
                age: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"age") as? String),
                height: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"height") as? String),
                weight: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"weight") as? String),
                distance: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"distance") as? String),
                lattitude: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"lattitude") as? String),
                longittude: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"longitude") as? String),
                bookingId: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"bookingId") as? String),
                categoryId: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"categoryId") as? String),
                trainerId: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"trainerId") as? String),
                traineeId: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"traineeId") as? String),
       
                pickup_lattitude: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"pickuplattitude") as? String),
                pickup_longitude:  CommonMethods.checkStringNull(val:bookingObj.value(forKey:"pickuplongitude") as? String),
                pickup_location:  CommonMethods.checkStringNull(val:bookingObj.value(forKey:"pickuplocation") as? String))
        }
    }
    
    func RateViewScreen(cancelStatus: Bool){
        
        
        print("CANCEL STATUS",cancelStatus)
        
        self.isTimerRunning = false
        let vc = storyboardSingleton.instantiateViewController(withIdentifier: "TrainerReviewPage") as! TrainerReviewPage
        vc.trainerProfileDetails1 = self.trainerProfileDetails
        vc.apologyBool = cancelStatus
        present(vc, animated: true, completion: nil)
    }
    

    
    
    //MARK: - API
    func BookingAction(Action_status: String) {
        
        var parameters = ["book_id" : trainerProfileDetails.Booking_id,
                          "action" : Action_status,
                          "trainer_id" : trainerProfileDetails.Trainer_id
                        ] as [String : Any]
        
        if Action_status == "cancel"{
            let tempDict = ["reason" : txtCancelReason.text,
                            ] as [String : Any]
            
            parameters = parameters.merged(with: tempDict)
        }
        
        print("Params:\(parameters)")
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: BOOKING_ACTION, parameters: parameters, onCompletion: { (jsondata) in
            
            CommonMethods.hideProgress()
            print("*** BookingAction Result:",jsondata)
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    //Need to check
                    if jsondata["status_type"] as? String == "BookingAlreadyCancelled" {
                        
                        self.stopTimer()
                        self.timer_lbl.text = "00" + ":" + "00"
                        userDefaults.removeObject(forKey: "TimerData")
                        appDelegate.timerrunningtime = false
                        userDefaults.set(false, forKey: "sessionBookedNotStarted")
                        userDefaults.set(false, forKey: "isCurrentlyInTrainingSession")
                        self.TIMERCHECK = false
                        userDefaults.removeObject(forKey: "TrainerProfileDictionary")
                        
                        print("**** Disconnecting Socket Connection ****")
                        SocketIOManager.sharedInstance.closeConnection()
                        
                        userDefaults.set(true, forKey: "isTimerStopped")
                        TrainerProfileDetail.deleteBookingDetails()
                        if appDelegate.USER_TYPE == "trainer" {
                            self.performSegue(withIdentifier: "trainingCancelledToTrainerHomeSegue", sender: self)
                        }else if appDelegate.USER_TYPE == "trainee" {
                            self.performSegue(withIdentifier: "trainingCancelledToTraineeHomeSegue", sender: self)
                        }
                        return
                    }
                    
                    //If success case
                    if let dict = jsondata["data"]  as? NSDictionary {
                        
                        if dict["status"] as! String == "cancelled" ||
                            dict["status"] as! String == "stopped" ||
                            dict["status"] as! String == "completed" {
                            
                            print("** Removing Timer Details from UserDefaults ***")
                            
                            TimerModel.sharedTimer.internalTimer?.invalidate()
                            self.stopTimer()
                            self.timer_lbl.text = "00" + ":" + "00"
                            userDefaults.removeObject(forKey: "TimerData")
                            appDelegate.timerrunningtime = false
                            userDefaults.set(false, forKey: "sessionBookedNotStarted")
                            userDefaults.set(false, forKey: "isCurrentlyInTrainingSession")
                            self.TIMERCHECK = false
                            userDefaults.removeObject(forKey: "TrainerProfileDictionary")
                            
                            print("**** Disconnecting Socket Connection ****")
                            SocketIOManager.sharedInstance.closeConnection()
                            
                            userDefaults.set(true, forKey: "isTimerStopped")
                            
                            if dict["status"] as! String == "stopped" || dict["status"] as! String == "completed"{
                                CommonMethods.removeTransactionDetailsFromUserDefault(sessionDuration: choosedSessionOfTrainee)
                            }

                            TrainerProfileDetail.deleteBookingDetails()
                            
                            if dict["status"] as! String == "stopped" || dict["status"] as! String == "completed" {
                                self.RateViewScreen(cancelStatus: false)
                            }
                            
                            if appDelegate.USER_TYPE == "trainer" {
                                self.performSegue(withIdentifier: "trainingCancelledToTrainerHomeSegue", sender: self)
                            }else if appDelegate.USER_TYPE == "trainee" {
                                self.performSegue(withIdentifier: "trainingCancelledToTraineeHomeSegue", sender: self)
                            }
                        }
                    }
                    
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"]  as? String, buttonTitle: "Ok")
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    func SessionStartAPI() {
        
        let parameters = ["book_id" : trainerProfileDetails.Booking_id,
                          "user_type" : appDelegate.USER_TYPE,
                          "trainer_id" : trainerProfileDetails.Trainer_id,
                          "trainee_id" : trainerProfileDetails.Trainee_id
            ] as [String : Any]
        
        print("Params:\(parameters)")
        
        CommonMethods.serverCall(APIURL: SESSION_START, parameters: parameters, onCompletion: { (jsondata) in
            
            print("*** SessionStart Result:",jsondata)
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    print("ENTER SUCESSS API")
                    let indexpath = NSIndexPath(row: 1, section: 0)
                    let startSessionCell: MapBottamButtonCell = self.collectionview.cellForItem(at: indexpath as IndexPath) as! MapBottamButtonCell
                    
                    CommonMethods.removeTransactionDetailsFromUserDefault(sessionDuration: choosedSessionOfTrainee)
                    self.locationManager.stopUpdatingLocation()
                    startSessionCell.menu_btn.setImage(UIImage(named: "session_stop"), for: .normal)
                    startSessionCell.name_lbl.text = "Stop"
                    self.BoolArray.insert(true, at: 1)
                    
                    userDefaults.set(false, forKey: "sessionBookedNotStarted")
                   // userDefaults.removeObject(forKey: "TrainerProfileDictionary")
                    
                    userDefaults.set(true, forKey: "isCurrentlyInTrainingSession")
                    print("TIMER STATUS",self.isTimerRunning)

                    if self.isTimerRunning == false {
                        self.TIMERCHECK = true
                        
                        
                         TimerModel.sharedTimer.seconds = 120
                         TimerModel.sharedTimer.startTimer(withInterval: 1.0)
                        
                        
                        self.runTimer()
                    }
                    
                    if self.frompushBool{
                         CommonMethods.alertView(view: self, title: ALERT_TITLE, message: self.trainerProfileDetails.firstName + " " + "started the Session", buttonTitle: "Ok")
                        
                        self.frompushBool = false
                    }else{
                         CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"]  as? String, buttonTitle: "Ok")
                    }
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
//MARK: - TIMER ACTIONS
    
    func runTimer() {
        
        print("TIMER STARTS RUNNING")
        

        
        if timer == nil {
            print("** Run timer IN FUNCTION **")
            timer =  Timer.scheduledTimer(
                timeInterval: TimeInterval(1),
                target      : self,
                selector    : #selector(TrainerTraineeRouteViewController.updateTimer),
                userInfo    : nil,
                repeats     : true)
                isTimerRunning = true
        }
    }
    
    func stopTimer() {
        print("=== Stop Timer Call Out Route page ===")
        
        if timer != nil {
            print("==== Stopping Timer ====")
            timer?.invalidate()
            timer = nil
        }else{
            print("Timer is nil 123")
            timer?.invalidate()
            timer = nil
        }
    }
    
    func updateTimer() {
        
        print("** updateTimer Call **")
        print("seconds Value :\(seconds)")
        
        guard isInSessionRoutePage else{
            print("** isInSessionRoutePage is false, hence suspended in Update Timer function **")
            stopTimer()
            return
        }

        if seconds < 1 {
            
            print("======= TIMER COMPLETETD ==========")
            self.stopTimer()
            appDelegate.timerrunningtime = false
            print("*** updateTimer")
            
            if appDelegate.USER_TYPE == "trainee" {
                
                CommonMethods.removeTransactionDetailsFromUserDefault(sessionDuration: choosedSessionOfTrainee)
                showDoYouWantToExtendAlertPage()
            }else if appDelegate.USER_TYPE == "trainer"{
               // showWaitingForTraineeExtendRequest()
                print("***** Show Loading View for Trainer *****")
                self.NewLoadingView()
                userDefaults.set(true, forKey: "isShowingWaitingForExtendRequest")
            }
//            self.BookingAction(Action_status: "complete")
        } else {
            seconds -= 1
            //  timerLabel.text = timeString(time: TimeInterval(seconds))
           // print("SECONDS",seconds)
            appDelegate.timerrunningtime = true
            
            myMutableString = NSMutableAttributedString(string: timeString(time: TimeInterval(seconds)), attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 70.0)])
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR), range: NSRange(location:3,length:2))
            
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: CommonMethods.hexStringToUIColor(hex: TIMER_COLOR), range: NSRange(location:0,length:3))
            
            timer_lbl.attributedText = myMutableString
            TimeDict.setValue(seconds, forKey: "TimeRemains")
            TimeDict.setValue(Date(), forKey: "currenttime")
            print("==== Set TimerData in UserDefault ===")
            userDefaults.setValue(TimeDict, forKey: "TimerData")
        }
    }
    
    func showWaitingForTraineeExtendRequest() {
        
        //Page to show a loader for trainer till the trainee has responded to the Extend session
        let waitingForExtendRequest : WaitingForAcceptancePage = storyboardSingleton.instantiateViewController(withIdentifier: "WaitingForAcceptanceVCID") as! WaitingForAcceptancePage
        
        waitingForExtendRequest.descriptionText = WAITING_FOR_TRAINEE_EXTEND_REQUEST_ACTION
        waitingForExtendRequest.forUserType = "trainer"
        waitingForExtendRequest.trainerProfileDetails = self.trainerProfileDetails

        self.present(waitingForExtendRequest, animated: true, completion: nil)
    }
    
    func timeString(time:TimeInterval) -> String {
       // let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func DrowRoute(OriginLat: Float, OriginLong: Float, DestiLat: Float, DestiLong: Float){
        
        print("LAT & LONG",lat)
        
        let origin = "\(OriginLat),\(OriginLong)"
        let destination = "\(DestiLat),\(DestiLong)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(GOOGLE_API_KEY)"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let routes = json["routes"] as! NSArray
                    self.mapview.clear()
                    
                    OperationQueue.main.addOperation({
                        for route in routes
                        {
                            let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: "points")
                            let path = GMSPath.init(fromEncodedPath: points! as! String)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 3
                            polyline.strokeColor = CommonMethods.hexStringToUIColor(hex: ROUTE_BLUE_COLOR)
                            
//                            let bounds = GMSCoordinateBounds(path: path!)
//                            self.mapview!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                            
                            polyline.map = self.mapview
                        }
                        
                         self.MarkPoints(latitude: Double(DestiLat), logitude: Double(DestiLong))
                    })
                    
//                    let routesArray = json ["routes"] as! NSArray
//                    self.mapview.clear()
//                    if (routesArray.count > 0)
//                    {
//                        let routeDict = routesArray[0] as! Dictionary<String, Any>
//                        let routeOverviewPolyline = routeDict["overview_polyline"] as! Dictionary<String, Any>
//                        let points = routeOverviewPolyline["points"]
//                        self.path = GMSPath.init(fromEncodedPath: points as! String)!
//                        
//                        self.polyline.path = self.path
//                        self.polyline.strokeColor = CommonMethods.hexStringToUIColor(hex: ROUTE_BLUE_COLOR)
//                        self.polyline.strokeWidth = 3.0
//                        self.polyline.map = self.mapview
//                        
//                        self.timerMapDraw = Timer.scheduledTimer(timeInterval: 0.003, target: self, selector: #selector(self.animatePolylinePath), userInfo: nil, repeats: true)
//                    }
//                    
//                    DispatchQueue.main.async {
//                        self.MarkPoints(latitude: Double(DestiLat), logitude: Double(DestiLong))
//                    }
                    
                }catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
    }
    
    func animatePolylinePath() {
        if (self.i < self.path.count()) {
            self.animationPath.add(self.path.coordinate(at: self.i))
            self.animationPolyline.path = self.animationPath
            self.animationPolyline.strokeColor = UIColor.black
            self.animationPolyline.strokeWidth = 3
            self.animationPolyline.map = self.mapview
            self.i += 1
        }
        else {
            self.i = 0
            self.animationPath = GMSMutablePath()
            self.animationPolyline.map = nil
        }
    }
    
    func MarkPoints(latitude: Double, logitude: Double ){
        let marker = GMSMarker()
        let markerImage = UIImage(named: "mapsicon")!.withRenderingMode(.alwaysTemplate)
        let markerView = UIImageView(image: markerImage)
        markerView.tintColor = UIColor(red: 118.0/255.0, green: 214.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        
        marker.position = CLLocationCoordinate2D(latitude:CLLocationDegrees(latitude), longitude:CLLocationDegrees(logitude))
        
        marker.iconView = markerView
        marker.title = trainerProfileDetails.PickUpLocation
        marker.snippet = ""
        marker.map = mapview
    }
    
    //MARK: - SOCKET CONNECTION
    
    func getSocketConnected() {
        
        parameterdict.setValue("connectSocket/connectSocket", forKey: "url")
//        SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict)
        SocketIOManager.sharedInstance.connectToServerWithParams(params: parameterdict)
    }
    
    func socketListener() {
        
        SocketIOManager.sharedInstance.getSocketdata { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                
                print("====== Trainer Location socket listen handler ========")
                
                print("** isInSessionRoutePage: \(self.isInSessionRoutePage)")
                print("** isTimerRunning: \(self.isTimerRunning)")
                print("** TIMERCHECK: \(self.TIMERCHECK)")

                guard self.isInSessionRoutePage else{
                    print("*** Suspended Socket listener handler as isInSessionRoutePage:\(self.isInSessionRoutePage) ****")
                    return
                }
                
                guard  !self.TIMERCHECK else{
                    print("*** Suspended Socket listener handler as TIMERCHECK:\(self.TIMERCHECK) ****")
                    return
                }
                
                guard !self.isTimerRunning else{
                    print("*** Suspended Socket listener handler as isTimerRunning:\(self.isTimerRunning) ****")
                    return
                }
                
                guard messageInfo["type"] as! String == "location" else{
                    print("**** Socket data received inside session screen without type 'location'")
                    return
                }
                
                print("Socket Message Info in Session Page",messageInfo)
                let trainerSocketData = messageInfo["message"] as! NSDictionary
                
               // CommonMethods.hideProgress()
                
                self.measureDistance(buddiLat: Float(trainerSocketData["latitude"] as! String)!, buddiLong: Float(trainerSocketData["longitude"] as! String!)!)
                
               // self.MarkPoints(latitude: Double(trainerSocketData["latitude"] as! String)!, logitude: Double(trainerSocketData["longitude"] as! String!)!)
                
               // self.DrowRoute(OriginLat: Float(self.lat), OriginLong: Float(self.long), DestiLat: Float(trainerSocketData["latitude"] as! String)!, DestiLong: Float(trainerSocketData["longitude"] as! String!)!)
            })
        }
    }
    
    func addHandlers() {
        
        datadict.setValue(appDelegate.UserId, forKey: "user_id")
        datadict.setValue(appDelegate.USER_TYPE, forKey: "user_type")
        datadict.setValue(lat, forKey: "latitude")
        datadict.setValue(long, forKey: "longitude")
        datadict.setValue("booked", forKey: "avail_status")
        
        parameterdict.setValue("/location/addLocation", forKey: "url")
        parameterdict.setValue(datadict, forKey: "data")
        print("PARADICT",parameterdict)
        print("============== Add Trainer Location Call ==============")
       // SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict)
        SocketIOManager.sharedInstance.connectToServerWithParams(params: parameterdict)
        
       // socketListener()
    }
    
    func addHandlersTrainer(){
        
        parameterdict1.setValue("/location/receiveTrainerLocation", forKey: "url")
        
        datadict1.setValue(appDelegate.UserId, forKey: "user_id")
        datadict1.setValue(trainerProfileDetails.Trainer_id, forKey: "trainer_id")
        parameterdict1.setValue(datadict1, forKey: "data")
        print("PARADICT_ReceivedTrainerLocation",parameterdict1)
        print("============== addHandlersTrainer Call ==============")

        // SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict1)
        SocketIOManager.sharedInstance.connectToServerWithParams(params: parameterdict1)
        
       // socketListener()
    }
    
    func measureDistance(buddiLat: Float, buddiLong: Float){
    
        //My location
        let myLocation = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
        
        //My buddy's location
        let myBuddysLocation = CLLocation(latitude: CLLocationDegrees(buddiLat), longitude: CLLocationDegrees(buddiLong))
        
        //Measuring my distance to my buddy's (in km)
        let distance = myLocation.distance(from: myBuddysLocation)
        DistanceTrainerTrainee = Float(distance)
        
        print("DISTANCE IN METERS",DistanceTrainerTrainee)
    }
    
    func showReviewScreen(){
        
        print("**** showRateViewScreen *****")
        let trainerReviewPageObj: TrainerReviewPage = storyboardSingleton.instantiateViewController(withIdentifier: "TrainerReviewPage") as! TrainerReviewPage
        trainerReviewPageObj.trainerProfileDetails1 = self.trainerProfileDetails
        trainerReviewPageObj.isFromExtendPage = true
        
        self.present(trainerReviewPageObj, animated: true, completion: nil)
    }
    
    //MARK: - EXTEND SESSION 
    
    func showDoYouWantToExtendAlertPage() {
        
        let extendSessionPage : ExtendSessionRequestPage = storyboardSingleton.instantiateViewController(withIdentifier: "ExtendSessionRequestVCID") as! ExtendSessionRequestPage
        //           self.navigationController?.pushViewController(paymentMethodPage, animated: true)
        
        extendSessionPage.bookingId = trainerProfileDetails.Booking_id
        extendSessionPage.trainerId = trainerProfileDetails.Trainer_id
        extendSessionPage.trainerProfileDetails = self.trainerProfileDetails
        
        print("*** Booking ID to send Extend Page: \(trainerProfileDetails.Booking_id)")
        
        self.isInSessionRoutePage = false
        appDelegate.isInSessionRoutePageAppDelegate = false
        
        self.present(extendSessionPage, animated: true, completion: nil)
    }

    //MARK: - PREPARE FOR SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromtimertotrainerprofile"{
            //To Trainer/Trainee Profile
            let TrainerProPage =  segue.destination as! AssignedTrainerProfileView
            TrainerProPage.TrainerId = self.trainerProfileDetails.Trainer_id
            TrainerProPage.trainingLocation = self.trainerProfileDetails.PickUpLocation
            
            print("CATEG ID received", self.trainerProfileDetails.categoryId)
            TrainerProPage.trainingCategory = CategoryDB.getCategoryByCategoryID(categoryId: self.trainerProfileDetails.categoryId)
        }else if segue.identifier == "fromSessionPageToMessagingSegue" {
            //To Messaging Page
            let messagingPage = segue.destination as! MessagingSocketVC
            messagingPage.sessionDetailModelObj = createSessionDetailModel(detailsDict: trainerProfileDetails)
        }else if segue.identifier == "fromTimerToTraineeProfileSegue" {
            let traineeProfile =  segue.destination as! ProfileVC
            traineeProfile.isFromRouteVC = true
            traineeProfile.userType = "trainee"
            traineeProfile.userId = self.trainerProfileDetails.Trainee_id
        }else if segue.identifier == "trainingCancelledToTrainerHomeSegue"{
            let trainerProfile =  segue.destination as! TrainerProfilePage
            trainerProfile.isFromSessionPageAfterCompletion = true
        }
    }
    
    //MARK: - CANCEL ALERT VIEW ACTIONS
    
    @IBAction func cancelAlertYesAction(_ sender: Any) {

        if txtCancelReason.text == "" {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_ENTER_CANCEL_REASON, buttonTitle: "OK")
        }else{
            self.BookingAction(Action_status: "cancel")
        }
    }
    
    @IBAction func cancelAlertNoAction(_ sender: Any) {
        cancelAlertView.isHidden = true
    }
}


extension TrainerTraineeRouteViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard isInSessionRoutePage else{
            print("*** didUpdateLocations response suspended as call is not handling in Route page ***")
            return
        }
        
        print("didUpdateLocations")

        for location in locations {
            
            print("**********************")
            print("Long \(location.coordinate.longitude)")
            print("Lati \(location.coordinate.latitude)")
            print("**********************")
            
            // I have taken a pin image which is a custom image
            let markerImage = UIImage(named: "mapsicon")!.withRenderingMode(.alwaysTemplate)
            
            //creating a marker view
            let markerView = UIImageView(image: markerImage)
            
            //changing the tint color of the image
            markerView.tintColor = UIColor(red: 118.0/255.0, green: 214.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            
            mapview.camera = GMSCameraPosition(target: location.coordinate, zoom: 18, bearing: 0, viewingAngle: 0)
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude:location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            lat = Float(location.coordinate.latitude)
            long = Float(location.coordinate.longitude)
        }
        
        print("TIMER CHECK in Location Manager:\(TIMERCHECK)")
        if TIMERCHECK{
            
            print("Lat:\(lat)")
            print("long:\(long)")
            print("PickupLat:\(trainerProfileDetails.PickUpLattitude)")
            print("PickupLong:\(trainerProfileDetails.PickUpLongitude)")
            
            if trainerProfileDetails.PickUpLattitude == "" || trainerProfileDetails.PickUpLongitude == ""{
//                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                userDefaults.removeObject(forKey: "TimerData")
            }else{
                self.DrowRoute(OriginLat: lat, OriginLong: long, DestiLat: Float(trainerProfileDetails.PickUpLattitude)!, DestiLong: Float(trainerProfileDetails.PickUpLongitude)!)
                self.addHandlersTrainer()
            }
            
        }else{
            if appDelegate.USER_TYPE == "trainer"{
                  self.DrowRoute(OriginLat: lat, OriginLong: long, DestiLat: Float(trainerProfileDetails.PickUpLattitude)!, DestiLong: Float(trainerProfileDetails.PickUpLongitude)!)
                self.addHandlers()
                
            }else{
                print("Lat:\(lat)")
                print("long:\(long)")
                print("trainerProfileDetails.PickUpLongitude:\(trainerProfileDetails.PickUpLongitude)")

                self.DrowRoute(OriginLat: lat, OriginLong: long, DestiLat: Float(trainerProfileDetails.PickUpLattitude)!, DestiLong: Float(trainerProfileDetails.PickUpLongitude)!)
                self.addHandlersTrainer()
            }
        }
      //  locationManager.stopUpdatingLocation()
    }
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapview.isMyLocationEnabled = true
        }
    }
}
extension TrainerTraineeRouteViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "MapBottamButtonid", for: indexPath as IndexPath) as! MapBottamButtonCell
        cell1.menu_btn.backgroundColor = UIColor.clear
        cell1.menu_btn.tag = indexPath.row
        cell1.menu_btn.addTarget(self, action: #selector(TrainerTraineeRouteViewController.TapedIndex), for: .touchUpInside)
        
        cell1.menu_btn.setImage(UIImage(named: imagearrayDark[indexPath.row]), for: .normal)
        cell1.name_lbl.text = MenuLabelArray[indexPath.row]
        
        if indexPath.row == 0 && isTimerRunning {
            //Cancel
            print("**** Reloading indexpath 0 ****")
            cell1.name_lbl.textColor = .lightGray
            cell1.menu_btn.setImage(UIImage(named: "cancel_gray"), for: .normal)
            cell1.leftLine.isHidden = true
            cell1.rightLine.isHidden = false
            cell1.lblMessageCount.isHidden = true
        }else if indexPath.row == 0 && !isTimerRunning {
            cell1.name_lbl.textColor = .black
            cell1.menu_btn.setImage(UIImage(named: "cancel_gray"), for: .normal)
            cell1.leftLine.isHidden = true
            cell1.rightLine.isHidden = false
            cell1.lblMessageCount.isHidden = true
        }
        
        if indexPath.row == 1{
            //Start / Stop
            cell1.leftLine.isHidden = false
            cell1.rightLine.isHidden = false
            if TIMERCHECK{
                cell1.menu_btn.setImage(UIImage(named: "session_stop"), for: .normal)
                cell1.name_lbl.text = "Stop"
                BoolArray.insert(true, at: 1)
            }else{
                cell1.menu_btn.setImage(UIImage(named: "play_gray"), for: .normal)
                cell1.name_lbl.text = "Start"
            }
            cell1.lblMessageCount.isHidden = true
        }
        
        if indexPath.row == 2{
            //Profile
            
            cell1.leftLine.isHidden = false
            cell1.rightLine.isHidden = false
            cell1.menu_btn.sd_setImage(with: URL(string: trainerProfileDetails.profileImage), for: .normal, placeholderImage: UIImage(named: "man"))
            cell1.menu_btn.layer.cornerRadius = 20.5
            cell1.menu_btn.clipsToBounds = true
            cell1.name_lbl.text = trainerProfileDetails.firstName
            cell1.lblMessageCount.isHidden = true
        }
        
        if indexPath.row == 3{
            //Message
            cell1.menu_btn.setImage(UIImage(named: "message_gray"), for: .normal)
            cell1.name_lbl.text = "Message"
            cell1.leftLine.isHidden = false
            cell1.rightLine.isHidden = true
            cell1.lblMessageCount.text = String(unreadMessageCount)
            
            if unreadMessageCount == 0 {
                cell1.lblMessageCount.isHidden = true
            }else{
                cell1.lblMessageCount.isHidden = false
            }
        }
        
        return cell1
    }
    
    // removing spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func TapedIndex(sender:UIButton!) {
        
        sender.isSelected = !(sender.isSelected)

        if sender.tag == 0 && !isTimerRunning{
            
            print("CANCEL ACTION")
            
//            CommonMethods.removeTransactionDetailsFromUserDefault()
            cancelAlertView.isHidden = false
            cancelAlertViewTitle.text = ARE_YOU_SURE_WANT_TO_CANCEL_SESSION
            
        }else if sender.tag == 1 {
            print("START AND STOP ACTIONS")
            print("Bool Array:\(BoolArray)")
            
            if !BoolArray[1]{
                //START
                
                if appDelegate.USER_TYPE == "trainer"{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_ASK_TRAINEE_TO_START_SESSION, buttonTitle: "OK")
                }else{
                    
                    if (DistanceTrainerTrainee) != nil{
                        print("****** DistanceTrainerTrainee ****** :\(DistanceTrainerTrainee!)")
                        if DistanceTrainerTrainee! < 500.0{
                            print("START CLICK")
                            self.SessionStartAPI()
                        }else{
                            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "\(TRAINER_NOT_REACHED_TO_LOCATION)", buttonTitle: "OK")
                        }
                    }else{
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "\(TRAINER_NOT_REACHED_TO_LOCATION)", buttonTitle: "OK")
                    }
                }
            }else{
                //STOP
                print("STOP CLICK")
                let alert = UIAlertController(title: ALERT_TITLE, message: ARE_YOU_SURE_WANT_TO_STOP_SESSION, preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                    self.BoolArray.insert(false, at: 1)
//                    self.stopTimer()
//                    self.timer_lbl.text = "00" + ":" + "00"
                    
                    //Need to check with Vishnu
//                    userDefaults.removeObject(forKey: "TimerData")
//                    userDefaults.set(false, forKey: "sessionBookedNotStarted")
//                    userDefaults.set(false, forKey: "isCurrentlyInTrainingSession")
//                    self.TIMERCHECK = false

                    self.BookingAction(Action_status: "stop")
                }))
                alert.addAction(UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: { action in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }else if sender.tag == 2{
             print("PROFILE ACTION")
            
            if appDelegate.USER_TYPE == "trainee"{
                self.performSegue(withIdentifier: "fromtimertotrainerprofile", sender: self)
            }else if appDelegate.USER_TYPE == "trainer" {
                self.performSegue(withIdentifier: "fromTimerToTraineeProfileSegue", sender: self)
            }
        }else if sender.tag == 3{
            
            if !TIMERCHECK{
                print("MESSAGE ACTION")
                performSegue(withIdentifier: "fromSessionPageToMessagingSegue", sender: self)
            }
        }
    }
}

extension TrainerTraineeRouteViewController : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        indexpath1 = indexPath as NSIndexPath                                                                                                                
        
        print("INDEXPATH",indexPath.row)
        
        switch (indexPath.row) {
            case 0:
                print("**** Cancel Click")
                
            case 1:
                
                print("**** Start or Stop Click")
            
            case 2:
                print("**** Profile Button Click")
            
            case 3:
                print("**** Message Button Click in DidSelect ****")
//                performSegue(withIdentifier: "fromSessionPageToMessagingSegue", sender: self)
            
            default:
                
                print("Integer out of range")
        }
    }
}

extension TrainerTraineeRouteViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type here.."
            textView.textColor = UIColor.lightGray
        }
    }
}

