//
//  SessionPreferenceCell.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 24/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class SessionPreferenceCell: UITableViewCell {

    @IBOutlet weak var backgroundCardView: CardView!
    @IBOutlet weak var lblSessionDuration: UILabel!
    @IBOutlet weak var lblSessionAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
