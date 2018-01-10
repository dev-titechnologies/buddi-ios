//
//  CardsTableViewCell.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 10/01/18.
//  Copyright © 2018 Ti Technologies. All rights reserved.
//

import UIKit

class CardsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCardName: UILabel!
    @IBOutlet weak var imgCheckBox: UIImageView!
    @IBOutlet weak var imgCardIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
