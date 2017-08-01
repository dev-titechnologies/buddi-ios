//
//  VTableViewCell.swift
//  VDropDown
//
//  Created by Vishal Kalola on 04/07/17.
//  Copyright © 2017 Vishal Kalola. All rights reserved.
//

import UIKit

class VTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnMultipleSelection: UIButton!
    
    @IBOutlet weak var imgTickMark: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
