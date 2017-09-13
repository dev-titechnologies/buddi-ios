//
//  SectionHeaderCell.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 03/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class SectionHeaderCell: UITableViewCell {

    @IBOutlet weak var lblHeaderSectionTitle: UILabel!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var lblSelectedValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
