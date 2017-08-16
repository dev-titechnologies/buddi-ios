//
//  RegisterViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import Alamofire
import CountryPicker
import SVProgressHUD
import libPhoneNumber_iOS

class RegisterViewController: UIViewController,GIDSignInUIDelegate,CountryPickerDelegate,UITextFieldDelegate {
    @IBOutlet weak var facebook_btn: UIButton!

    @IBOutlet weak var google_btn: UIButton!
    @IBOutlet weak var imgview: UIImageView!
    @IBOutlet weak var female_btn: UIButton!
    @IBOutlet weak var male_btn: UIButton!
    @IBOutlet weak var countrycode_btn: UIButton!
    @IBOutlet weak var contrycode_txt: UITextField!
    @IBOutlet weak var picker: CountryPicker!
    @IBOutlet weak var password_txt: UITextField!
    @IBOutlet weak var mobile_txt: UITextField!
    @IBOutlet weak var email_txt: UITextField!
    @IBOutlet weak var lastname_txt: UITextField!
    @IBOutlet weak var firstname_txt: UITextField!
    
    var fbUserDictionary: NSDictionary!
    var googleUserDictionary: NSDictionary!
    var FullDataDictionary: NSDictionary!
    var HeaderDictionary: NSDictionary!
    var genderString = String()
    var UserType = String()
    var registerType = String()
    var countryAlphaCode = String()
    var profileImageURL = String()
    var mobileNumber = String()
    var jsondict: NSDictionary!
    
    let myView = UIView()
    
    @IBOutlet weak var countryPickerCardView: CardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 188/255, green: 214/255, blue: 255/255, alpha: 1)
        contrycode_txt.isUserInteractionEnabled = false
    
        print("qqqqq",UserType)
        
        self.title = "Register"
        
         if (fbUserDictionary != nil){
            self.registerType = "facebook"

            self.firstname_txt.text = (self.fbUserDictionary["first_name"] as? String)!
            self.lastname_txt.text = (self.fbUserDictionary["last_name"] as? String)!
            
            if (self.fbUserDictionary["email"] as? String) != nil{
                self.email_txt.text = (self.fbUserDictionary["email"] as? String)!
            }
            
            self.profileImageURL = (((self.fbUserDictionary["picture"] as? NSDictionary)?["data"] as? NSDictionary)?["url"] as? String)!
        }else if (googleUserDictionary != nil){
            registerType = "google"
            self.firstname_txt.text = (self.googleUserDictionary["name"] as? String)!
            self.email_txt.text = (self.googleUserDictionary["email"] as? String)!
        }
        
        google_btn.layer.borderColor = UIColor.init(colorLiteralRed: 223/255, green: 74/255, blue: 50/255, alpha: 1.0).cgColor
        google_btn.layer.borderWidth = 2
        google_btn.layer.cornerRadius = 5
        google_btn.clipsToBounds = true
        
        facebook_btn.layer.borderColor = UIColor.init(colorLiteralRed: 59/255, green: 74/255, blue: 153/255, alpha: 1.0).cgColor

        facebook_btn.layer.borderWidth = 2
        facebook_btn.layer.cornerRadius = 5
        facebook_btn.clipsToBounds = true
               
//        removeZerosFromBeginningInMobileNumber(mobile: "000000231234")
        contrycode_txt.delegate = self
        firstname_txt.delegate = self
        lastname_txt.delegate = self
        mobile_txt.delegate = self
        password_txt.delegate = self
        
        male_btn.layer.cornerRadius = 12
        male_btn.layer.borderColor = UIColor.darkGray.cgColor
        male_btn.layer.borderWidth = 2
        male_btn.clipsToBounds = true
        
        female_btn.layer.cornerRadius = 12
        female_btn.layer.borderColor = UIColor.darkGray.cgColor
        female_btn.layer.borderWidth = 2

        female_btn.clipsToBounds = true
  
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().uiDelegate = self
        // GIDSignIn.sharedInstance().delegate = self as! GIDSignInDelegate
        
        let locale = Locale.current
        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String?
        //init Picker
        picker.countryPickerDelegate = self
        picker.showPhoneNumbers = true
        picker.setCountry(code!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Define identifier
        let notificationName = Notification.Name("NotificationIdentifier")
       
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: notificationName, object: nil)
    
    }
    
     func methodOfReceivedNotification(notif: NSNotification) {
        
        let notificationName = Notification.Name("NotificationIdentifier")
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil);

        self.googleUserDictionary = notif.userInfo!["googledata"] as! NSDictionary
        print("GOOGLE DATA ",self.googleUserDictionary)
        
        registerType = "google"
         self.LoginAPI(Email: (self.googleUserDictionary["email"] as? String)!, Passwrd: "", loginType: "google", UserType: self.UserType, FBId: "", GoogleId: (self.googleUserDictionary["userid"] as? String)!)
        
        
//        self.firstname_txt.text = (self.googleUserDictionary["name"] as? String)!
//        self.email_txt.text = (self.googleUserDictionary["email"] as? String)!
    }
    
    @IBAction func male_action(_ sender: Any) {
        
        male_btn.backgroundColor = UIColor.lightGray
        female_btn.backgroundColor = UIColor.clear
        genderString = "male"
    }
    
    @IBAction func female_action(_ sender: Any) {
        
        female_btn.backgroundColor = UIColor.lightGray
        male_btn.backgroundColor = UIColor.clear
        genderString = "female"
    }

    @IBAction func countryCode_action(_ sender: Any) {
        myView.isHidden = false
        countryPickerCardView.isHidden = false
        picker.isHidden = false
    }
    
    public func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        contrycode_txt.text = phoneCode
        imgview.image = flag
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func validation() {
        
        let mobileNumberCopy = contrycode_txt.text! + mobile_txt.text!
        mobileNumber = contrycode_txt.text! + "-" + mobile_txt.text!
        
        if firstname_txt.text!.isEmpty {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please enter your first name", buttonTitle: "Ok")
        }else if lastname_txt.text!.isEmpty {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please enter last name", buttonTitle: "Ok")
        }else if email_txt.text!.isEmpty {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please enter email", buttonTitle: "Ok")
        }else if !self.validate(YourEMailAddress: email_txt.text!) {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please enter a valid email", buttonTitle: "Ok")
        }else if contrycode_txt.text!.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please select country code", buttonTitle: "Ok")
        }else if mobile_txt.text!.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please enter your mobile number", buttonTitle: "Ok")
        }else if genderString.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please select your gender", buttonTitle: "Ok")
        }else if(!mobileNumberValidation(number: mobileNumberCopy)){
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please Enter a valid mobile number", buttonTitle: "Ok")
        }else if password_txt.text!.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please Enter Password", buttonTitle: "Ok")
        }else{
            
            guard CommonMethods.networkcheck() else {
                
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
                return
            }
            
            var FB_id = String()
            var GOOGLE_id = String()
            
            if registerType == REGISTER_TYPE.FACEBOOK{
                 FB_id = CommonMethods.checkStringNull(val: (self.fbUserDictionary["id"] as! String))
                 GOOGLE_id = ""
            }else if registerType == REGISTER_TYPE.GOOGLE{
                 FB_id = ""
                 GOOGLE_id = CommonMethods.checkStringNull(val: (self.googleUserDictionary["userid"] as? String)!)
            }else{
                registerType = REGISTER_TYPE.NORMAL
                FB_id = ""
                GOOGLE_id = ""
            }
            
            OTPCall()
            
            FullDataDictionary = [
                "register_type":registerType,
                "email":self.email_txt.text!,
                "password":self.password_txt.text!,
                "first_name":self.firstname_txt.text!,
                "last_name": self.lastname_txt.text!,
                "mobile": mobileNumber,
                "gender":genderString,
                "user_image": self.profileImageURL,
                "user_type": UserType,
                "facebook_id": FB_id ,
                "google_id": GOOGLE_id ,
                "profile_desc":"dd"
                
            ]
            HeaderDictionary = [
                "device_id": appDelegate.DeviceToken,
                "device_imei": UIDevice.current.identifierForVendor!.uuidString,
                "device_type": "ios",
                
            ]
        }
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }
    
    func OTPCall(){
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: "register/sendOTP", parameters: ["mobile":mobileNumber, "email": self.email_txt.text!], headers: nil, onCompletion: { (jsondata) in
            print("1234",jsondata)
            
            CommonMethods.hideProgress()
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    print("OTP Sent Successfully")
                    self.performSegue(withIdentifier: "otpview", sender: self)
                }else if status == RESPONSE_STATUS.FAIL{
                    print("OTP Call Failed")
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "OK")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    print("OTP Call Session Expired")
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    func removeZerosFromBeginningInMobileNumber(mobile: String) -> String {
        
        var mobileCopy = mobile
        while mobileCopy.characters.first == "0" {
            mobileCopy.remove(at: mobileCopy.startIndex)
        }
        print(mobileCopy)
        return mobileCopy
    }
    
    func mobileNumberValidation(number : String) -> Bool{

        let phoneUtil = NBPhoneNumberUtil()
        do {
            let phoneNumber: NBPhoneNumber = try phoneUtil.parse(number, defaultRegion: countryAlphaCode)
            print("Is Valid Phone Number",phoneUtil.isValidNumber(phoneNumber))
            return phoneUtil.isValidNumber(phoneNumber)
        }catch{
            return false
        }
    }

    func validate(YourEMailAddress: String) -> Bool {
        let REGEX: String
        REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", REGEX).evaluate(with: YourEMailAddress)
    }

    @IBAction func Google_register(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func Facebook_register(_ sender: Any) {
//        CommonMethods.showProgress()
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                
                if (result?.isCancelled)! {
//                    CommonMethods.hideProgress()
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email")){
                    CommonMethods.showProgress()
                    self.getFBUserData()
                }
            }else{
//                CommonMethods.hideProgress()
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: REQUEST_TIMED_OUT, buttonTitle: "OK")
                print("FB ERROR")
            }
        }
    }
    
    @IBAction func pickerCloseAction(_ sender: Any) {
        countryPickerCardView.isHidden = true
    }
    
    @IBAction func next_action(_ sender: Any) {
        validation()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        countryPickerCardView.isHidden = true
        picker.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Google SignIn Delegate
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    // Present a view that prompts the user to sign in with Google
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    // Dismiss the "Sign in with Google" view
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
        
//        
//        self.googleUserDictionary = userDefaults.dictionary(forKey: "googledata")! as NSDictionary
//        self.firstname_txt.text = (self.googleUserDictionary["name"] as? String)!
//        //self.lastname_txt.text = (self.googleUserDictionary["last_name"] as? String)!
//        self.email_txt.text = (self.googleUserDictionary["email"] as? String)!
//
        
        
    }
    //completed sign In
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        
        
        if (error == nil)
        {
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let name = user.profile.name
            let email = user.profile.email
            //let userImageURL = user.profile.imageURLWithDimension(200)
            // ...
            
            
            //print(user)
            print(userId!)
            print(idToken!)
            print(name!)
            print(email!)
        }
        else
        {
            print("\(error.localizedDescription)")
        }
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    
                    print("RESULT",result!)
                    self.registerType = "facebook"
                    
                     self.fbUserDictionary = result as? NSDictionary
                    
                    var emailId = ""
                    if (self.fbUserDictionary["email"] as? String) != nil{
                        emailId = (self.fbUserDictionary["email"] as? String!)!
                        print("*** Email present in FB: \(emailId)")
                    }
                    
                    self.LoginAPI(Email: emailId, Passwrd: "", loginType: "facebook", UserType: self.UserType, FBId: (self.fbUserDictionary["id"] as? String)!, GoogleId: "")
                }else{
                    CommonMethods.hideProgress()
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: error?.localizedDescription, buttonTitle: "OK")
                    print("ERROR123",error?.localizedDescription)
                }
            })
        }
    }
    
    func LoginAPI(Email: String,Passwrd: String, loginType: String, UserType: String,FBId: String,GoogleId:String) {
        
        let parameters = ["login_type":loginType,
                          "email":Email,
                          "password":Passwrd,
                          "user_type": UserType,
                          "facebook_id": FBId,
                          "google_id": GoogleId]
        
        let headers = [
            "device_id": appDelegate.DeviceToken,
            "device_imei": UIDevice.current.identifierForVendor!.uuidString,
            "device_type": "ios",
            ]
        
        print("Params:",parameters)
        print("Header:",headers)
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: "login/login", parameters: parameters, headers: headers , onCompletion: { (jsondata) in
            print("LOGIN RESPONSE",jsondata)
            
            CommonMethods.hideProgress()
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    self.jsondict = jsondata["data"]  as! NSDictionary
                    
                    appDelegate.Usertoken = (self.jsondict["token"] as? String)!
                    appDelegate.UserId = (self.jsondict["user_id"] as? Int)!
                    appDelegate.USER_TYPE =  self.UserType
                    appDelegate.userName = (self.jsondict["first_name"] as? String)! + " " + (self.jsondict["last_name"] as? String)!

                    userDefaults.set((self.jsondict["user_id"] as? Int)!, forKey: "user_id")
                    userDefaults.set(appDelegate.userName, forKey: "userName")
                    userDefaults.set((self.jsondict["token"] as? String)!, forKey: "token")
                    userDefaults.set(self.UserType, forKey: "userType")
                    print(self.jsondict["trainer_type"]!)
                    userDefaults.set(self.jsondict["trainer_type"]!, forKey: "ifAlreadyTrainer")
                    print("If Already a Trainer Value ####:",userDefaults.value(forKey: "ifAlreadyTrainer") as! Bool)
                    
                    if let url = URL(string:(self.jsondict["user_image"] as? String)!){
                        print("Image URL:", url)
                        if let data = NSData.init(contentsOf: url) {
                            ProfileImageDB.save(imageURL: (self.jsondict["user_image"] as? String)!, imageData: data)
                        }
                    }
                    
                    print("User Type Check:\(self.UserType)")
                    if self.UserType == "trainer" {
                        self.segueActionsIfTrainer(dictionary: self.jsondict as! Dictionary<String, Any>!)
                    }else if self.UserType == "trainee" {
                        self.performSegue(withIdentifier: "registerToToTraineeHomeSegue", sender: self)
                    }
                    
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SUCCESSFULLY_LOGGED_IN, buttonTitle: "Ok")
                    
                                 }
                else if status == RESPONSE_STATUS.FAIL{
                    if jsondata["status_type"] as? String == "UserNotRegistered" {
                        
                        if self.registerType == REGISTER_TYPE.FACEBOOK{
                            
                            self.firstname_txt.text = (self.fbUserDictionary["first_name"] as? String)!
                            self.lastname_txt.text = (self.fbUserDictionary["last_name"] as? String)!
                            
                            if (self.fbUserDictionary["email"] as? String) != nil{
                                self.email_txt.text = (self.fbUserDictionary["email"] as? String)!
                            }
                            
                            self.profileImageURL = (((self.fbUserDictionary["picture"] as? NSDictionary)?["data"] as? NSDictionary)?["url"] as? String)!
                            
                            print("PROFILE IMAGE ",self.profileImageURL)
                        }else if self.registerType == REGISTER_TYPE.GOOGLE{
                            self.firstname_txt.text = (self.googleUserDictionary["name"] as? String)!
                            self.email_txt.text = (self.googleUserDictionary["email"] as? String)!
                        }
                    }
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    func segueActionsIfTrainer(dictionary: Dictionary<String, Any>!) {
        print(dictionary)
        
        var approvedCount = Int()
        var pendingCount = Int()
        
        if let category_approvedArray = dictionary["category_approved"] as? NSArray{
            print(category_approvedArray)
            
            approvedCount = category_approvedArray.count
            userDefaults.setValue(approvedCount, forKey: "approvedCategoryCount")
            //            approvedCategoryCountSingleton = approvedCount
            
            if approvedCount > 0 {
                print("*** Approved Categories Present ****")
                //Need to redirect to Trainer Home Screen
                self.performSegue(withIdentifier: "loginToHomeSegueR", sender: self)
            }
        }
        
        if let category_pendingArray = dictionary["category_pending"] as? NSArray{
            print(category_pendingArray)
            
            pendingCount = category_pendingArray.count
            userDefaults.setValue(pendingCount, forKey: "pendingCategoryCount")
            //            pendingCategoryCountSingleton = pendingCount
            
            if pendingCount > 0 && approvedCount == 0 {
                print("*** Pending Categories Present ****")
                //Redirect to Waiting for Approval Page
                self.performSegue(withIdentifier: "toWaitingForApprovalSegueR", sender: self)
            }else if pendingCount == 0 && approvedCount == 0 {
                //Redirect to Choose Category Page
                print("Login to Choose Category Page")
                self.performSegue(withIdentifier: "loginToChooseCategorySegueR", sender: self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "otpview" {
            let controller = segue.destination as! OTPViewController
            controller.MobileNumber = mobileNumber
            controller.DataDictionary = FullDataDictionary
            controller.HeaderDict = HeaderDictionary
        }
        else if segue.identifier == "loginToChooseCategorySegueR" {
            let chooseCategoryPage =  segue.destination as! CategoryListVC
            chooseCategoryPage.isBackButtonHidden = true
        }
    }
}
