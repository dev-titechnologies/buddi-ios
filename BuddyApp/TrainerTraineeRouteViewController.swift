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

class TrainerTraineeRouteViewController: UIViewController {
    
    @IBOutlet weak var timer_lbl: UILabel!
    @IBOutlet weak var mapview: GMSMapView!
    @IBOutlet weak var collectionview: UICollectionView!
    
//    var sessionDetailModel: SessionDetailModel = SessionDetailModel()
    
    var TIMERCHECK = Bool()
    var locationManager: CLLocationManager!
    var lat = Float()
    var long = Float()
    var trainerProfileDetails = TrainerProfileModal()
    var TrainerProfileDictionary: NSDictionary!
    
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
    var timer = Timer()
    var isTimerRunning = false
    
    //Cancel Alert View
    @IBOutlet weak var cancelAlertView: CardView!
    @IBOutlet weak var btnNoCancelAlert: UIButton!
    @IBOutlet weak var btnYesCancelAlert: UIButton!
    @IBOutlet weak var cancelAlertViewTitle: UILabel!
    @IBOutlet weak var txtCancelReason: UITextView!

    var isInSessionRoutePage = Bool()
    
    //MARK: - VIEW CYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        appDelegate.TrainerProfileDictionary = nil
        
        
        print("Trainer Profile Details : \(trainerProfileDetails)")
        print("*****  Received Trainer Profile Dict1:\(TrainerProfileDictionary)")
        
        //For Temporary Display
        printTrainerProfileDetails()
        
        self.title = PAGE_TITLE.TRAINING_SESSION
        
        if TIMERCHECK {
            print("Timer Check ******")
            FetchFromDb()
            self.runTimer()
        }else{
            initializeSession()
        }
        
        SocketIOManager.sharedInstance.establishConnection()

        collectionview.delegate = self
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 170, height: 70)
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        collectionview.collectionViewLayout = flowLayout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("**** viewWillAppear *****")
        print("*****  Received Trainer Profile Dict2:\(TrainerProfileDictionary)")
        
        isInSessionRoutePage = true
        
        getSocketConnected()
        socketListener()
        
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: NSNotification.Name.UIApplicationDidEnterBackground, object:nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: NSNotification.Name.UIApplicationWillEnterForeground, object:nil)
        
        
        // Define identifier
        let notificationName = Notification.Name("SessionNotification")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.SessionTimerNotification), name: notificationName, object: nil)
        
        btnNoCancelAlert.addShadowView()
        btnYesCancelAlert.addShadowView()
            
        getCurrentLocationDetails()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("**** viewDidAppear ****")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        isInSessionRoutePage = false
    }
    
    func initializeSession() {
        
        print("NOT timer Check")
        if appDelegate.USER_TYPE == "trainee"{
            var sessionTime = String()
            if choosedSessionOfTrainee == ""{
                sessionTime = userDefaults.value(forKey: "backupTrainingSessionChoosed") as! String
            }else{
                sessionTime = choosedSessionOfTrainee
            }
            seconds = Int(sessionTime)!*60
            
            //For testing purpose
            seconds = 30
            timer_lbl.text = sessionTime + ":" + "00"
        }else{
            //For testing purpose
            seconds = 30
            timer_lbl.text = String(seconds/60) + ":" + "00"
            
            let Trainee_Dict = TrainerProfileDictionary["trainee_details"] as! Dictionary<String, Any>
            
            trainerProfileDetails = TrainerProfileModal.init(
                 profileImage: "",
                 firstName: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_first_name"] as? String),
                 lastName: CommonMethods.checkStringNull(val:Trainee_Dict["trainee_last_name"] as? String),
                 mobile: "91",
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
                 trainerId: String(TrainerProfileDictionary["trainer_id"] as! Int),
                 traineeId: String(TrainerProfileDictionary["trainee_id"] as! Int),
                 pickup_lattitude: String(TrainerProfileDictionary["pick_latitude"] as! String),
                 pickup_longitude: String(TrainerProfileDictionary["pick_longitude"] as! String),
                 pickup_location: String(TrainerProfileDictionary["pick_location"] as! String))
            
            TrainerProfileDetail.createProfileBookingEntry(TrainerProfileModal: self.trainerProfileDetails)
        }
    }
    
    func printTrainerProfileDetails() {
        
        print("Booking ID: \(trainerProfileDetails.Booking_id)")
        print("Trainee ID: \(trainerProfileDetails.Trainee_id)")
        print("Trainer ID: \(trainerProfileDetails.Trainer_id)")
        print("First Name: \(trainerProfileDetails.firstName)")
        print("Last Name: \(trainerProfileDetails.lastName)")
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
        
        guard self.isInSessionRoutePage else{
            print("******** Suspended Notification received execution in Trainer Trainee RounteVC ********")
            return
        }
        
        if notif.userInfo!["pushData"] as! String == "2"{
        
            let alertController = UIAlertController(title: ALERT_TITLE, message: "Session has started", preferredStyle: UIAlertControllerStyle.alert)
        
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                print("START CLICK")
                self.SessionStartAPI()
                self.BoolArray.insert(true, at: 1)
                self.TIMERCHECK = true
                self.collectionview.reloadData()
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }else if notif.userInfo!["pushData"] as! String == "3"{
            self.timer.invalidate()
             self.timer_lbl.text = "00" + ":" + "00"
            removeTransactionDetailsFromUserDefault()
            userDefaults.removeObject(forKey: "TimerData")
            appDelegate.timerrunningtime = false
            TrainerProfileDetail.deleteBookingDetails()

            self.RateViewScreen()
            
            if appDelegate.USER_TYPE == "trainer" {
                self.performSegue(withIdentifier: "trainingCancelledToTrainerHomeSegue", sender: self)
            }else if appDelegate.USER_TYPE == "trainee" {
                self.performSegue(withIdentifier: "trainingCancelledToTraineeHomeSegue", sender: self)
            }

           // self.BookingAction(Action_status: "cancel")
        }else if notif.userInfo!["pushData"] as! String == "4"{
            
           // print()
            
            self.timer.invalidate()
            
            self.timer_lbl.text = "00" + ":" + "00"
            userDefaults.removeObject(forKey: "TimerData")
            appDelegate.timerrunningtime = false
            TrainerProfileDetail.deleteBookingDetails()

            self.RateViewScreen()
            
            
            if appDelegate.USER_TYPE == "trainer" {
                self.performSegue(withIdentifier: "trainingCancelledToTrainerHomeSegue", sender: self)
            }else if appDelegate.USER_TYPE == "trainee" {
                self.performSegue(withIdentifier: "trainingCancelledToTraineeHomeSegue", sender: self)
            }
           // self.BookingAction(Action_status: "complete")
        }
    }
    
    func RunningTimeData()
    {
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
            self.timer.invalidate()
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
    
    func FetchFromDb() {
        
        if let result = TrainerProfileDetail.fetchBookingDetails() {
            self.profileArray = result as! Array<TrainerProfileDetail>
            
            guard self.profileArray.count > 0 else {
                return
            }
       
            let bookingObj = self.profileArray[0]
            
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
                trainerId: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"trainerId") as? String),
                traineeId: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"traineeId") as? String),
        pickup_lattitude: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"pickuplattitude") as? String),
        pickup_longitude:  CommonMethods.checkStringNull(val:bookingObj.value(forKey:"pickuplongitude") as? String),
        pickup_location:  CommonMethods.checkStringNull(val:bookingObj.value(forKey:"pickuplocation") as? String))
        }
    }
    
    func RateViewScreen(){
        
        self.isTimerRunning = false
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TrainerReviewPage") as! TrainerReviewPage
        vc.trainerProfileDetails1 = self.trainerProfileDetails
        present(vc, animated: true, completion: nil)
    }
    
    
    //MARK: - API
    func BookingAction(Action_status: String) {
        
        let headers = [
            "token":appDelegate.Usertoken]
        
        var parameters = ["book_id" : trainerProfileDetails.Booking_id,
                          "action" : Action_status,
                          "trainer_id" : trainerProfileDetails.Trainer_id
                        ] as [String : Any]
        
        if Action_status == "cancel"{
            let tempDict = ["reason" : txtCancelReason.text,
                            ] as [String : Any]
            
            parameters = parameters.merged(with: tempDict)
        }
        
        print("Header:\(headers)")
        print("Params:\(parameters)")
        
        CommonMethods.serverCall(APIURL: BOOKING_ACTION, parameters: parameters, headers: headers, onCompletion: { (jsondata) in
            
            print("*** BookingAction Result:",jsondata)
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    if let dict = jsondata["data"]  as? NSDictionary {
                        if dict["status"] as! String == "cancelled" || dict["status"] as! String == "completed" {
                            self.timer.invalidate()
                            self.timer_lbl.text = "00" + ":" + "00"
                            userDefaults.removeObject(forKey: "TimerData")
                            userDefaults.set(false, forKey: "sessionBookedNotStarted")
                            userDefaults.removeObject(forKey: "TrainerProfileDictionary")

                            TrainerProfileDetail.deleteBookingDetails()
                            appDelegate.timerrunningtime = false
                            self.RateViewScreen()
                            
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
        
        let headers = [
            "token" : appDelegate.Usertoken
        ]
        
        let parameters = ["book_id" : trainerProfileDetails.Booking_id,
                          "user_type" : appDelegate.USER_TYPE,
                          "trainer_id" : trainerProfileDetails.Trainer_id,
                          "trainee_id" : trainerProfileDetails.Trainee_id
            ] as [String : Any]
        
        print("Header:\(headers)")
        print("Params:\(parameters)")
        
        CommonMethods.serverCall(APIURL: SESSION_START, parameters: parameters, headers: headers, onCompletion: { (jsondata) in
            
            print("*** SessionStart Result:",jsondata)
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    print("ENTER SUCESSS API")
                    
                    userDefaults.set(false, forKey: "sessionBookedNotStarted")
                     userDefaults.removeObject(forKey: "TrainerProfileDictionary")
                     print("TIMER STATUS",self.isTimerRunning)

                    if self.isTimerRunning == false {
                        self.runTimer()
                    }
                    
                  //  CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"]  as? String, buttonTitle: "Ok")
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    
//MARK: - TIMER ACTIONS
    
    func ExtendSessionAlert() {
        
        let alert = UIAlertController(title: ALERT_TITLE, message: "You want to extend the session", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
            
           
            //self.dismissOnSessionExpire()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
 
    func runTimer() {
        
        print("TIMER STARTS RUNNING")
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TrainerTraineeRouteViewController.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    func updateTimer() {
        
        if seconds < 1 {
            
            timer.invalidate()
            appDelegate.timerrunningtime = false
            print("*** updateTimer")
            
            if appDelegate.USER_TYPE == "trainee" {
                showDoYouWantToExtendAlertPage()
            }else{
                showWaitingForTraineeExtendRequest()
            }
//            self.BookingAction(Action_status: "complete")
            
        } else {
            
            seconds -= 1
            //  timerLabel.text = timeString(time: TimeInterval(seconds))
            print("SECONDS",seconds)
            appDelegate.timerrunningtime = true
            
            myMutableString = NSMutableAttributedString(string: timeString(time: TimeInterval(seconds)), attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 70.0)])
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR), range: NSRange(location:3,length:2))
            
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: CommonMethods.hexStringToUIColor(hex: TIMER_COLOR), range: NSRange(location:0,length:3))
            
            timer_lbl.attributedText = myMutableString
            TimeDict.setValue(seconds, forKey: "TimeRemains")
            TimeDict.setValue(Date(), forKey: "currenttime")
            userDefaults.setValue(TimeDict, forKey: "TimerData")
        }
    }
    
    func showWaitingForTraineeExtendRequest() {
        
        //Page to show a loader for trainer till the trainee has responded to the Extend session
        let waitingForExtendRequest : WaitingForAcceptancePage = storyboardSingleton.instantiateViewController(withIdentifier: "WaitingForAcceptanceVCID") as! WaitingForAcceptancePage
        
        waitingForExtendRequest.descriptionText = WAITING_FOR_TRAINEE_EXTEND_REQUEST_ACTION
        waitingForExtendRequest.forUserType = "trainer"
        waitingForExtendRequest.trainerProfileDetails = self.trainerProfileDetails

        //           self.navigationController?.pushViewController(paymentMethodPage, animated: true)
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
        
        print("LAT$LONG",lat)
        
        let origin = "\(OriginLat),\(OriginLong)"
        let destination = "\(DestiLat),\(DestiLong)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyCSZe_BrUnVvqOg4OCQUHY7fFem6bvxOkc"
        
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
                            
                            let bounds = GMSCoordinateBounds(path: path!)
                            self.mapview!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                            polyline.map = self.mapview
                        }
                        
                         self.MarkPoints(latitude: Double(DestiLat), logitude: Double(DestiLong))
                        
                    })
                }catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
    }
    
    func MarkPoints(latitude: Double, logitude: Double ){
        let marker = GMSMarker()
        // I have taken a pin image which is a custom image
        let markerImage = UIImage(named: "mapsicon")!.withRenderingMode(.alwaysTemplate)
        
        //creating a marker view
        let markerView = UIImageView(image: markerImage)
        
        //changing the tint color of the image
        markerView.tintColor = UIColor(red: 118.0/255.0, green: 214.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        
        marker.position = CLLocationCoordinate2D(latitude:CLLocationDegrees(latitude), longitude:CLLocationDegrees(logitude))
        
        //  marker.icon = markerImage
        marker.iconView = markerView
        marker.title = trainerProfileDetails.PickUpLocation
        marker.snippet = ""
        marker.map = mapview
    }
    
    //MARK: - SOCKET CONNECTION
    
    func getSocketConnected() {
        
        parameterdict.setValue("connectSocket/connectSocket", forKey: "url")
        SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict)
    }
    
    func socketListener() {
        
        SocketIOManager.sharedInstance.getSocketdata { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                
                if !self.isInSessionRoutePage{
                    return
                }
                
                guard messageInfo["type"] as! String == "location" else{
                    print("**** Socket data received inside session screen without type 'location'")
                    return
                }
                
                print("Socket Message Info in Session Page",messageInfo)
                let trainerSocketData = messageInfo["message"] as! NSDictionary
                
                self.MarkPoints(latitude: Double(trainerSocketData["latitude"] as! String)!, logitude: Double(trainerSocketData["longitude"] as! String!)!)
                
                self.DrowRoute(OriginLat: Float(self.lat), OriginLong: Float(self.long), DestiLat: Float(trainerSocketData["latitude"] as! String)!, DestiLong: Float(trainerSocketData["longitude"] as! String!)!)
            })
        }
    }
    
    func addHandlers() {
        
        datadict.setValue(appDelegate.UserId, forKey: "user_id")
        datadict.setValue(appDelegate.USER_TYPE, forKey: "user_type")
        datadict.setValue(lat, forKey: "latitude")
        datadict.setValue(long, forKey: "longitude")
        datadict.setValue("online", forKey: "avail_status")
        
        parameterdict.setValue("/location/addLocation", forKey: "url")
        parameterdict.setValue(datadict, forKey: "data")
        print("PARADICT",parameterdict)
        print("============== addHandlers Call ==============")
        SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict)
    }
    
    func addHandlersTrainer(){
        
        parameterdict1.setValue("/location/receiveTrainerLocation", forKey: "url")
        
        datadict1.setValue(appDelegate.UserId, forKey: "user_id")
        datadict1.setValue(trainerProfileDetails.userid, forKey: "trainer_id")
        parameterdict1.setValue(datadict1, forKey: "data")
        print("PARADICT_ReceivedTrainerLocation",parameterdict1)
        print("============== addHandlersTrainer Call ==============")

        // SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict1)
        SocketIOManager.sharedInstance.connectToServerWithParams(params: parameterdict1)
    }
    
    //MARK: - EXTEND SESSION 
    
    func showDoYouWantToExtendAlertPage() {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let extendSessionPage : ExtendSessionRequestPage = mainStoryboard.instantiateViewController(withIdentifier: "ExtendSessionRequestVCID") as! ExtendSessionRequestPage
        //           self.navigationController?.pushViewController(paymentMethodPage, animated: true)
        
        extendSessionPage.bookingId = trainerProfileDetails.Booking_id
        extendSessionPage.trainerId = trainerProfileDetails.Trainer_id
        extendSessionPage.trainerProfileDetails = self.trainerProfileDetails
        
        print("*** Booking ID to send Extend Page: \(trainerProfileDetails.Booking_id)")
        
        self.present(extendSessionPage, animated: true, completion: nil)
    }

    //MARK: - PREPARE FOR SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromtimertotrainerprofile"{
            //To Trainer/Trainee Profile
            let TrainerProPage =  segue.destination as! AssignedTrainerProfileView
            TrainerProPage.TrainerId = self.trainerProfileDetails.Trainer_id
        }else if segue.identifier == "fromSessionPageToMessagingSegue" {
            //To Messaging Page
            let messagingPage = segue.destination as! MessagingSocketVC
            messagingPage.sessionDetailModelObj = createSessionDetailModel(detailsDict: trainerProfileDetails)
        }
        
        //For REview Segue
        //        performSegue(withIdentifier: "trainerReviewPageSegue", sender: self)

    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
    
        print("*** Unwind SEgue Identifier:\(String(describing: segue.identifier))")
    }
    
    //MARK: - CANCEL ALERT VIEW ACTIONS
    
    @IBAction func cancelAlertYesAction(_ sender: Any) {

        if txtCancelReason.text == "" {
            
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_ENTER_CANCEL_REASON, buttonTitle: "OK")
        }else{
            removeTransactionDetailsFromUserDefault()
            self.BookingAction(Action_status: "cancel")
        }
    }
    
    @IBAction func cancelAlertNoAction(_ sender: Any) {
        cancelAlertView.isHidden = true
    }
}


extension TrainerTraineeRouteViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            
            print("**********************")
            print("Long \(location.coordinate.longitude)")
            print("Lati \(location.coordinate.latitude)")
            print("Alt \(location.altitude)")
            print("Sped \(location.speed)")
            print("Accu \(location.horizontalAccuracy)")
            
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
        
        if TIMERCHECK{
            
            self.DrowRoute(OriginLat: lat, OriginLong: long, DestiLat: Float(trainerProfileDetails.PickUpLattitude)!, DestiLong: Float(trainerProfileDetails.PickUpLongitude)!)
            self.addHandlersTrainer()

            
        }else{
            if appDelegate.USER_TYPE == "trainer"{
                  self.DrowRoute(OriginLat: lat, OriginLong: long, DestiLat: Float(trainerProfileDetails.PickUpLattitude)!, DestiLong: Float(trainerProfileDetails.PickUpLongitude)!)
                self.addHandlers()
            }else{
                self.DrowRoute(OriginLat: lat, OriginLong: long, DestiLat: Float(trainerProfileDetails.PickUpLattitude)!, DestiLong: Float(trainerProfileDetails.PickUpLongitude)!)
                self.addHandlersTrainer()
            }
        }
        locationManager.stopUpdatingLocation()
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
        }else if indexPath.row == 0 && !isTimerRunning {
            cell1.name_lbl.textColor = .black
            cell1.menu_btn.setImage(UIImage(named: "cancel_gray"), for: .normal)
            cell1.leftLine.isHidden = true
            cell1.rightLine.isHidden = false
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
        }
        
        if indexPath.row == 2{
            //Profile
            cell1.menu_btn.setImage(UIImage(named: "man"), for: .normal)
            cell1.name_lbl.text = trainerProfileDetails.firstName
        }
        
        if indexPath.row == 3{
            //Message
            cell1.menu_btn.setImage(UIImage(named: "message_gray"), for: .normal)
            cell1.name_lbl.text = "Message"
            cell1.leftLine.isHidden = false
            cell1.rightLine.isHidden = true
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
        let indexpath = NSIndexPath(row: sender.tag, section: 0)
        
        cell1 = collectionview.cellForItem(at: indexpath as IndexPath) as! MapBottamButtonCell

        if sender.tag == 0 && !isTimerRunning{
            
            print("CANCEL ACTION")
            removeTransactionDetailsFromUserDefault()
            cancelAlertView.isHidden = false
            cancelAlertViewTitle.text = ARE_YOU_SURE_WANT_TO_CANCEL_SESSION
            
        }else if sender.tag == 1 {
            print("START AND STOP ACTIONS")
            print("Bool Array:\(BoolArray)")
            removeTransactionDetailsFromUserDefault()
            if !BoolArray[1]{
                //START
                print("START CLICK")
                cell1.menu_btn.setImage(UIImage(named: "session_stop"), for: .normal)
                cell1.name_lbl.text = "Stop"
                self.SessionStartAPI()
                BoolArray.insert(true, at: 1)
            }else{
                //STOP
                print("STOP CLICK")
                let alert = UIAlertController(title: ALERT_TITLE, message: ARE_YOU_SURE_WANT_TO_STOP_SESSION, preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                    self.BoolArray.insert(false, at: 1)
                    self.timer.invalidate()
                     self.timer_lbl.text = "00" + ":" + "00"
                    self.BookingAction(Action_status: "complete")
                }))
                alert.addAction(UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: { action in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }else if sender.tag == 2{
             print("PROFILE ACTION")
            self.performSegue(withIdentifier: "fromtimertotrainerprofile", sender: self)
        }else if sender.tag == 3{
             print("MESSAGE ACTION")
            performSegue(withIdentifier: "fromSessionPageToMessagingSegue", sender: self)
        }
    }
    
    func removeTransactionDetailsFromUserDefault() {
        //Clear the Userdefault values related to the Transaction
    
        userDefaults.removeObject(forKey: "backupPaymentTransactionId")
        userDefaults.removeObject(forKey: "backupIsTransactionAmount")
        userDefaults.removeObject(forKey: "backupIsTransactionSuccessfull")
        userDefaults.removeObject(forKey: "backupTrainingCategoryChoosed")
        userDefaults.removeObject(forKey: "backupTrainingGenderChoosed")
        userDefaults.removeObject(forKey: "backupTrainingSessionChoosed")
        userDefaults.removeObject(forKey: "backupIsTransactionStatus")
        userDefaults.removeObject(forKey: "TrainingLocationModelBackup")
    }
}


extension TrainerTraineeRouteViewController : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        indexpath1 = indexPath as NSIndexPath
        
        print("INDEXPATH",indexPath.row)
//        cell = collectionview.cellForItem(at: indexPath) as! MapBottamButtonCell
//        // cell1.imageview.image = UIImage(named:imagearray[indexPath.row])
//        cell1.menu_btn.setImage(UIImage(named: imagearray[indexPath.row]), for: .normal)
//        cell1.bgview.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        
//        cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "MapBottamButtonid", for: indexPath as IndexPath) as! MapBottamButtonCell

        if isTimerRunning == false && indexPath.row == 1{
            self.runTimer()
        }
        
        switch (indexPath.row) {
            case 0:
                print("**** Cancel Click")
                
            case 1:
                
                print("**** Start or Stop Click")
                let index_path = NSIndexPath(index: 0)
                collectionview.reloadItems(at: [index_path as IndexPath])
            
            case 2:
                print("**** Profile Button Click")
            
            case 3:
                print("**** Message Button Click")
                performSegue(withIdentifier: "fromSessionPageToMessagingSegue", sender: self)
            
            default:
                
                print("Integer out of range")
        }

    }
}


