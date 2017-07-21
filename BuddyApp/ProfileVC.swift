//
//  ProfileVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = 40
        profileImage.clipsToBounds = true

        

    }

    override func viewWillAppear(_ animated: Bool) {
        ProfileDataAPI()
        parseProfileDetails()
    }
    
    func parseProfileDetails() {
        
        let profile = ProfileModel(profileImage: "Test URL for Image", firstName: "ABC", lastName: "EFG", email: "abc@gmail.com", mobile: "46467467", gender: "male")
        
        
        
        profileImage.image = UIImage.init(named: profile.profileImage)
        firstname_txt.text = profile.firstName
        lastname_txt.text = profile.lastName
        email_txt.text = profile.email
        mobile_txt.text = profile.mobile
        gender_txt.text = profile.gender
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func ProfileDataAPI() {
        
        
        let parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId] as [String : Any]
        
        let headers = [
            "token":appDelegate.Usertoken,            ]

        
        print("PARAMS",parameters)
        
        CommonMethods.serverCall(APIURL: "profile/viewProfile", parameters: parameters , headers: headers , onCompletion: { (jsondata) in
            print("PROFILE RESPONSE",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == 1{
                }
            }
             })

        
    }
}
