//
//  ChooseGenderTableCell.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 03/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class ChooseGenderTableCell: UITableViewCell {

    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnMale.backgroundColor = .white
        btnFemale.backgroundColor = .white
    }

    @IBAction func btnMaleAction(_ sender: Any) {
        
        btnMale.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        btnFemale.backgroundColor = .white
        choosedTrainerGenderOfTrainee = "male"
    }
    
    @IBAction func btnFemaleAction(_ sender: Any) {
        btnMale.backgroundColor = .white
        btnFemale.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        choosedTrainerGenderOfTrainee = "female"

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
