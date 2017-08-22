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

class TrainerTraineeRouteViewController: UIViewController {
    
    @IBOutlet weak var timer_lbl: UILabel!
    @IBOutlet weak var mapview: GMSMapView!
    @IBOutlet weak var collectionview: UICollectionView!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        
        if TIMERCHECK {
            FetchFromDb()
            self.runTimer()
        }else{
            if appDelegate.USER_TYPE == "trainee"{
                
                var sessionTime = String()
                if choosedSessionOfTrainee == ""{
                    sessionTime = userDefaults.value(forKey: "backupTrainingSessionChoosed") as! String
                }else{
                    sessionTime = choosedSessionOfTrainee
                }
                seconds = Int(sessionTime)!*60
                timer_lbl.text = sessionTime + ":" + "00"
            }
            else
            {
                
                timer_lbl.text = String(seconds/60) + ":" + "00"
                
                trainerProfileDetails = TrainerProfileModal.init(profileImage: "",
                                            firstName: TrainerProfileDictionary["trainee_name"] as! String,
                                            lastName: "",
                                            mobile: "",
                                            gender: "",
                                            userid: String(appDelegate.UserId),
                                            rating: "",
                                            age: "",
                                            height: "",
                                            weight: "",
                                            distance: "",
                                            lattitude: TrainerProfileDictionary["trainee_latitude"] as! String,
                                            longittude: TrainerProfileDictionary["trainee_longitude"] as! String,
                                            bookingId: String(TrainerProfileDictionary["book_id"] as! Int) ,
                                            trainerId: String(appDelegate.UserId),
                                            traineeId: String(TrainerProfileDictionary["trainee_id"] as! Int))
                
                
                TrainerProfileDetail.createProfileBookingEntry(TrainerProfileModal: self.trainerProfileDetails)

                
            }
            SocketIOManager.sharedInstance.establishConnection()
        }
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: NSNotification.Name.UIApplicationDidEnterBackground, object:nil)

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: NSNotification.Name.UIApplicationWillEnterForeground, object:nil)

        
        // Define identifier
        let notificationName = Notification.Name("SessionNotification")
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.SessionTimerNotification), name: notificationName, object: nil)
        

        
        print("viewWillAppear")
        btnNoCancelAlert.addShadowView()
        btnYesCancelAlert.addShadowView()
        
        if appDelegate.USER_TYPE == "trainer"{
            
        }else if appDelegate.USER_TYPE == "trainee"{
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.hidesBackButton = true
        }
        
        getCurrentLocationDetails()
    }
    func SessionTimerNotification(notif: NSNotification)
    {
       if notif.userInfo!["pushData"] as! String == "2"
       {
        
        let alertController = UIAlertController(title: ALERT_TITLE, message: "Session has started", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
        
        // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
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
        
        
        
        
             }
        else if notif.userInfo!["pushData"] as! String == "3"
       {
        
        self.timer.invalidate()
        removeTransactionDetailsFromUserDefault()
        self.BookingAction(Action_status: "cancel")

        }
        else if notif.userInfo!["pushData"] as! String == "4"
       {
        self.timer.invalidate()
         self.BookingAction(Action_status: "complete")
        
        }
    }
    func methodOfReceivedNotification(notif: NSNotification) {
        
      print("ENTRE FORGROUND",notif.name.rawValue)
        
        if notif.name.rawValue == "UIApplicationWillEnterForegroundNotification"
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
            }else{
            }
            

        }
        else if notif.name.rawValue == "UIApplicationDidEnterBackgroundNotification"
        {
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
                traineeId: CommonMethods.checkStringNull(val:bookingObj.value(forKey:"traineeId") as? String))
        }
    }
    
    //MARK: - API
    func BookingAction(Action_status: String) {
        
        let headers = [
            "token":appDelegate.Usertoken]
        
        let parameters = ["book_id" : trainerProfileDetails.Booking_id,
                          "action" : Action_status,
                          "trainer_id" : trainerProfileDetails.Trainer_id
                        ] as [String : Any]
        
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
                            TrainerProfileDetail.deleteBookingDetails()
                            
                            //Add Review Screen here
                            
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
            "token":appDelegate.Usertoken]
        
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
                    
                    if self.isTimerRunning == false {
                        self.runTimer()
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
  
    
    
//MARK: -TIMER ACTIONS
    
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TrainerTraineeRouteViewController.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            //Send alert to indicate time's up.
            
            self.BookingAction(Action_status: "complete")
            
        } else {
            seconds -= 1
            //  timerLabel.text = timeString(time: TimeInterval(seconds))
           // print("SECONDS",seconds)
            
            myMutableString = NSMutableAttributedString(string: timeString(time: TimeInterval(seconds)), attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 70.0)])
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR), range: NSRange(location:3,length:2))
            
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: CommonMethods.hexStringToUIColor(hex: TIMER_COLOR), range: NSRange(location:0,length:3))
            
            timer_lbl.attributedText = myMutableString
            
            
            TimeDict.setValue(seconds, forKey: "TimeRemains")
            TimeDict.setValue(Date(), forKey: "currenttime")
            
            userDefaults.setValue(TimeDict, forKey: "TimerData")
            
            
            }
    }
    func timeString(time:TimeInterval) -> String {
       // let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        marker.title = trainerProfileDetails.firstName
        marker.snippet = ""
        marker.map = mapview
    }
    //MARK: - SOCKET CONNECTION
    
    func addHandlers() {
        
        datadict.setValue(appDelegate.UserId, forKey: "user_id")
        datadict.setValue(appDelegate.USER_TYPE, forKey: "user_type")
        datadict.setValue(lat, forKey: "latitude")
        datadict.setValue(long, forKey: "longitude")
        datadict.setValue("online", forKey: "avail_status")
        
        parameterdict.setValue("/location/addLocation", forKey: "url")
        parameterdict.setValue(datadict, forKey: "data")
        print("PARADICT",parameterdict)
        
        SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict)
        SocketIOManager.sharedInstance.getSocketdata { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                print("Socket Message Info",messageInfo)
            })
        }
    }
    func addHandlersTrainer(){
        
        parameterdict1.setValue("/location/receiveTrainerLocation", forKey: "url")
        
        datadict1.setValue(appDelegate.UserId, forKey: "user_id")
        datadict1.setValue(trainerProfileDetails.userid, forKey: "trainer_id")
        parameterdict1.setValue(datadict1, forKey: "data")
        print("PARADICT_ReceivedTrainerLocation",parameterdict1)
        // SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict1)
        SocketIOManager.sharedInstance.connectToServerWithParams(params: parameterdict1)
        
        SocketIOManager.sharedInstance.getSocketdata { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                print("Socket Message Info1",messageInfo)
                
                // print(Float(messageInfo["longitude"] as! String)!)
                
                
                 self.MarkPoints(latitude: Double((messageInfo["message"] as! NSDictionary)["latitude"] as! String)!, logitude: Double((messageInfo["message"] as! NSDictionary)["longitude"] as! String!)!)
                
                self.DrowRoute(OriginLat: Float(self.lat), OriginLong: Float(self.long), DestiLat: Float((messageInfo["message"] as! NSDictionary)["latitude"] as! String)!, DestiLong: Float((messageInfo["message"] as! NSDictionary)["longitude"] as! String!)!)
                
            })
        }
    }

    //MARK: - PREPARE FOR SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromtimertotrainerprofile"{
            let TrainerProPage =  segue.destination as! AssignedTrainerProfileView
            TrainerProPage.TrainerId = self.trainerProfileDetails.Trainer_id
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
        }else{
            if appDelegate.USER_TYPE == "trainer"{
                  self.DrowRoute(OriginLat: lat, OriginLong: long, DestiLat: Float(trainerProfileDetails.Lattitude)!, DestiLong: Float(trainerProfileDetails.Longitude)!)
                
                self.addHandlers()
            }else{
                self.DrowRoute(OriginLat: lat, OriginLong: long, DestiLat: Float(trainerProfileDetails.Lattitude)!, DestiLong: Float(trainerProfileDetails.Longitude)!)
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
            print("**** Reloading indexpath 0 ****")
            cell1.name_lbl.textColor = .lightGray
        }else if indexPath.row == 0 && !isTimerRunning {
            cell1.name_lbl.textColor = .black
        }
        
        if indexPath.row == 1{
            
            if TIMERCHECK{
                cell1.menu_btn.setImage(UIImage(named: "session_stop"), for: .normal)
                cell1.name_lbl.text = "Stop"
                BoolArray.insert(true, at: 1)
            }else{
                cell1.menu_btn.setImage(UIImage(named: "play-dark"), for: .normal)
                cell1.name_lbl.text = "Start"
            }
        }else if indexPath.row == 3{
            cell1.line_lbl.isHidden = true
        }
        return cell1
    }
    
    func TapedIndex(sender:UIButton!) {
        
        sender.isSelected = !(sender.isSelected)
        let indexpath = NSIndexPath(row: sender.tag, section: 0)
        
        cell1 = collectionview.cellForItem(at: indexpath as IndexPath) as! MapBottamButtonCell

        if sender.tag == 0 && !isTimerRunning{
            
            print("CANCEL ACTION")
            removeTransactionDetailsFromUserDefault()
            cancelAlertView.isHidden = false
            cancelAlertViewTitle.text = "Are you sure you want to Cancel this session?"
            
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
                print("zero")
                
            case 1:
                
                print("one")
                let index_path = NSIndexPath(index: 0)
                collectionview.reloadItems(at: [index_path as IndexPath])
            
            case 2:
                
                print("two")
            case 3:
                
                print("three")
                
            default:
                
                print("Integer out of range")
        }

    }
}
