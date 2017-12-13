//
//  TrainerProfilePage.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 14/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import CountryPicker
import Alamofire
import MapKit
import FBSDKCoreKit
import FBSDKLoginKit


class TrainerProfilePage: UIViewController {

    //Trainer Header Outlets
    @IBOutlet weak var StatusSwitch: UISwitch!
    @IBOutlet weak var lblTrainerName: UILabel!
    
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblHeight: UILabel!
    @IBOutlet weak var lblWeight: UILabel!
    @IBOutlet weak var imgHeightIcon: UIImageView!
    @IBOutlet weak var imgWeightIcon: UIImageView!
    
    var ageValue = String()
    var heightValue = String()
    var weightValue = String()
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    //SOCKET
    var parameterdict = NSMutableDictionary()
    var datadict = NSMutableDictionary()
//    var timer : Timer?
    
    var objdata = NSData()
    var imageArray = Array<ProfileImageDB>()
    var isEditingProfile = Bool()
    var isUpdatingProfileImage = Bool()
    
    var profileImageURL = String()
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var btnChooseProfileImage: UIButton!
    var trainerProfileViewTableCaptionsArray = [String]()
    let trainerProfileModel = TrainerProfileModal()
    var locationManager: CLLocationManager!
    var lat = Float()
    var long = Float()

    var countrypicker = CountryPicker()
    var TrainerProfileDictionary: NSDictionary!
    var selectedTrainerProfileDetails : TrainerProfileModal = TrainerProfileModal()
    var numOfDays = Int()
    var TimerDict = NSDictionary()

    var isInTrainerProfilePage = Bool()
    
    //social media urls/links
    var facebookLink = String()
    var instagramLink = String()
    var linkdInLink = String()
    var snapchatLink = String()
    var twitterLink = String()
    var youtubeLink = String()
    
    var fbUserDictionary: NSDictionary!

    //MARK: - VIEW CYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = PAGE_TITLE.TRAINER_PROFILE
        
        imagePicker.delegate = self
        trainerProfileViewTableCaptionsArray = ["Gym Subscriptions", "Training Category", "Certifications"]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("*** viewDidAppear Trainer")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        isInTrainerProfilePage = true
        
        //For checking any sessions are ongoing
//        checkIfAnySessionPresentForTrainer()
//        timerCheck()
        
//        getSocketConnected()
        SocketIOManager.sharedInstance.establishConnection()
        StatusSwitch.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        
        self.UpdateLocationAPI(Status: "online")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: NSNotification.Name.UIApplicationDidEnterBackground, object:nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: NSNotification.Name.UIApplicationWillEnterForeground, object:nil)
        
        print("*** viewWillAppear Trainer")
        if !isUpdatingProfileImage{
            changeTextColorGrey()
            parseTrainerProfileDetails()
        }
        getCurrentLocationDetails()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        print("** Trainer Profile Page viewWillDisappear **")
        isInTrainerProfilePage = false
        
       // self.timer.invalidate()
    }
    
    func getCurrentLocationDetails() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func StatusSwitch_action(_ sender: Any) {
        
    }
    
    //MARK: - CHECK IF ANY SESSION IS ONGOING BY TRAINER
    func checkIfAnySessionPresentForTrainer () {
        
        let parameters =  ["user_id": appDelegate.UserId,
                           "user_type" : appDelegate.USER_TYPE
            ] as [String : Any]
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: PENDING_BOOKING_DETAILS, parameters: parameters) { (jsondata) in
            print("** checkIfAnySessionPresentForTrainer Response: \(jsondata)")
            
            CommonMethods.hideProgress()
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    if let dataArray = jsondata["data"] as? NSArray {
                        
                        guard dataArray.count > 0 else {
                            return
                        }
                        
                        self.TrainerProfileDictionary = dataArray[0] as! NSDictionary
                        print("TRAINING DATA Trainer Profile Page :",self.TrainerProfileDictionary)
                        let trainerProfileModelObj = TrainerProfileModal()
                        self.selectedTrainerProfileDetails = trainerProfileModelObj.getTrainerProfileModelFromDict(dictionary: self.TrainerProfileDictionary as! Dictionary<String, Any>)
                        TrainerProfileDetail.createProfileBookingEntry(TrainerProfileModal: self.selectedTrainerProfileDetails)
                        self.performSegue(withIdentifier: "trainerHomePageToRoutePageSegue", sender: self)
                    }
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        }
    }
    
    func timerCheck(){
        
        print("** TimerCheck function call in LeftViewController **")
        if userDefaults.value(forKey: "TimerData") != nil {
            TimerDict = userDefaults.value(forKey: "TimerData") as! NSDictionary
            print("TIMERDICT",TimerDict)
            
            let date = ((TimerDict["currenttime"] as! Date).addingTimeInterval(TimeInterval(TimerDict["TimeRemains"] as! Int)))
            
            print("Expected time for session completion:",date)
            print("Current date and time:",Date())
            
            if date > Date(){
                print("Session is Ongoing")
                numOfDays = Date().daysBetweenDate(toDate: date)
                
                print("Time difference:",numOfDays)
//                isTimerStarted = true
                self.performSegue(withIdentifier: "trainerHomePageToRoutePageSegue", sender: self)
            }else{
                print("Session completed")
                userDefaults.removeObject(forKey: "TimerData")
                userDefaults.set(false, forKey: "isCurrentlyInTrainingSession")
                TrainerProfileDetail.deleteBookingDetails()
            }
        }
    }
    
//    else if segue.identifier == "TraineeHomeToRoutePageSegue" {
//    let timerPage =  segue.destination as! TrainerTraineeRouteViewController
//    //            timerPage.TrainerProfileDictionary = self.TrainerProfileDictionary
//    timerPage.trainerProfileDetails = selectedTrainerProfileDetails
//    timerPage.seconds = Int(self.TrainerProfileDictionary["training_time"] as! String)!*60
//    print("SECONDSSSS",timerPage.seconds)
//    }
    
    //MARK: - SOCKET CONNECTION
    
    func getSocketConnected() {
        print("**** getSocketConnected ******")
        parameterdict.setValue("/connectSocket/connectSocket", forKey: "url")
        SocketIOManager.sharedInstance.connectToServerWithParams(params: parameterdict)
        //        SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict)
    }
    
    func addHandlers() {
        
        print("*** Add Handler call for Add Location ***")
        datadict.setValue(appDelegate.UserId, forKey: "user_id")
        datadict.setValue(appDelegate.USER_TYPE, forKey: "user_type")
        datadict.setValue(lat, forKey: "latitude")
        datadict.setValue(long, forKey: "longitude")
        datadict.setValue("online", forKey: "avail_status")
        
        parameterdict.setValue("/location/addLocation", forKey: "url")
        parameterdict.setValue(datadict, forKey: "data")
        print("PARADICT11",parameterdict)
        
//        SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict)
        SocketIOManager.sharedInstance.connectToServerWithParams(params: parameterdict)
    }

    func switchValueDidChange(sender:UISwitch!) {
        
        if sender.isOn{
            print("ON STATUS")
            runTimer()
//            self.UpdateLocationAPI(Status: "online")
        }else{
            print("OFF STATUS")
//            self.UpdateLocationAPI(Status: "offline")
            stopTimer()
        }
    }
    
    func runTimer() {
        
        print("UPDATE LOCATION TIMER STARTS RUNNING")
        if addLocationTimerSingleton == nil {
            print("** Run timer IN FUNCTION **")
            self.UpdateLocationAPI(Status: "online")
            addLocationTimerSingleton =  Timer.scheduledTimer(
                timeInterval: TimeInterval(10),
                target      : self,
                selector    : #selector(self.updateLocation),
                userInfo    : nil,
                repeats     : true)
        }
    }
    
    func stopTimer() {
        print("=== Stop Timer Call Out Trainer Profile Page ===")
        if addLocationTimerSingleton != nil {
            print("==== Stopping Timer ====")
            addLocationTimerSingleton?.invalidate()
            addLocationTimerSingleton = nil
            self.UpdateLocationAPI(Status: "offline")
        }
    }
    
    func updateLocation(){
        print("**** Update Location ****")
        addHandlers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func parseTrainerProfileDetails() {
    
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
        let parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId] as [String : Any]
        
        print("PARAMS",parameters)
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: VIEW_PROFILE, parameters: parameters , onCompletion: { (jsondata) in
            print("PROFILE RESPONSE",jsondata)
            
            CommonMethods.hideProgress()
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    let profileDict = jsondata["data"]  as! NSDictionary
                    print(profileDict)

//                    let profileObj = self.trainerProfileModel.getTrainerProfileModelFromDict(dictionary: profileDict as! Dictionary<String, Any>)
                    self.fillValuesInForm(profile: profileDict)
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    //Commented due to the page expire issue when before submitting the review after completion of a session
                    //self.dismissOnSessionExpire()
                }
            }else{
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: REQUEST_TIMED_OUT, buttonTitle: "OK")
            }
        })
    }
    
    func UpdateLocationAPI (Status: String){
        
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
        let parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId,
                          "avail_status":Status
            ] as [String : Any]
        
        print("PARAMS",parameters)
        
        //CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: UPDATE_LOCATION_STATUS, parameters: parameters , onCompletion: { (jsondata) in
            print("**** Availability status response",jsondata)
            print("*** Update location status API call ***")
            
            //CommonMethods.hideProgress()
            if let status = jsondata["status"] as? Int{
                
                guard self.isInTrainerProfilePage else{
                    print("** isInTrainerProfilePage value is false, hence returned **")
                    return
                }
                
                if status == RESPONSE_STATUS.SUCCESS{
                   
                    if let onlinedata = jsondata["data"] as? NSDictionary{
                    
                        print(onlinedata)
                        
                        if onlinedata["availabilityStatus"] as? String == "online"{
                            //self.addHandlers()
                            onlineavailabilty = true
                            self.runTimer()
                        }else{
                            onlineavailabilty = false
                            self.stopTimer()
                        }
                    }
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    //Commented due to the page expire issue when before submitting the review after completion of a session
//                    self.isInTrainerProfilePage = false
//                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    func methodOfReceivedNotification(notif: NSNotification) {
        
        //print("ENTER FORGROUND",notif.name.rawValue)
        
        if notif.name.rawValue == "UIApplicationWillEnterForegroundNotification"{
            
            self.stopTimer()
            print("ENTER FORGROUND",notif.name.rawValue)
            if onlineavailabilty{
                self.runTimer()
            }
        }else if notif.name.rawValue == "UIApplicationDidEnterBackgroundNotification"{
            print("ENTER BACKGROUND",notif.name.rawValue)

            self.stopTimer()
            print("AVAILABITY",onlineavailabilty)
            
            if onlineavailabilty{
                self.runTimer()
            }
        }
    }

    func changeTextColorBlack() {
        
        btnEdit.title = "Save"
        txtFirstName.textColor = .black
        txtLastName.textColor = .black
        
        txtFirstName.isUserInteractionEnabled = true
        txtLastName.isUserInteractionEnabled = true
        
        btnChooseProfileImage.isUserInteractionEnabled = true
        btnChooseProfileImage.isHidden = false
    }
    
    func changeTextColorGrey() {
        
        btnEdit.title = "Edit"
        
        txtFirstName.textColor = .gray
        txtLastName.textColor = .gray
        lblEmail.textColor = .gray
        lblCountryCode.textColor = .gray
        lblMobile.textColor = .gray
        lblGender.textColor = .gray
        
        txtFirstName.isUserInteractionEnabled = false
        txtLastName.isUserInteractionEnabled = false
        
        btnChooseProfileImage.isUserInteractionEnabled = false
        btnChooseProfileImage.isHidden = true
    }

    //MARK: - EDIT/SAVE PROFILE ACTION
    
    @IBAction func editAction(_ sender: Any) {
        
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }

        if isEditingProfile{
            isEditingProfile = false
            changeTextColorGrey()
            editProfileServerCall()
        }else{
            isEditingProfile = true
            changeTextColorBlack()
        }
    }
    
    func validateFirstNameAndLastName() -> Bool {
        
        var isValidationSuccess = false
        if txtFirstName.text!.isEmpty {
            showAlertView(alertMessage:PLEASE_ENTER_FIRSTNAME)
        }else if txtLastName.text!.isEmpty {
            showAlertView(alertMessage:PLEASE_ENTER_LASTNAME)
        }else{
            isValidationSuccess = true
        }
        
        return isValidationSuccess
    }
    
    func showAlertView(alertMessage: String) {
        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: alertMessage, buttonTitle: "Ok")
    }
    
    func editProfileServerCall() {
        
        guard validateFirstNameAndLastName() else {
            isEditingProfile = true
            changeTextColorBlack()
            return
        }
        
        print("***** Edit profile Server Call *****")
        let parameters = ["user_type" : appDelegate.USER_TYPE,
                          "user_id" : appDelegate.UserId,
                          "first_name" : txtFirstName.text!,
                          "last_name" :txtLastName.text!,
                          "gender" : (lblGender.text!).lowercased(),
                          "user_image": profileImageURL,
                          "profile_desc":"tt",
                          "age" : ageValue,
                          "weight" : weightValue,
                          "height" : heightValue
            ] as [String : Any]
        
        print("PARAMS",parameters)
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: EDIT_PROFILE, parameters: parameters, onCompletion: { (jsondata) in
            print("EDIT PROFILE RESPONSE",jsondata)
            
            CommonMethods.hideProgress()
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    
                    let profileDict = jsondata["data"]  as! NSDictionary
                    print(profileDict)
                    
                   // let profileObj = self.trainerProfileModel.getTrainerProfileModelFromDict(dictionary: profileDict as! Dictionary<String, Any>)
                    self.fillValuesInForm(profile: profileDict)
                    
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PROFILE_UPDATED_SUCCESSFULLY, buttonTitle: "Ok")
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }else{
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "Ok")
                return
            }
        })
    }
    
    @IBAction func chooseProfileImageAction(_ sender: Any) {
    
        isUpdatingProfileImage = true
        chooseProfilePicture()
    }
    
    func fillValuesInForm(profile: NSDictionary) {
        //print("IMAGEEE",profile["user_image"] as! String)
        
        print("*** fillValuesInForm :\(profile)")
        let userName = (profile["first_name"] as! String) + " " + (profile["last_name"] as! String)
        userDefaults.set(userName, forKey: "userName")
        
        if let age = profile["age"] as? String{
            ageValue = age
            lblAge.text = "Trainer (\(ageValue))"
        }else{
            lblAge.text = "Trainer"
        }
        
        if let height = profile["height"] as? String{
            heightValue = height
            lblHeight.text = "\(heightValue) cm"
            imgHeightIcon.isHidden = false
        }else{
            lblHeight.isHidden = true
            imgHeightIcon.isHidden = true
        }
        
        if let weight = profile["weight"] as? String{
            weightValue = weight
            lblWeight.text = "\(weightValue) lbs"
            imgWeightIcon.isHidden = false
        }else{
            lblWeight.isHidden = true
            imgWeightIcon.isHidden = true
        }

        lblTrainerName.text = (profile["first_name"] as! String) + " " + (profile["last_name"] as! String)
        txtFirstName.text = profile["first_name"] as? String
        txtLastName.text = profile["last_name"] as? String
        lblEmail.text = profile["email"] as? String
        lblCountryCode.text = CommonMethods.phoneNumberSplit(number: profile["mobile"] as! String).0
        lblMobile.text = CommonMethods.phoneNumberSplit(number: profile["mobile"] as! String).1
        lblGender.text = (profile["gender"] as! String).uppercased()
        
        countrypicker.countryPickerDelegate = self
        countrypicker.showPhoneNumbers = true
        countrypicker.setCountryByPhoneCode(CommonMethods.phoneNumberSplit(number: profile["mobile"] as! String).0)
        
        if let image_url = profile["user_image"] as? String{
            
            if let imagearray = ProfileImageDB.fetchImage() {
                self.imageArray = imagearray as! Array<ProfileImageDB>
                
                guard self.imageArray.count > 0 else{
                    
                    self.profileImage.image = UIImage(named: "profileDemoImage")
                    return
                }
                self.objdata = self.imageArray[0].value(forKey: "imageData") as! NSData
                DispatchQueue.main.async {
                    print("This is run on the main queue, after the previous code in outer block")
                    self.profileImage.image = UIImage(data: self.objdata as Data)
                }
            }else{
            
                profileImage.sd_setImage(with: URL(string:image_url)) { (image, error, cacheType, imageURL) in
                    print("Image completion block")
                    if image != nil {
                        print("image found")
                        self.profileImage.image = image
                    }else{
                        print("image not found")
                        self.profileImage.image = UIImage(named: "profileDemoImage")
                    }
                }
            }
        }else{
            print("image not found1")
            self.profileImage.image = UIImage(named: "profileDemoImage")
//            profileImage.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: "profileDemoImage"))
        }
    }
    
    //MARK: - PREPARE FOR SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromprofiletocategorylist" {
            print("**** fromprofiletocategorylist Segue")
            let chooseCategoryPage =  segue.destination as! CategoryListVC
            chooseCategoryPage.FromTrainerProfileBool = true
        }else if segue.identifier == "trainerHomePageToRoutePageSegue" {
            let timerPage =  segue.destination as! TrainerTraineeRouteViewController
            timerPage.seconds = numOfDays
            timerPage.TIMERCHECK = true
        }
    }
}

extension TrainerProfilePage: CountryPickerDelegate{
    
    public func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        print("** didSelectCountryWithName:\(flag) **")
        imgFlag.image = flag
    }
}

//MARK: - TABLEVIEW DATASOURCE FUNCTIONS

extension TrainerProfilePage: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainerProfileViewTableCaptionsArray.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 {
            let cell: AssignedTrainerProfileTableCaptionsCell = tableView.dequeueReusableCell(withIdentifier: "captionCellId") as! AssignedTrainerProfileTableCaptionsCell
            
            cell.title_lbl.text = trainerProfileViewTableCaptionsArray[indexPath.row]
            
            return cell
            
        }else if indexPath.row == 3{
            let socialMediaCell: AssignedTrainerSocialMediaCell = tableView.dequeueReusableCell(withIdentifier: "socialMediaCellId") as! AssignedTrainerSocialMediaCell
            
            socialMediaCell.btnFacebook.addTarget(self, action: #selector(TrainerProfilePage.facebookAction(sender:)), for: .touchUpInside)
            socialMediaCell.btnInstagram.addTarget(self, action: #selector(TrainerProfilePage.instagramAction(sender:)), for: .touchUpInside)
            socialMediaCell.btnLinkdIn.addTarget(self, action: #selector(TrainerProfilePage.linkdInAction(sender:)), for: .touchUpInside)
            socialMediaCell.btnSnapchat.addTarget(self, action: #selector(TrainerProfilePage.snapChatAction(sender:)), for: .touchUpInside)
            socialMediaCell.btnTwitter.addTarget(self, action: #selector(TrainerProfilePage.twitterAction(sender:)), for: .touchUpInside)
            socialMediaCell.btnYoutube.addTarget(self, action: #selector(TrainerProfilePage.youtubeAction(sender:)), for: .touchUpInside)
            
            return socialMediaCell
        }else{
            let cell: AssignedTrainerEmailCell = tableView.dequeueReusableCell(withIdentifier: "emailCellId") as! AssignedTrainerEmailCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var row = 0.0
        
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 {
            row = 60.0
        }else if indexPath.row == 3{
            row = 123.0
        }else{
            row = 60.0
        }
        return CGFloat(row)
    }
}

//MARK: - SOCIAL MEDIA BUTTON ACTIONS
extension TrainerProfilePage {
    
    func facebookAction(sender : UIButton){
        
        if let facebook_id = userDefaults.value(forKey: "facebookId") as? String {
            facebookLink = facebook_id
        }
        
        if !facebookLink.isEmpty{
            openFBProfile(facebookUserID: facebookLink)
        }else if facebookLink.isEmpty{
            loginWithFacebook()
        }
    }
    
    func instagramAction(sender : UIButton){
        
        if isEditingProfile {
            showAlertWithTextBox(messageString: "Please enter instagram username", withPlaceholder: "Username", socialMediaType: SOCIAL_MEDIA_TYPES.INSTAGRAM)
        }else if !instagramLink.isEmpty{
            openInstagramProfile(instagramProfileName: instagramLink)
        }else if instagramLink.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Instagram profile is not linked", buttonTitle: "OK")
        }
    }
    
    func linkdInAction(sender : UIButton){
    }
    
    func snapChatAction(sender : UIButton){
    }

    func twitterAction(sender : UIButton){
        
        if isEditingProfile {
            showAlertWithTextBox(messageString: "Please enter Twitter username", withPlaceholder: "Username", socialMediaType: SOCIAL_MEDIA_TYPES.TWITTER)
        }else if !twitterLink.isEmpty{
            openTwitterProfile(twitterUsername: twitterLink)
        }else if twitterLink.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Twitter profile is not linked", buttonTitle: "OK")
        }
    }

    func youtubeAction(sender : UIButton){
        
        if isEditingProfile {
            showAlertWithTextBox(messageString: "Please enter Youtube link", withPlaceholder: "Please paste youtube link here", socialMediaType: SOCIAL_MEDIA_TYPES.YOUTUBE)
        }else if !youtubeLink.isEmpty{
            openYoutubeLink(youtubeLink: youtubeLink)
        }else if youtubeLink.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Youtube link not provided", buttonTitle: "OK")
        }
    }
    
    func showAlertWithTextBox(messageString: String, withPlaceholder placeholderString: String, socialMediaType socialType: String) {
        
        let alertController = UIAlertController(title: ALERT_TITLE, message: messageString, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                print("entered Field:\(String(describing: field.text!))")
                
                guard field.text != "" else{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please enter \(placeholderString)", buttonTitle: "OK")
                    return
                }
                
                self.saveSocialMediaLinks(enteredValue: field.text!, socialMediaType: socialType)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = placeholderString
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func saveSocialMediaLinks(enteredValue: String, socialMediaType: String) {
        
        switch socialMediaType {
        case SOCIAL_MEDIA_TYPES.FACEBOOK:
            print("FACEBOOK")
            
            facebookLink = enteredValue
            break
        case SOCIAL_MEDIA_TYPES.TWITTER:
            print("TWITTER")
            
            twitterLink = enteredValue
            break
        case SOCIAL_MEDIA_TYPES.INSTAGRAM:
            print("INSTAGRAM")

            instagramLink = enteredValue
            break
        case SOCIAL_MEDIA_TYPES.LINKDIN:
            print("LINKDIN")

            linkdInLink = enteredValue
            break
        case SOCIAL_MEDIA_TYPES.SNAPCHAT:
            print("SNAPCHAT")

            snapchatLink = enteredValue
            break
        case SOCIAL_MEDIA_TYPES.YOUTUBE:
            print("YOUTUBE")

            youtubeLink = enteredValue
            break

        default:
            print("Default case in saveSocialMediaLinks")
        }
    }
    
    //MARK: - OPEN SOCIAL MEDIA WITH URL's
    func openTwitterProfile(twitterUsername: String) {
        
        let twitterProfileUrl = URL(string: "twitter://user?screen_name=\(twitterUsername)")
        UIApplication.shared.open(twitterProfileUrl!, options: [:])
    }

    func openFBProfile(facebookUserID: String) {
        
        if UIApplication.shared.canOpenURL(URL(string: "fb://profile/\(facebookUserID)")!) {
            //            UIApplication.shared.open(URL(string: "fb://profile?app_scoped_user_id=1442756282446578")!, options: [:])
            UIApplication.shared.open(URL(string: "https://facebook.com/\(facebookUserID)")!, options: [:])
        } else {
            UIApplication.shared.open(URL(string: "https://facebook.com/\(facebookUserID)")!, options: [:])
        }
    }
    
    func openInstagramProfile(instagramProfileName: String) {
        
        let instagramHooks = "instagram://user?username=\(instagramProfileName)"
        let instagramUrl = NSURL(string: instagramHooks)
        
        if UIApplication.shared.canOpenURL(instagramUrl! as URL){
            UIApplication.shared.open(instagramUrl! as URL, options: [:])
        } else {
            UIApplication.shared.open(NSURL(string: "http://instagram.com/")! as URL, options: [:])
        }
    }
    
    func openYoutubeLink(youtubeLink: String){
        let youtubeId = extractYoutubeIdFromLink(link: youtubeLink)
        print("Youtube Identifier :\(String(describing: youtubeId!))")
        UIApplication.shared.open(NSURL(string: "youtube://watch?v=\(youtubeId!)")! as URL, options: [:])
    }
    
    func extractYoutubeIdFromLink(link: String) -> String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        guard let regExp = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        let nsLink = link as NSString
        let options = NSRegularExpression.MatchingOptions(rawValue: 0)
        let range = NSRange(location: 0, length: nsLink.length)
        let matches = regExp.matches(in: link as String, options:options, range:range)
        if let firstMatch = matches.first {
            return nsLink.substring(with: firstMatch.range)
        }
        return nil
    }
    
    func loginWithFacebook() {
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                
                if (result?.isCancelled)! {
                    return
                }
                
                if(fbloginresult.grantedPermissions.contains("email")){
                    self.getFBUserData()
                }
            }else{
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: REQUEST_TIMED_OUT, buttonTitle: "OK")
                print("FB ERROR")
            }
        }
    }
    
    func getFBUserData(){
        
        CommonMethods.showProgress()
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                
                CommonMethods.hideProgress()
                if (error == nil){
                    
                    print("RESULT Login",result!)
                    self.fbUserDictionary = result as? NSDictionary
                    
                    let facebookId = (self.fbUserDictionary["id"] as? String)!
                    print("Facebook ID:\(facebookId)")
                    userDefaults.set(facebookId, forKey: "facebookId")
                    self.openFBProfile(facebookUserID: facebookId)
                }else{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: error?.localizedDescription, buttonTitle: "OK")
                    print("ERROR123",error?.localizedDescription as Any)
                }
            })
        }
    }
}

//MARK: - TABLEVIEW DELEGATE FUNCTIONS

extension TrainerProfilePage: UITableViewDelegate{
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1{
            print("**** Did select Training Category ****")
            self.performSegue(withIdentifier: "fromprofiletocategorylist", sender: self)
        }
    }
}

//MARK: - CHOOSE PROFILE PICTURE

extension TrainerProfilePage: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func chooseProfilePicture(){
        
        let actionSheet: UIAlertController = UIAlertController(title: "Edit Profile Picture", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction) -> Void in
            actionSheet.dismiss(animated: true, completion: {() -> Void in
            })
        }))
        actionSheet.addAction(UIAlertAction(title: "From Gallery", style: .default, handler: {(action: UIAlertAction) -> Void in
            self.fromGallery()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Take Picture", style: .default, handler: {(action: UIAlertAction) -> Void in
            self.fromCamera()
        }))
        self.present(actionSheet, animated: true, completion: { _ in })
    }
    
    func fromGallery() {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func fromCamera(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker,
                animated: true,
                completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print("*** didFinishPickingMediaWithInfo")
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        dismiss(animated: true, completion: nil)
    
        var imagePickedData = NSData()
        imagePickedData = UIImageJPEGRepresentation(chosenImage, 1.0)! as NSData
        self.uploadImageAPI(imagedata: imagePickedData)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImageAPI(imagedata : NSData) {
        
        print("**** uploadImageAPI")
        
        let headers = [
            "token" : appDelegate.Usertoken,
            "user_type" : appDelegate.USER_TYPE
        ]
        
        let parameters = [
            "file_type" : "img",
            "upload_type" : "profile"
        ]
        
        print("PARAMS",parameters)
        print("HEADERS",headers)
        
        let imageUploadURL = SERVER_URL + UPLOAD_VIDEO_AND_IMAGE
        print("Image Upload URL",imageUploadURL)
        
        CommonMethods.showProgress()
        var uploadImageData = NSData()
        uploadImageData = imagedata
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            for (key, value) in parameters {
                
                print("PARAMETER Value:",value)
                print("PARAMETER Key:",key)
                
                multipartFormData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
            }
            
            if UIImageJPEGRepresentation(self.profileImage.image!, 0.6) != nil {
                multipartFormData.append(uploadImageData as Data, withName: "file_name", fileName: "image.png", mimeType: "image/png")
            }else{
                print("** No image data found **")
            }
        }, to: imageUploadURL,
           method:.post,
           headers:headers,
           
           encodingCompletion: { encodingResult in
            
            switch encodingResult {
                
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    print("Response:\(response)")
                    if let jsonDic = response.result.value as? NSDictionary{
                        print("JSON DICT:",jsonDic)
                        
                        if let status = jsonDic["status"] as? Int{
                            if status == RESPONSE_STATUS.SUCCESS{
                                
                                CommonMethods.hideProgress()
                                self.profileImage.image = UIImage(data:(uploadImageData as NSData) as Data,scale:1.0)
                                self.profileImageURL = (jsonDic["Url"] as? String)!
                                self.isUpdatingProfileImage = false
//                                print("*** editProfileServerCall inside Image upload")
//                                self.editProfileServerCall()
                                
                                ProfileImageDB.save(imageURL: (jsonDic["Url"] as? String)!, imageData: uploadImageData as Data as Data as NSData)
                            }else if status == RESPONSE_STATUS.FAIL{
                                CommonMethods.hideProgress()
                                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsonDic["message"] as? String, buttonTitle: "Ok")
                            }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                                CommonMethods.hideProgress()
                                self.dismissOnSessionExpire()
                            }
                        }else{
                            CommonMethods.hideProgress()
                            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please try again", buttonTitle: "Ok")
                            self.profileImageURL = ""
                        }
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                CommonMethods.hideProgress()
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please try again", buttonTitle: "Ok")
                self.profileImageURL = ""
            }
        })
    }

}
extension TrainerProfilePage: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            
            print("**********************")
            print("Long \(location.coordinate.longitude)")
            print("Lati \(location.coordinate.latitude)")            
            print("**********************")                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
            
            lat = Float(location.coordinate.latitude)
            long = Float(location.coordinate.longitude)
            
        }
        self.UpdateLocationAPI(Status: "online")
        locationManager.stopUpdatingLocation()
    }
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
          
        }
    }
}
