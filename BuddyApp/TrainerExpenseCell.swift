//
//  TrainerExpenseCell.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 25/01/18.
//  Copyright © 2018 Ti Technologies. All rights reserved.
//

import UIKit

class TrainerExpenseCell: UITableViewCell {

    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
