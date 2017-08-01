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
    let subCategoryModelObj: SubCategoryModel = SubCategoryModel()
    var selectedSubCategories = [SubCategoryModel]()

    var categoriesArray = [CategoryModel]()
    fileprivate var selectedCategories = [Int]()
    
    fileprivate let reuseIdentifier = "categoryListCellId"
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    fileprivate let itemsPerRow: CGFloat = 2
    
    var isBackButtonHidden = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isBackButtonHidden{
            CommonMethods.hidesBackButton(viewController: self, isHide: true)
        }else{
            CommonMethods.hidesBackButton(viewController: self, isHide: false)
        }

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
                    self.subCategoryModelObj.insertSubCategoriesToDB(subCategories: subcategories)
                    self.categoryCollectionView.reloadData()
                }else if status == RESPONSE_STATUS.FAIL{
                      CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    @IBAction func categoryNextAction(_ sender: Any) {
        
        if selectedCategories.count > 0{
            performSegue(withIdentifier: "CategoryToQuestion1Segue", sender: self)
        }else{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please choose atleast one category", buttonTitle: "OK")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
        print("SELECTED CATEGS:",categoriesArray)
        if segue.identifier == "CategoryToQuestion1Segue"{
            print("Selected Categories are :",selectedCategories)
            loadSelectedCategories()
            print("Selected Categories are 111",selectedCategoriesSingleton)
            var subCategoryIDsArray = [String]()
            
            for values in selectedCategories{
                let subcategory = categoriesArray[values].subCategories
                print("Sub Categories of \(categoriesArray[values].categoryId) are \(subcategory)")

                for i in subcategory{
                    
                    if !subCategoryIDsArray.contains(i.subCategoryId){
                        selectedSubCategories.append(i)
                        subCategoryIDsArray.append(i.subCategoryId)
                    }
                }
            }
            //Storing values to Singleton Object for later use
            selectedSubCategoriesSingleton = selectedSubCategories
        }
    }
    
    func loadSelectedCategories() {
        for value in selectedCategories{
            selectedCategoriesSingleton.append(categoriesArray[value])
        }
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
        cell.categoryImage.sd_setImage(with: URL(string: categoriesArray[indexPath.row].categoryImage), placeholderImage: UIImage(named: ""))
        
        if selectedCategories.contains(indexPath.row){
            cell.cellSelectionView.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        }else{
            cell.cellSelectionView.backgroundColor = UIColor.white
        }
        
        return cell
    }
}

extension CategoryListVC : UICollectionViewDelegateFlowLayout {

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
