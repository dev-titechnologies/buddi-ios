//
//  SelectCountryCell.swift
//  BuddyApp
//
//  Created by Ti Technologies on 19/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class SelectCountryCell: UITableViewCell {

    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var lblCountryName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
