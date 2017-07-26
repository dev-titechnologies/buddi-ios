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
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 188/255, green: 214/255, blue: 255/255, alpha: 1)
        contrycode_txt.isUserInteractionEnabled = false
    print("qqqqq",UserType)
        
        self.title = "Register"
               
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
        
        
//JOSE
    }
    override func viewWillAppear(_ animated: Bool) {
        // Define identifier
        let notificationName = Notification.Name("NotificationIdentifier")
       
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: notificationName, object: nil)
    
    }
     func methodOfReceivedNotification(notif: NSNotification) {
        
        
        
        
        self.googleUserDictionary = notif.userInfo!["googledata"] as! NSDictionary
        print("GOOGLE DATA ",self.googleUserDictionary)
        
        registerType = "google"
        
        self.firstname_txt.text = (self.googleUserDictionary["name"] as? String)!
        self.email_txt.text = (self.googleUserDictionary["email"] as? String)!

        
        
        
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
        
        
        picker.isHidden = false
        
    }
    public func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        contrycode_txt.text = phoneCode
        imgview.image = flag
        
         picker.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func validation() {
        let mobileNumberCopy = contrycode_txt.text! + mobile_txt.text!
        mobileNumber = contrycode_txt.text! + "-" + mobile_txt.text!
        
        if firstname_txt.text!.isEmpty {
            CommonMethods.alertView(view: self, title: "", message: "Please enter your first name", buttonTitle: "Ok")
        }else if lastname_txt.text!.isEmpty {
            CommonMethods.alertView(view: self, title: "", message: "Please enter last name", buttonTitle: "Ok")
        }else if email_txt.text!.isEmpty {
            CommonMethods.alertView(view: self, title: "", message: "Please enter email", buttonTitle: "Ok")
        }else if !self.validate(YourEMailAddress: email_txt.text!) {
            CommonMethods.alertView(view: self, title: "", message: "Please enter a valid email", buttonTitle: "Ok")
        }else if contrycode_txt.text!.isEmpty{
            CommonMethods.alertView(view: self, title: "", message: "Please select country code", buttonTitle: "Ok")
        }else if mobile_txt.text!.isEmpty{
            CommonMethods.alertView(view: self, title: "", message: "Please enter your mobile number", buttonTitle: "Ok")
        }else if genderString.isEmpty{
            CommonMethods.alertView(view: self, title: "", message: "Please select your gender", buttonTitle: "Ok")
        }else if(!mobileNumberValidation(number: mobileNumberCopy)){
            CommonMethods.alertView(view: self, title: "", message: "Please Enter a valid mobile number", buttonTitle: "Ok")
        }else{
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
                "device_id": "y",
                "device_imei": "yu",
                "device_type": "ios",
                
            ]
        }
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }
    
    func OTPCall(){
        CommonMethods.serverCall(APIURL: "register/sendOTP", parameters: ["mobile":mobileNumber], headers: nil, onCompletion: { (jsondata) in
            print("1234",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    print("OTP Sent Successfully")
                    self.performSegue(withIdentifier: "otpview", sender: self)
                }else if status == RESPONSE_STATUS.FAIL{
                    print("OTP Call Failed")
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "OK")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    print("OTP Call Session Expired")

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
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                
                if (result?.isCancelled)! {
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    
                     SVProgressHUD.show()
                    self.getFBUserData()
                }
            }
        }
    }

    @IBAction func next_action(_ sender: Any) {
        validation()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //MARK:Google SignIn Delegate
    
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
                     self.firstname_txt.text = (self.fbUserDictionary["first_name"] as? String)!
                    self.lastname_txt.text = (self.fbUserDictionary["last_name"] as? String)!
                    self.email_txt.text = (self.fbUserDictionary["email"] as? String)!
                    
                    self.profileImageURL = (((self.fbUserDictionary["picture"] as? NSDictionary)?["data"] as? NSDictionary)?["url"] as? String)!
                    
                    print("PROFILE IMAGE ",self.profileImageURL)
                   
                    SVProgressHUD.dismiss()
                }
            })
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "otpview" {
            let controller = segue.destination as! OTPViewController
            controller.MobileNumber = mobileNumber
            controller.DataDictionary = FullDataDictionary
            controller.HeaderDict = HeaderDictionary
        }

        
        
    }
  

}
