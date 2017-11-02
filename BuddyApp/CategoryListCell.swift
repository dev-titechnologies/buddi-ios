//
//  CategoryListCell.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 20/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class CategoryListCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var cellSelectionView: UIView!
    @IBOutlet weak var imgPendingStatus: UIImageView!
    
    override func awakeFromNib() {
        
        self.layoutIfNeeded()
        
        categoryImage.layer.cornerRadius = categoryImage.frame.height / 2.0
        categoryImage.layer.masksToBounds = true

//        categoryImage.addShadowView()
    }
}
