//
//  ProfileVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProfileVC: UIViewController {

    @IBOutlet weak var edit_btn: UIBarButtonItem!
    @IBOutlet weak var gender_txt: UITextField!
    @IBOutlet weak var flage_img: UIImageView!
    @IBOutlet weak var contycode_lbl: UILabel!
    @IBOutlet weak var mobile_txt: UITextField!
    @IBOutlet weak var email_txt: UITextField!
    @IBOutlet weak var lastname_txt: UITextField!
    @IBOutlet weak var firstname_txt: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var lblEmailID: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    
    let profileDetails : ProfileModel = ProfileModel()
    var ProfileDict: NSDictionary!
    
    var profileArray = Array<ProfileDB>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = 40
        profileImage.clipsToBounds = true
        
      
        
        
        if let result = ProfileDB.fetchUser()      {
            if result.count == 0
            {
               ProfileDataAPI()
                
            
            }
            else
            {
                print("from db")
                FetchFromDb()
            }
            
        }
        else
        {
            print("from api")
            ProfileDataAPI()
        }
        
        

        

    }
    func FetchFromDb() {
        
        if let result = ProfileDB.fetchUser()      {
        
         self.profileArray = result as! Array<ProfileDB>
            
            let obj = self.profileArray[0].value(forKey: "firstname")
            print("DBBB",obj!)
            
    let profile = ProfileModel(profileImage: self.profileArray[0].value(forKey: "profileImageURL") as! String, firstName: self.profileArray[0].value(forKey: "firstname") as! String,
        lastName: self.profileArray[0].value(forKey: "lastname") as! String,
        email: self.profileArray[0].value(forKey: "email") as! String,
        mobile: self.profileArray[0].value(forKey: "mobile") as! String,
        gender: self.profileArray[0].value(forKey: "gender") as! String,
        userid: "")
            
            
            profileImage.image = UIImage.init(named: profile.profileImage)
            firstname_txt.text = profile.firstName
            lastname_txt.text = profile.lastName
            email_txt.text = profile.email
            mobile_txt.text = profile.mobile
            gender_txt.text = profile.gender

            
            
        
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
       // parseProfileDetails()
        
      
        
    }
    @IBAction func editProfile_action(_ sender: Any) {
        
        self.EditProfileAPI()
    }
    
    func EditProfileAPI()
    {
        
        
        
        let parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId,
                           "first_name":self.firstname_txt.text!,
                            "last_name":self.lastname_txt.text!,
                           "gender":self.gender_txt.text!,
                         "user_image":"",
                         "profile_desc":"tt" ] as [String : Any]
        
        let headers = [
            "token":appDelegate.Usertoken ]
        
        
        print("PARAMS",parameters)
        print("HEADER",headers)
        
        CommonMethods.serverCall(APIURL: "profile/editProfile", parameters: parameters , headers: headers , onCompletion: { (jsondata) in
            print("EDIT PROFILE RESPONSE",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == 1{
                    
                    self.ProfileDict = jsondata["data"]  as! NSDictionary
                    
                    self.parseProfileDetails(profiledict: self.ProfileDict as! Dictionary<String, Any>)

                }
            }
        })
        
        
    

    }
    
    
    func parseProfileDetails(profiledict: Dictionary<String, Any>) {
        
        print("FINAL DICT",profiledict)
        
        
        let profile = ProfileModel(profileImage: (profiledict["user_image"] as? String)!, firstName: (profiledict["first_name"] as? String)!, lastName: (profiledict["last_name"] as? String)!, email: (profiledict["email"] as? String)!, mobile: (profiledict["mobile"] as? String)!, gender: (profiledict["gender"] as? String)!, userid: "")
        
        
        
        ProfileDB.createProfileEntry(profileModel: profile)
        
      //  flage_img.image = UIImage.sd_image(with: userDefaults.value(forKey: "flage_img") as! Data)
        
        
        
        profileImage.image = UIImage.init(named: profile.profileImage)
        firstname_txt.text = profile.firstName
        lastname_txt.text = profile.lastName
        email_txt.text = profile.email
        mobile_txt.text = profile.mobile
        gender_txt.text = profile.gender
        
        SVProgressHUD.dismiss()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func ProfileDataAPI() {
        
    SVProgressHUD.show()
        
        
        let parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId] as [String : Any]
        
        let headers = [
            "token":appDelegate.Usertoken ]

        
        print("PARAMS",parameters)
         print("HEADER",headers)
        
        CommonMethods.serverCall(APIURL: "profile/viewProfile", parameters: parameters , headers: headers , onCompletion: { (jsondata) in
            print("PROFILE RESPONSE",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == 1{
                    
                     self.ProfileDict = jsondata["data"]  as! NSDictionary
                    
                    self.parseProfileDetails(profiledict: self.ProfileDict as! Dictionary<String, Any>)
                    
                }
            }
             })

        
    }
}
