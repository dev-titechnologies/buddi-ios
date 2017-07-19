//
//  ProfileVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblProfileName: UILabel!
    @IBOutlet weak var lblEmailID: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    
    let profileDetails : ProfileModel = ProfileModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        
        parseProfileDetails()
    }
    
    func parseProfileDetails() {
        
        let profile = ProfileModel(profileImage: "Test URL for Image", name: "ABC", email: "abc@gmail.com", mobile: "46467467", gender: "male")
        profileImage.image = UIImage.init(named: profile.profileImage)
        lblProfileName.text = profile.name
        lblEmailID.text = profile.email
        lblMobile.text = profile.mobile
        lblGender.text = profile.gender
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
