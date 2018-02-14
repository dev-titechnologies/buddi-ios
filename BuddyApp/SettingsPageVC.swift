//
//  SettingsPageVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 24/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import TwitterKit
import TwitterCore
import FBSDKCoreKit
import FBSDKLoginKit

class SettingsPageVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var settingsTableView: UITableView!
    var headerSectionTitles = [String]()
    
    let sessionTime = ["40","60"]
    var collapseArray = [Bool]()
    var sessionChoosed = Int()
    var headerChoosed = Int()
    var isChoosedGender = Bool()
    var locationcordinate = CLLocationCoordinate2D()
    var dict = NSMutableDictionary()
    var sessionCell = SessionPreferenceCell()
    var preferanceBool = Bool()
    var preferenceValuesDict = NSDictionary()
    
    var locationLatitude = String()
    var locationLongitude = String()
    
    var choosed_session_duration = String()

    var trainingLocationModelObj = TrainingLocationModel()
    var preferenceModelObj = PreferenceModel()
    
    var isTwitterAutoShare = Bool()
    var isFacebookAutoShare = Bool()
    var twitterUserName = String()
    var isTwitterSessionPresent = Bool()
    
    var facebookUserName = String()
    var isFacebookSessionPresent = Bool()
    
    var isFromTrainer = Bool()
    
    var choosed_trainer_gender_preference = String()
    
    var extensionSessionDurationArray = [SessionDurationModel]()
    var normalSessionDurationArray = [SessionDurationModel]()
    var choosedSessionIndex = Int()
    
    //MARK: - VIEW CYCLES 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferanceBool = false

        self.title = PAGE_TITLE.SETTINGS
        
        sessionChoosed = -1
        headerChoosed = -1
        
        if appDelegate.USER_TYPE == USER_TYPE.TRAINEE{
         //  headerSectionTitles = ["Location Preference" ,"Training Category Preference", "Gender Preference", "Session Length Preference", "Social Media Auto Share"]
            
            headerSectionTitles = ["Location Preference" ,"Training Category Preference", "Gender Preference", "Session Length Preference"]

            
        }else{
            headerSectionTitles = ["Social Media Auto Share"]
        }

        for _ in 0..<headerSectionTitles.count{
            collapseArray.append(false)
        }
        
        getPreferenceModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("Settings Page ViewWillAppear")
        
        fetchSessionDurations()
        
        if appDelegate.USER_TYPE == USER_TYPE.TRAINEE {
            self.settingsTableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
        fetchSocialAutoShareValuesFromUserDefaults()
    }
    
    func fetchSocialAutoShareValuesFromUserDefaults() {
        
        if userDefaults.bool(forKey: "isFacebookAutoShare"){
            isFacebookAutoShare = true
            isFacebookSessionPresent = true
            facebookUserName = userDefaults.value(forKey: "facebookUserName") as! String
        }else{
            isFacebookAutoShare = false
        }
        
        if userDefaults.bool(forKey: "isTwitterAutoShare"){
            isTwitterAutoShare = true
        }else{
            isTwitterAutoShare = false
        }
        
        if let session = TWTRTwitter.sharedInstance().sessionStore.session() {
            print("*** Twitter Session present ***")
            print("Session ID:\(session.userID)")
            let client = TWTRAPIClient()
            client.loadUser(withID: session.userID) { (user, error) -> Void in
                if let user = user {
                    self.isTwitterSessionPresent = true
                    self.twitterUserName = user.screenName
                    print("Session Name:\(user.screenName)")
                }
            }
        }
    }
    
    func requestFacebookPublishAction() {
        
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logOut()
        fbLoginManager.logIn(withPublishPermissions: ["publish_actions"], from: self) { (result, error) in
            
            print("RESULT logIn(withPublishPermissions:\(String(describing: result))")
            print("ERROR logIn(withPublishPermissions:\(String(describing: error?.localizedDescription))")

            if (error != nil) {
                print(error!)
                self.isFacebookSessionPresent = false
                self.isFacebookAutoShare = false
                self.reloadSection(row: 0)

            } else if (result?.isCancelled)! {
                print("Canceled")
                self.isFacebookSessionPresent = false
                self.isFacebookAutoShare = false
                self.reloadSection(row: 0)

            } else if (result?.grantedPermissions.contains("publish_actions"))! {
                print("permissions granted")
                
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if(fbloginresult.grantedPermissions.contains("publish_actions")){
                    self.getFBUserData()
                }
            }else{
                print("Error Case")
                self.isFacebookSessionPresent = false
                self.isFacebookAutoShare = false
                self.reloadSection(row: 0)
            }
        }
    }
    
//        if !(FBSDKAccessToken.current().hasGranted("publish_actions")) {
//            
//            print("Request publish_actions permissions")
//            let login: FBSDKLoginManager = FBSDKLoginManager()
//            
//            login.logIn(withPublishPermissions: ["publish_actions"], from: self) { (result, error) in
//                if (error != nil) {
//                    print(error!)
//                } else if (result?.isCancelled)! {
//                    print("Canceled")
//                } else if (result?.grantedPermissions.contains("publish_actions"))! {
//                    print("permissions granted")
//                    
//                }
//            }
//        }else {
//            print("TEST Error")
//        }
    
//    func btnPostMsg() {
//        
//        if FBSDKAccessToken.current().hasGranted("publish_actions") {
//            
//            FBSDKGraphRequest.init(graphPath: "me/feed", parameters: ["message" : "Posted with FBSDK Graph API."], httpMethod: "POST").start(completionHandler: { (connection, result, error) -> Void in
//                if let error = error {
//                    print("Error: \(error)")
//                } else {
//                    //self.alertShow("Message")
//                    print("** Shared Post in Facebook Successfully **")
//                }
//            })
//        } else {
//            print("require publish_actions permissions")
//        }
//    }
    
//    func facebookLogin() {
//        
//        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
//        fbLoginManager.logOut()
//        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
//            if (error == nil){
//                let fbloginresult : FBSDKLoginManagerLoginResult = result!
//                
//                if (result?.isCancelled)! {
//                    return
//                }
//                
//                if(fbloginresult.grantedPermissions.contains("email")){
//                    self.getFBUserData()
//                }
//            }else{
//                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: REQUEST_TIMED_OUT, buttonTitle: "OK")
//                print("FB ERROR")
//            }
//        }
//    }
//    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    print("RESULT Login",result!)
                    let fbUserDictionary = result as? NSDictionary
                    print("fbUserDictionary:\(String(describing: fbUserDictionary))")
                    
                    let facebookName = (fbUserDictionary?["name"] as? String)!

                    self.facebookUserName = facebookName
                    userDefaults.set(facebookName, forKey: "facebookUserName")
                    userDefaults.set(true, forKey: "isFacebookAutoShare")
                    self.isFacebookSessionPresent = true
                    self.isFacebookAutoShare = true
                    self.reloadSection(row: 0)
                }else{
                    print("ERROR logIn(withPublishPermissions:\(String(describing: error?.localizedDescription))")
                    self.isFacebookSessionPresent = false
                    self.isFacebookAutoShare = false
                    self.reloadSection(row: 0)
                }
            })
        }
    }

    func getPreferenceModel() {
        
        if userDefaults.value(forKey: "save_preferance") as? NSDictionary != nil{
            let dict = userDefaults.value(forKey: "save_preferance") as? NSDictionary
            preferenceModelObj = getPreferenceObjectFromDictionary(dictionary: dict!)
        }
    }
    
    func getPreferenceObjectFromDictionary(dictionary: NSDictionary) -> PreferenceModel {
        
        let preference_obj = PreferenceModel()
        
        preference_obj.categoryId = dictionary["categoryid"] as! String
        preference_obj.gender = dictionary["gender"] as! String
        preference_obj.sessionDuration = dictionary["time"] as! String
        preference_obj.locationName = dictionary["locationName"] as! String
        preference_obj.locationLattitude = dictionary["lat"] as! String
        preference_obj.locationLongitude = dictionary["long"] as! String
        preference_obj.categoryName = dictionary["categoryName"] as! String
        
        choosed_trainer_gender_preference = preference_obj.gender
        choosedSessionOfTraineePreference = preference_obj.sessionDuration
        choosedCategoryOfTraineePreference.categoryId = preference_obj.categoryId
        choosedCategoryOfTraineePreference.categoryName = preference_obj.categoryName
        choosedTrainingLocationPreference = preference_obj.locationName
        choosed_session_duration = preference_obj.sessionDuration
        
        locationLatitude = preference_obj.locationLattitude
        locationLongitude = preference_obj.locationLongitude
        
        return preference_obj
    }
    
    //MARK: - SAVE ACTION
    
    @IBAction func Save_action(_ sender: Any) {
        
        if choosedTrainingLocationPreference.isEmpty {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please select location", buttonTitle: "Ok")
        }else if choosedCategoryOfTraineePreference.categoryId.isEmpty {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please choose category", buttonTitle: "Ok")
        }else if choosed_trainer_gender_preference.isEmpty {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please select gender", buttonTitle: "Ok")
        }else if choosedSessionOfTraineePreference.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please choose session time", buttonTitle: "Ok")
        }else{
            preferanceBool = false
            print("GENDER",choosed_trainer_gender_preference)
            print("TIME",choosedSessionOfTraineePreference)
            print("CATEGORY",choosedCategoryOfTraineePreference.categoryId)
            print("location",choosedTrainingLocationPreference)
            
            dict.setValue(choosed_trainer_gender_preference, forKey: "gender")
            dict.setValue(choosedSessionOfTraineePreference, forKey: "time")
            dict.setValue(String(choosedCategoryOfTraineePreference.categoryId), forKey: "categoryid")
            dict.setValue(String(choosedCategoryOfTraineePreference.categoryName), forKey: "categoryName")
            dict.setValue(locationLatitude, forKey: "lat")
            dict.setValue(locationLongitude, forKey: "long")
            dict.setValue(choosedTrainingLocationPreference, forKey: "locationName")
            
            print("Save preference Settings dict:\(dict)")

            userDefaults.setValue(dict, forKey: "save_preferance")
            savedAlert()
//            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Saved successfully", buttonTitle: "Ok")
        }
    }
    
    func savedAlert() {
        
        let alert = UIAlertController(title: ALERT_TITLE, message: INSTANT_BOOKING_PREFERENCES_SAVED_SUCCESSFULLY, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingtocatagorylist" {
            let chooseCategoryPage =  segue.destination as! TraineeHomePage
            chooseCategoryPage.isFromSettings = true
        }
    }
    
    func GooglePlacePicker(){
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    //MARK: - FETCH SESSION DURATIONS
    
    func fetchSessionDurations() {
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: LIST_SESSIONS, parameters: ["":""]) { (jsondata) in
            print("fetchSessionDurations Response: \(jsondata)")
            CommonMethods.hideProgress()

            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    if let jsonDict = jsondata["data"] as? NSDictionary{
                        
                        let sessions = 
                            CommonMethods.getNormalAndExtensionSessionDurationArrays(sessionsDictionary: jsonDict)
                        self.normalSessionDurationArray = sessions.0
                        self.extensionSessionDurationArray = sessions.1
                        
                        CommonMethods.storeSessionDurationToUserDefaults(normalDuration: self.normalSessionDurationArray, extendDuration: self.extensionSessionDurationArray)

                        self.settingsTableView.reloadData()
                    }
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        }
    }
    
}

//MARK: - TABLEVIEW DELEGATES AND DATASOURCE

extension SettingsPageVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if appDelegate.USER_TYPE == USER_TYPE.TRAINEE{
            if section == 2{
                return 1
            }else if section == 3{
                return normalSessionDurationArray.count
            }else if section == 4 {
             //   return socialMediaTitles.count
               return 0 
            }else{
                return 0
            }
        }else{
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("Indexpath:\(indexPath.row)")
        if indexPath.section == 3{
            //Preferred Session
            sessionCell = tableView.dequeueReusableCell(withIdentifier: "chooseSessionCellId") as! SessionPreferenceCell
            
//            sessionCell.lblSessionDuration.text = trainingDurationArray[indexPath.row]
//            sessionCell.lblSessionDuration.text = CommonMethods.cellDisplayDuration(row: indexPath.row)
            sessionCell.lblSessionDuration.text = normalSessionDurationArray[indexPath.row].sessionTitle

            // PREFERENCE SHOWN
            if preferenceModelObj.sessionDuration != "" {
                print("preferenceModelObj.sessionDuration:\(preferenceModelObj.sessionDuration)")
                let session_split = preferenceModelObj.sessionDuration.components(separatedBy: " ") as Array
                print("session_split:\(session_split)")
                let session_duration = self.sessionTime.index(of: session_split[0])
                //let session_duration = session_split[0]
                print("Session Duration:\(String(describing: session_duration))")
                if !preferanceBool{
                    sessionChoosed = Int(session_duration!)
                }
            }
            
            if sessionChoosed == indexPath.row{
                sessionCell.backgroundCardView.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            }else{
                sessionCell.backgroundCardView.backgroundColor = .white
            }
            
            return sessionCell
        }else if indexPath.section == 2{
            //Preferred Gender
            
            let genderCell: GenderPreferenceCell = tableView.dequeueReusableCell(withIdentifier: "chooseGenderCellId") as! GenderPreferenceCell
            
            genderCell.selectionStyle = UITableViewCellSelectionStyle.none
            
            genderCell.btnMale.addShadowView()
            genderCell.btnFemale.addShadowView()
            genderCell.btnNopreferance.addShadowView()
            
            genderCell.btnMale.tag = 1
            genderCell.btnFemale.tag = 2
            genderCell.btnNopreferance.tag = 3
            
            switch choosedTrainerGenderOfTraineePreference {
            case "Male":
                genderCell.btnMale.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
                genderCell.btnFemale.backgroundColor = .white
                genderCell.btnNopreferance.backgroundColor = .white
                
            case "Female":
                genderCell.btnMale.backgroundColor = .white
                genderCell.btnFemale.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
                genderCell.btnNopreferance.backgroundColor = .white
                
            case "No Preference":
                genderCell.btnMale.backgroundColor = .white
                genderCell.btnFemale.backgroundColor = .white
                genderCell.btnNopreferance.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
                
            default:
                print("Default case in gender color")
            }
            
            genderCell.btnMale.addTarget(self, action: #selector(ChooseSessionAndGenderVC.choosedGender(sender:)), for: .touchUpInside)
            genderCell.btnFemale.addTarget(self, action: #selector(ChooseSessionAndGenderVC.choosedGender(sender:)), for: .touchUpInside)
            genderCell.btnNopreferance.addTarget(self, action: #selector(ChooseSessionAndGenderVC.choosedGender(sender:)), for: .touchUpInside)
            
            return genderCell
        }else if indexPath.section == 4{
            //Social Media Auto Share
            return socialShareTableCell(tableView, index_path: indexPath)
        }else{
            
            if appDelegate.USER_TYPE == USER_TYPE.TRAINEE{
                let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellid")!
                return cell
            }else{
                return socialShareTableCell(tableView, index_path: indexPath)
            }
        }
    }
    
    func socialShareTableCell(_ tableView: UITableView, index_path: IndexPath) -> SocialAutoShareCell {
        
        let socialShareCell: SocialAutoShareCell = tableView.dequeueReusableCell(withIdentifier: "socialAutoShareCellId") as! SocialAutoShareCell
        
        socialShareCell.selectionStyle = UITableViewCellSelectionStyle.none
        socialShareCell.lblSocialTitle.text = socialMediaTitles[index_path.row]
        
        socialShareCell.btnSwitch.tag = index_path.row
        socialShareCell.btnSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        
        if index_path.row == 0 && isFacebookAutoShare {
            socialShareCell.btnSwitch.isOn = true
            socialShareCell.lblUserName.text = self.facebookUserName
            socialShareCell.lblUserName.isHidden = false
        }else if index_path.row == 0 && !isFacebookAutoShare && isFacebookSessionPresent{
            socialShareCell.btnSwitch.isOn = false
            socialShareCell.lblUserName.text = self.facebookUserName
            socialShareCell.lblUserName.isHidden = false
        }else if index_path.row == 0 && !isFacebookSessionPresent {
            socialShareCell.lblUserName.isHidden = true
            socialShareCell.btnSwitch.isOn = false
        }else if index_path.row == 1 && isTwitterAutoShare {
            socialShareCell.btnSwitch.isOn = true
            socialShareCell.lblUserName.text = self.twitterUserName
            socialShareCell.lblUserName.isHidden = false
        }else if index_path.row == 1 && !isTwitterAutoShare  && isTwitterSessionPresent{
            socialShareCell.btnSwitch.isOn = false
            socialShareCell.lblUserName.text = self.twitterUserName
            socialShareCell.lblUserName.isHidden = false
        }else if index_path.row == 1 && !isTwitterSessionPresent {
            socialShareCell.lblUserName.isHidden = true
            socialShareCell.btnSwitch.isOn = false
        }
        
        return socialShareCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if collapseArray[indexPath.section]{
            if indexPath.section == 3 || indexPath.section == 4{
                return 60
            }else if indexPath.section == 2{
                return 114
            }else if indexPath.section == 0 && appDelegate.USER_TYPE == USER_TYPE.TRAINER{
                return 60
            }else{
                return 0
            }
        }else{
            return 0
        }
    }
    
    func switchValueDidChange(_ sender: UISwitch) {

        print("Switch button tag:\(sender.tag)")
        if sender.tag == 0 {
            //Facebook
            
            if isFacebookAutoShare{
                userDefaults.set(false, forKey: "isFacebookAutoShare")
                isFacebookAutoShare = false
                reloadSection(row: sender.tag)
            }else{
                
                if isFacebookSessionPresent{
                    userDefaults.set(true, forKey: "isFacebookAutoShare")
                    isFacebookAutoShare = true
                    print("User Name1:\(self.facebookUserName)")
                    reloadSection(row: sender.tag)
                }else{
//                    facebookLogin()
                    requestFacebookPublishAction()
                }
            }
            
        }else if sender.tag == 1{
            //Twitter
            
            if isTwitterAutoShare{
                userDefaults.set(false, forKey: "isTwitterAutoShare")
                isTwitterAutoShare = false
                reloadSection(row: sender.tag)
            }else{
                
                print("isTwitterSessionPresent:\(isTwitterSessionPresent)")
                if isTwitterSessionPresent{
                    userDefaults.set(true, forKey: "isTwitterAutoShare")
                    isTwitterAutoShare = true
                    print("User Name1:\(self.twitterUserName)")
                    reloadSection(row: sender.tag)
                }else{
                    TWTRTwitter.sharedInstance().logIn { session, error in
                        print("*** Twitter Login Completion Handler ***")
                        if (session != nil){
                            print("User Name:\((session?.userName)!)")
                            self.twitterUserName = (session?.userName)!
                            
                            userDefaults.set(true, forKey: "isTwitterAutoShare")
                            userDefaults.set(session?.userID, forKey: "TwitterUserId")

                            self.isTwitterSessionPresent = true
                            self.isTwitterAutoShare = true
                            self.reloadSection(row: sender.tag)
                        }else{
                            self.isTwitterSessionPresent = false
                            self.isTwitterAutoShare = false
                            self.reloadSection(row: sender.tag)
                        }
                    }
                }
            }
        }
    }
    
    func reloadSection(row: Int) {
        
        if appDelegate.USER_TYPE == USER_TYPE.TRAINEE{
            let indexpath: IndexPath = IndexPath.init(row: row, section: 4)
            self.settingsTableView.reloadRows(at: [indexpath], with: .automatic)
        }else{
            let indexpath: IndexPath = IndexPath.init(row: row, section: 0)
            self.settingsTableView.reloadRows(at: [indexpath], with: .automatic)
        }
    }
    
    func choosedGender(sender : UIButton){
        print("Choose gender Action")
        
        print("Button Tapped 123")
        
        switch sender.tag {
        case 1:
            choosedTrainerGenderOfTraineePreference = "Male"
            choosed_trainer_gender_preference = "male"
        case 2:
            choosedTrainerGenderOfTraineePreference = "Female"
            choosed_trainer_gender_preference = "female"
        case 3:
            choosedTrainerGenderOfTraineePreference = "No Preference"
            choosed_trainer_gender_preference = "nopreference"
            
        default:
            print("Gender Default Case catched")
        }

        self.settingsTableView.reloadSections(IndexSet(integer: 2), with: .automatic)
        
//        choosed_trainer_gender = "No Preference"
//        choosedTrainerGenderOfTrainee = "nopreference"
    }
    
    //MARK: - TABLEVIEW HEADER SECTION VIEW
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell: PreferenceSectionHeader = tableView.dequeueReusableCell(withIdentifier: "sectionHeaderCellId") as! PreferenceSectionHeader
        
        cell.lblHeaderSectionTitle.text = headerSectionTitles[section]
        
        if headerChoosed == -1{
            print("Init")
            cell.imgArrow.image = UIImage(named: "rightArrow")
        }else if collapseArray[headerChoosed] {
            cell.imgArrow.image = UIImage(named: "downArrow")
        }else{
            cell.imgArrow.image = UIImage(named: "rightArrow")
        }
        
        switch section {
        case 0:
            //Location
            if appDelegate.USER_TYPE == USER_TYPE.TRAINEE{
                print("**** choosedTrainingLocationPreference:\(choosedTrainingLocationPreference)")
                cell.lblSelectedValue.text = choosedTrainingLocationPreference
            }
        case 1:
            //Category
            print("**** choosedCategoryOfTraineePreference categoryName:\(choosedCategoryOfTraineePreference.categoryName)")
            cell.lblSelectedValue.text = choosedCategoryOfTraineePreference.categoryName
        case 2:
            //Gender
            print("**** choosedTrainerGenderOfTraineePreference:\(choosed_trainer_gender_preference)")
            
            if choosed_trainer_gender_preference == "male" {
                choosedTrainerGenderOfTraineePreference = "Male"
                cell.lblSelectedValue.text = "Male"
            }else if choosed_trainer_gender_preference == "female" {
                choosedTrainerGenderOfTraineePreference = "Female"
                cell.lblSelectedValue.text = "Female"
            }else if choosed_trainer_gender_preference == "nopreference" {
                choosedTrainerGenderOfTraineePreference = "No Preference"
                cell.lblSelectedValue.text = "No Preference"
            }
        case 3:
            //Session
            print("**** choosed_session_duration:\(choosed_session_duration)")
            
            if choosed_session_duration != "" {
//                let secondsValue = Double(choosed_session_duration)! * 60
//                cell.lblSelectedValue.text = CommonMethods.cellDisplayDurationValue(secondsValue: Int(secondsValue))
                
                cell.lblSelectedValue.text = normalSessionDurationArray[choosedSessionIndex].sessionTitle
            }
//            if choosed_session_duration == "40" {
//                cell.lblSelectedValue.text = "40 Minutes"
//            }else if choosed_session_duration == "60" {
//                cell.lblSelectedValue.text = "1 Hour"
//            }

        default:
            print("View for sectionheader Default Case catched")
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapSectionHeader(_:)))
        cell.contentView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        tapGesture.view?.tag = section
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        preferanceBool = true
        sessionChoosed = indexPath.row
//        settingsTableView.reloadSections(IndexSet(integer: 3), with: .automatic)
        
        if indexPath.section == 2{
            print("*** didSelectRowAt: section 2")
            self.settingsTableView.reloadSections(IndexSet(integer: 2), with: .automatic)
        }else if indexPath.section == 3{
            print("*** didSelectRowAt: section 3")
            
//            choosedSessionOfTraineePreference = String(trainingDurationSecondsArray[indexPath.row] / 60)
            choosedSessionOfTraineePreference = normalSessionDurationArray[indexPath.row].sessionDuration
            choosedSessionIndex = indexPath.row
            print("choosedSessionOfTraineePreference:\(choosedSessionOfTraineePreference)")
//            if indexPath.row == 0 {
//                choosedSessionOfTraineePreference = "40"
//            }else{
//                choosedSessionOfTraineePreference = "60"
//            }
            
            choosed_session_duration = choosedSessionOfTraineePreference
            self.settingsTableView.reloadSections(IndexSet(integer: 3), with: .automatic)
        }
      
        print("Choosed Session:\(choosedSessionOfTraineePreference)")
    }
    
    func didTapSectionHeader(_ sender: UITapGestureRecognizer) {
        print("Please Help!")
        
        let indexpath: IndexPath = IndexPath.init(row: 0, section: (sender.view?.tag)!)
        print("Tapped Index:",indexpath.section)
        
        headerChoosed = (sender.view?.tag)!
        let collapsed = collapseArray[indexpath.section]
        
        if indexpath.section == 0 && appDelegate.USER_TYPE == USER_TYPE.TRAINER{
            self.collapseArray[indexpath.section] = !collapsed
            self.settingsTableView.reloadSections(IndexSet(integer: indexpath.section), with: .automatic)
        }else if indexpath.section == 2 || indexpath.section == 3 || indexpath.section == 4 {
            self.collapseArray[indexpath.section] = !collapsed
            self.settingsTableView.reloadSections(IndexSet(integer: indexpath.section), with: .automatic)

        }else if indexpath.section == 1{
           self.performSegue(withIdentifier: "settingtocatagorylist", sender: self)
        }else{
            self.GooglePlacePicker()
        }
    }
}

extension SettingsPageVC: GMSPlacePickerViewControllerDelegate {
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        guard String(place.coordinate.latitude) != "0.0" else {
            print("Gurad case as no location has been selected")
            return
        }
        
        self.locationcordinate = place.coordinate
        
        print("****** Location Details from Preference Settings ******")
        print("Place name \(place.name)")
        print("coordinate.latitude \(String(place.coordinate.latitude))")
        print("coordinate.longitude \(String(place.coordinate.longitude))")
        
        locationLatitude = String(place.coordinate.latitude)
        locationLongitude = String(place.coordinate.longitude)
        
        trainingLocationModelObj.locationName = place.name
        trainingLocationModelObj.locationLatitude = locationLatitude
        trainingLocationModelObj.locationLongitude = locationLongitude
        
        choosedTrainingLocationPreference = place.name
        self.settingsTableView.reloadSections(IndexSet(integer: 0), with: .automatic)

        userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: CommonMethods.getDictionaryFromTrainingLocationModel(training_location_model: trainingLocationModelObj)), forKey: "TrainingLocationModelBackup")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
}
