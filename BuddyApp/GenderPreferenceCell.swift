//
//  GenderPreferenceCell.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 24/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class GenderPreferenceCell: UITableViewCell {

    @IBOutlet weak var btnNopreferance: UIButton!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        btnMale.backgroundColor = .white
//        btnFemale.backgroundColor = .white
//        btnNopreferance.backgroundColor = .white
    }
    
    @IBAction func NoPreferaceAction(_ sender: Any) {
        
//        print("NoPreferaceAction")
//        btnNopreferance.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
//        btnFemale.backgroundColor = .white
//        btnMale.backgroundColor = .white
//        choosedTrainerGenderOfTraineePreference = "No Preference"
    }
    
    @IBAction func btnMaleAction(_ sender: Any) {
        
//        print("btnMaleAction")
//
//        btnMale.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
//        btnNopreferance.backgroundColor = .white
//        btnFemale.backgroundColor = .white
//        choosedTrainerGenderOfTraineePreference = "Male"
    }
    
    @IBAction func btnFemaleAction(_ sender: Any) {
       
//        print("btnFemaleAction")
//
//        btnMale.backgroundColor = .white
//        btnNopreferance.backgroundColor = .white
//        choosedTrainerGenderOfTraineePreference = "Female"
//        btnFemale.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
