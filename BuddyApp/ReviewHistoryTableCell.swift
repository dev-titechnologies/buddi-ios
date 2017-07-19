//
//  ReviewHistoryTableCell.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class ReviewHistoryTableCell: UITableViewCell {

    @IBOutlet weak var lblReviewDesc: UILabel!
    @IBOutlet weak var lblReviewDate: UILabel!
    @IBOutlet weak var lblTraineeName: UILabel!
    @IBOutlet weak var lblStarRatingValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
