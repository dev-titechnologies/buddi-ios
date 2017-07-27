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
    
    override func awakeFromNib() {
        
        self.layoutIfNeeded()
        categoryImage.layer.cornerRadius = categoryImage.frame.height / 2.0
        categoryImage.layer.masksToBounds = true
        
        
//        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        outerView.clipsToBounds = false
//        outerView.layer.shadowColor = UIColor.black.cgColor
//        outerView.layer.shadowOpacity = 1
//        outerView.layer.shadowOffset = CGSize.zero
//        outerView.layer.shadowRadius = 10
//        outerView.layer.shadowPath = UIBezierPath(roundedRect: outerView.bounds, cornerRadius: 10).cgPath
//
//        categoryImage = UIImageView(frame: outerView.bounds)
//        categoryImage.clipsToBounds = true
//        categoryImage.layer.cornerRadius = 10
//
//        outerView.addSubview(categoryImage)

    }
}
