//
//  CategoryListVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 20/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import SDWebImage

class CategoryListVC: UIViewController {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    let categoryModelObj: CategoryModel = CategoryModel()
    var categoriesArray = [CategoryModel]()
    fileprivate var selectedCategories = [Int]()
    
    fileprivate let reuseIdentifier = "categoryListCellId"
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    fileprivate let itemsPerRow: CGFloat = 2

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    override func viewWillAppear(_ animated: Bool) {

        CommonMethods.serverCall(APIURL: "category/listCategory", parameters: [:], headers: nil, onCompletion: { (jsondata) in
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: "Error", message: "Server not responding", buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == 1{
                    print("okkkk")
                    self.categoriesArray = self.categoryModelObj.getCategoryModelFromJSONDict(dictionary: jsondata)
                    
//                    var tempDict = [String: Any]()
//                    var tempArray = [Dictionary<String, Any>]()
//                    for i in 0 ..< self.categoriesArray.count{
//                        tempDict = ["selected" : "0", "categoryModel" : self.categoriesArray[i]]
//                        tempArray.append(tempDict)
//                    }
                    
                    self.categoryModelObj.insertCategoriesToDB(categories: self.categoriesArray)
                    self.categoryCollectionView.reloadData()
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension CategoryListVC : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CategoryListCell

        cell.lblCategoryName.text = categoriesArray[indexPath.row].categoryName
        print("CATEG Image URL:",categoriesArray[indexPath.row].categoryImage)
        cell.categoryImage.sd_setImage(with: URL(string: categoriesArray[indexPath.row].categoryImage), placeholderImage: UIImage(named: "profileImage"))
        
        if selectedCategories.contains(indexPath.row){
            //Cell Selected
            cell.cellSelectionView.backgroundColor = UIColor.blue
        }else{
            //Cell no Selected
            cell.cellSelectionView.backgroundColor = UIColor.lightGray
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedCategories.contains(indexPath.row){
            print("Cell deselected")
            selectedCategories.remove(at: selectedCategories.index(of: indexPath.row)!)
        }else{
            print("Cell Selected")
            selectedCategories.append(indexPath.row)
        }
        categoryCollectionView.reloadItems(at: [indexPath])
    }
}
