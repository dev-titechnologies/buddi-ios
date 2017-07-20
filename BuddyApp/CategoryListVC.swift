//
//  CategoryListVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 20/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class CategoryListVC: UIViewController {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let nib = UINib(nibName: "CategoryListCell", bundle: nil)
//        categoryCollectionView?.register(nib, forCellWithReuseIdentifier: "categoryListCellId")

        self.categoryCollectionView.register(CategoryListCell.self, forCellWithReuseIdentifier: "categoryListCellId")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension CategoryListVC : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("Collection cell")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryListCellId", for: indexPath) as! CategoryListCell
//        cell.backgroundColor = UIColor.red
//        cell.lblCategoryName.text = "Squaut"
//        cell.categoryImage.image = UIImage.init(named: "profileImage")
        
        return cell

    }
}

extension CategoryListVC : UICollectionViewDelegate{
    
}
