//
//  TrainerIncomeCell.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 25/01/18.
//  Copyright © 2018 Ti Technologies. All rights reserved.
//

import UIKit

class TrainerIncomeCell: UITableViewCell {

    @IBOutlet weak var lblSessionName: UILabel!
    @IBOutlet weak var lblTraineeName: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblSessionDuration: UILabel!
    @IBOutlet weak var imgImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
