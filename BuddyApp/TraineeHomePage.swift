//
//  TraineeHomePage.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 03/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class TraineeHomePage: UIViewController {

    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    let categoryModelObj: CategoryModel = CategoryModel()
    var categoriesArray = [CategoryModel]()
    fileprivate let reuseIdentifier = "categoryListCellId"
    fileprivate var selectedCategory = [Int]()
    fileprivate var deSelectedCategory = [Int]()
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    fileprivate let itemsPerRow: CGFloat = 2

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        getCategoryList()
        selectedCategory.removeAll()
    }
    
    func getCategoryList() {
        
        CommonMethods.serverCall(APIURL: CATEGORY_URL, parameters: [:], headers: nil, onCompletion: { (jsondata) in
            
            print("*** Category Listing Result:",jsondata)
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    let (categories,subcategories) = self.categoryModelObj.getCategoryModelFromJSONDict(dictionary: jsondata)
                    
                    print("*** Categories:",categories)
                    print("*** SubCategories:",subcategories)
                    
                    self.categoriesArray = categories
                    self.categoryModelObj.insertCategoriesToDB(categories: categories)
                    self.categoryCollectionView.reloadData()
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        if selectedCategory.count > 0{
            choosedCategoryOfTrainee = categoriesArray[selectedCategory[0]]
            print("Choosed Category:\(choosedCategoryOfTrainee.categoryName)")
            performSegue(withIdentifier: "afterCategorySelectionTraineeSegue", sender: self)
        }else{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please choose atleast one category", buttonTitle: "OK")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TraineeHomePage : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CategoryListCell
        
        cell.lblCategoryName.text = categoriesArray[indexPath.row].categoryName
        print("CATEG Image URL:",categoriesArray[indexPath.row].categoryImage)
        cell.categoryImage.sd_setImage(with: URL(string: categoriesArray[indexPath.row].categoryImage), placeholderImage: UIImage(named: ""))
        
        print("Selected Category:\(selectedCategory)")
        print("Deselected Category:\(deSelectedCategory)")

        if selectedCategory.count == 0{
            cell.cellSelectionView.backgroundColor = UIColor.white
        }else if selectedCategory[0] == indexPath.row{
            cell.cellSelectionView.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        }
        if deSelectedCategory.contains(indexPath.row) {
            cell.cellSelectionView.backgroundColor = UIColor.white
        }
        
        return cell
    }
}

extension TraineeHomePage : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}


extension TraineeHomePage : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if selectedCategory.count > 0 {
            deSelectedCategory.append(selectedCategory[0])
            selectedCategory.removeAll()
            selectedCategory.append(indexPath.row)
            let indexpath = NSIndexPath(row: deSelectedCategory[0], section: 0)
            categoryCollectionView.reloadItems(at: [indexpath as IndexPath])
            deSelectedCategory.removeAll()
        }else{
            selectedCategory.append(indexPath.row)
        }
        let indexpath = NSIndexPath(row: selectedCategory[0], section: 0)
        categoryCollectionView.reloadItems(at: [indexpath as IndexPath])
    }
}