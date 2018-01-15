//
//  SocialAutoShareCell.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/12/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class SocialAutoShareCell: UITableViewCell {

    @IBOutlet weak var lblSocialTitle: UILabel!
    @IBOutlet weak var btnSwitch: UISwitch!
    @IBOutlet weak var lblUserName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
