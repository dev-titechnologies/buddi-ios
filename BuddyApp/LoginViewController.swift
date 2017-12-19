//
//  LoginViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController,GIDSignInUIDelegate{
    
    var fbUserDictionary: NSDictionary!
    var loginType = String()
    var UserType = String()
    var googleUserDictionary: NSDictionary!
    var jsondict: NSDictionary!

    @IBOutlet weak var google_btn: UIButton!
    @IBOutlet weak var password_txt: UITextField!
    @IBOutlet weak var email_txt: UITextField!
    @IBOutlet weak var FB_btn: UIButton!
    var profileImageURL = String()

    override func viewDidLoad() {
        super.viewDidLoad()

//        GIDSignIn.sharedInstance().uiDelegate = self as! GIDSignInUIDelegate
        
        self.title = PAGE_TITLE.LOGIN
        
        google_btn.layer.borderColor = UIColor.init(colorLiteralRed: 223/255, green: 74/255, blue: 50/255, alpha: 1.0).cgColor
        google_btn.layer.borderWidth = 2
        google_btn.clipsToBounds = true
        
        FB_btn.layer.borderColor = UIColor.init(colorLiteralRed: 59/255, green: 74/255, blue: 153/255, alpha: 1.0).cgColor
        
        FB_btn.layer.borderWidth = 2
        FB_btn.clipsToBounds = true
        
        print("User Type in LoginViewController",UserType)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("*** viewWillAppear ***")
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().uiDelegate = self
        // Define identifier
        
        let notificationName = Notification.Name("NotificationIdentifier")
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: notificationName, object: nil)
    }
    
    func methodOfReceivedNotification(notif: NSNotification) {
        
        let notificationName = Notification.Name("NotificationIdentifier")
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil);
        
        self.googleUserDictionary = notif.userInfo!["googledata"] as! NSDictionary
        print("GOOGLE DATA in LoginVC",self.googleUserDictionary)
        self.LoginAPI(Email: (self.googleUserDictionary["email"] as? String)!, Passwrd: "", loginType: "google", UserType: self.UserType, FBId: "", GoogleId: (self.googleUserDictionary["userid"] as? String)!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func forgotpq_action(_ sender: Any) {
        
//        guard CommonMethods.networkcheck() else {
//            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please check your internet connectivity", buttonTitle: "Ok")
//            return
//        }
//        
//        self.LoginAPI(Email: self.email_txt.text!, Passwrd: self.password_txt.text!, loginType: "normal", UserType: UserType, FBId: "", GoogleId: "")
    }
    
    @IBAction func NormalLogin(_ sender: Any) {
        validation()
    }
    
    @IBAction func GoogleLogin_action(_ sender: Any) {
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
         GIDSignIn.sharedInstance().signIn()
    }
    
    func validation() {
        
        if email_txt.text!.isEmpty {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please enter email", buttonTitle: "Ok")
        }else if !self.validate(YourEMailAddress: email_txt.text!) {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please enter a valid email", buttonTitle: "Ok")
        }else if password_txt.text!.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please enter password", buttonTitle: "Ok")
        }else{
            guard CommonMethods.networkcheck() else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
                return
            }
            self.LoginAPI(Email: self.email_txt.text!, Passwrd: self.password_txt.text!, loginType: "normal", UserType: UserType, FBId: "", GoogleId: "")
        }
    }

    func validate(YourEMailAddress: String) -> Bool {
        let REGEX: String
        REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", REGEX).evaluate(with: YourEMailAddress)
    }
    
    //MARK: - Google SignIn Delegate
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
       
    @IBAction func FaceBookLogin_Action(_ sender: Any) {
      
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
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
                    
                    var emailId = ""
                    if (self.fbUserDictionary["email"] as? String) != nil{
                        emailId = (self.fbUserDictionary["email"] as? String!)!
                        print("*** Email present in FB: \(emailId)")
                    }
                    
                    let facebookId = (self.fbUserDictionary["id"] as? String)!
                    let facebookName = (self.fbUserDictionary["name"] as? String)!
                    
                    print("Facebook ID:\(facebookId)")
                    print("Facebook Name:\(facebookName)")

                    userDefaults.set(facebookId, forKey: "facebookId")
                    userDefaults.set(facebookName, forKey: "facebookUserName")
                    userDefaults.set(true, forKey: "isFacebookAutoShare")

                    self.LoginAPI(Email: emailId, Passwrd: "", loginType: "facebook", UserType: self.UserType, FBId: facebookId, GoogleId: "")
                }else{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: error?.localizedDescription, buttonTitle: "OK")
                    print("ERROR123",error?.localizedDescription as Any)
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
        CommonMethods.serverCallCopy(APIURL: "login/login", parameters: parameters, headers: headers , onCompletion: { (jsondata) in
            print("LOGIN RESPONSE in LoginVC",jsondata)
            
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
                    userDefaults.set((self.jsondict["email"] as? String)!, forKey: "userEmailId")
                    userDefaults.set((self.jsondict["token"] as? String)!, forKey: "token")
                    userDefaults.set(self.UserType, forKey: "userType")
                    userDefaults.set(self.jsondict["trainer_type"]!, forKey: "ifAlreadyTrainer")
                    userDefaults.set(self.jsondict["mobile"]!, forKey: "userMobileNumber")
                    
                    //Image Check
//                    if ([GIDSignIn sharedInstance].currentUser.profile.hasImage)
                    
                    if let transaction_details = self.jsondict["transaction_details"] as? NSArray{
                        CommonMethods.storeUnusedTransactionsToUserDefaults(transactionDetailsArray: transaction_details)
                    }
                    
                    print(self.jsondict["trainer_type"]!)
                    print("If Already a Trainer Value ####:",userDefaults.value(forKey: "ifAlreadyTrainer") as! Bool)
                    
                    DispatchQueue.global(qos: .background).async {
                        print("This is run on the background queue: *** Profile Image Save to DB ***")
                        if let url = URL(string:(CommonMethods.checkStringNull(val: self.jsondict["user_image"] as? String))){
                            print("Image URL:", url)
                            if let data = NSData.init(contentsOf: url){
                                appDelegate.profileImageData = data
                                ProfileImageDB.save(imageURL: (self.jsondict["user_image"] as? String)!, imageData: data)
                            }
                        }
                    }
                    
                    if self.UserType == "trainer" {
                        self.segueActionsIfTrainer(dictionary: self.jsondict as! Dictionary<String, Any>!)
                    }else if self.UserType == "trainee" {
                        self.performSegue(withIdentifier: "loginToHomeSegue", sender: self)
                    }
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    
                    if jsondata["status_type"] as? String == "UserNotRegistered" {
                        self.performSegue(withIdentifier: "logintoregister", sender: self)
                    }else if jsondata["status_type"] as? String == "UserNotValid" {
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "OK")
                    }else{
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "OK")
                    }
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }else{
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: REQUEST_TIMED_OUT, buttonTitle: "OK")
            }
        })
    }
        
    func segueActionsIfTrainer(dictionary: Dictionary<String, Any>!) {
        print(dictionary)
        
        var approvedCount = Int()
        var pendingCount = Int()
        
        approvedOrPendingCategoriesSingleton.removeAll()
        
        if let category_approvedArray = dictionary["category_approved"] as? NSArray{
            print(category_approvedArray)
            
            for i in 0..<category_approvedArray.count{
                approvedOrPendingCategoriesSingleton.append(category_approvedArray[i] as! String)
            }
            
            approvedCount = category_approvedArray.count
            userDefaults.setValue(approvedCount, forKey: "approvedCategoryCount")
                        
            userDefaults.set(approvedOrPendingCategoriesSingleton, forKey: "approvedCategoriesIdArrayNew")
            
            if approvedCount > 0 {
                print("*** Approved Categories Present ****")
                //Need to redirect to Home Screen
                self.performSegue(withIdentifier: "loginToTrainerHomePage", sender: self)
            }
        }
        
        if let category_pendingArray = dictionary["category_pending"] as? NSArray{
            print(category_pendingArray)
            
            for i in 0..<category_pendingArray.count{
                approvedOrPendingCategoriesSingleton.append(category_pendingArray[i] as! String)
            }
            
            pendingCount = category_pendingArray.count
            userDefaults.setValue(pendingCount, forKey: "pendingCategoryCount")
            
            if pendingCount > 0 && approvedCount == 0 {
                print("*** Pending Categories Present ****")
                //Redirect to Waiting for Approval Page
                self.performSegue(withIdentifier: "toWaitingForApprovalSegue", sender: self)
            }else if pendingCount == 0 && approvedCount == 0 {
                //Redirect to Choose Category Page
                print("Login to Choose Category Page")
                self.performSegue(withIdentifier: "loginToChooseCategorySegue", sender: self)
            }
        }
        
        print("Approved and Pending Categories Id:\(approvedOrPendingCategoriesSingleton)")
        userDefaults.set(approvedOrPendingCategoriesSingleton, forKey: "approvedOrPendingCategoriesIdArray")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "loginToChooseCategorySegue" {
            let chooseCategoryPage =  segue.destination as! CategoryListVC
            chooseCategoryPage.isBackButtonHidden = true
        }else if segue.identifier == "logintoregister"{
            
            let registerPage =  segue.destination as! RegisterViewController
            registerPage.UserType = self.UserType
            registerPage.fbUserDictionary = self.fbUserDictionary
            registerPage.googleUserDictionary = self.googleUserDictionary
        }
    }
}
