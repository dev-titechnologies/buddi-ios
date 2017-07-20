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
    let categoryModelObj: CategoryModel = CategoryModel()
    
    fileprivate let reuseIdentifier = "categoryListCellId"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 2

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    override func viewWillAppear(_ animated: Bool) {

        CommonMethods.serverCall(APIURL: "category/listCategory", parameters: [:], headers: nil, onCompletion: { (jsondata) in
            
            print(jsondata)
            
            self.categoryModelObj.getCategoryModelFromJSONDict(dictionary: jsondata)
//            let responseJSON = jsondata.result.value as! [String: AnyObject]
//            if let status = responseJSON["status"] as? Int{
//                if status == 1{
//                    print("okkkk")
//                    categoryModelObj.getCategoryModelFromJSONDict(dictionary: responseJSON)
//                }
//            }
        })
        
        

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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CategoryListCell

        cell.lblCategoryName.text = "Squaut"
        cell.categoryImage.image = UIImage.init(named: "profileImage")
        
        return cell

    }
}

extension CategoryListVC : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}


extension CategoryListVC : UICollectionViewDelegate{
    
}
