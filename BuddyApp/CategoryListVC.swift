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

    var FromTrainerProfileBool = Bool()
    var ShowCategoryListModelArray = [CategoryModel]()
    var PendingcategoryModelArray = [CategoryModel]()
        
    var categoriesArray = [CategoryModel]()
    var pendingcategoriesArray = [CategoryModel]()
    var approvedAndPendingFilteredArray = [CategoryModel]()

    
    fileprivate var selectedCategories = [Int]()
    
    fileprivate let reuseIdentifier = "categoryListCellId"
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    fileprivate let itemsPerRow: CGFloat = 2
    var approvedCategoriesIdArray = [String]()
    var pendingCategoriesIdArray = [String]()

    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    var isBackButtonHidden = Bool()
    @IBOutlet weak var btnMenu: UIButton!
    
    var isFromAssignedTrainerVC = Bool()
    var isFromAddCategoryVC = Bool()

//    var assignedTrainerprofileDictionary: NSDictionary!
    var approvedCategories = [CategoryModel]()
    var restCategories = [CategoryModel]()

    var trainerID = String()
    
    //MARK: - VIEW CYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.approvedCategoriesIdArray = userDefaults.stringArray(forKey: "approvedOrPendingCategoriesIdArray") ?? [String]()
//        print("ApprovedCategories ID retrieved from userdefaults:\(self.approvedCategoriesIdArray)")

        btnNext.isHidden = true

        if FromTrainerProfileBool || isFromAssignedTrainerVC {
            btnMenu.isHidden = false
            self.title = PAGE_TITLE.CATEGORY_LIST
        }else{
            self.title = PAGE_TITLE.CHOOSE_CATEGORY
//            (self.approvedCategoriesIdArray.count > 0 ? (btnMenu.isHidden = false) : (btnMenu.isHidden = true))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("** isBackButtonHidden:\(isBackButtonHidden)")
        print("** Trainer ID:\(trainerID)")

//        print("Trainer Profile Details:\(self.assignedTrainerprofileDictionary)")
        
        getUpdatedListOfApprovedAndPendingCategoryLists()

        if isBackButtonHidden{
            CommonMethods.hidesBackButton(viewController: self, isHide: true)
        }else{
            CommonMethods.hidesBackButton(viewController: self, isHide: false)
            btnMenu.isHidden = false
        }
        
        print("*** isFromAssignedTrainerVC:\(isFromAssignedTrainerVC) ***")
        
        if FromTrainerProfileBool || isFromAssignedTrainerVC {
            btnMenu.setImage((UIImage(named: "back_button")), for: .normal)
        }
        
//        listCategoryServerCall()
    }
    
    //MARK: - FUNCTIONS
    
    func getUpdatedListOfApprovedAndPendingCategoryLists() {
        
        let parameters = ["user_id" : appDelegate.UserId,"user_type" : appDelegate.USER_TYPE] as [String : Any]
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: CATEGORY_APPROVED_STATUS, parameters: parameters, onCompletion: { (jsondata) in
            
            print("*** getUpdatedListOfApprovedAndPendingCategoryLists:",jsondata)
            
            CommonMethods.hideProgress()
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    let approvalStatusArray = jsondata["data"] as! NSDictionary as! [String: Any]
                    print("approvalStatusArray:\(approvalStatusArray)")
                    self.loadApproveAndPendingCategoriesToUserDefaults(dictionary: approvalStatusArray)

                }else if status == RESPONSE_STATUS.FAIL{
                    //If no categories are appproved. Eg: Initial case
                    if jsondata["status_type"] as! String == "PendingForApproval"{
                        if self.isBackButtonHidden{
                            print("Changes1234")
                        }else{
                            self.btnMenu.isHidden = false
                        }
                        self.listCategoryServerCall()
                    }else{
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                    }
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    func loadApproveAndPendingCategoriesToUserDefaults(dictionary: Dictionary<String, Any>!) {
       
        print("loadApproveAndPendingCategoriesToUserDefaults:\(dictionary)")
        
        var approvedCount = Int()
//        var pendingCount = Int()
        
        approvedOrPendingCategoriesSingleton.removeAll()
        
        if let category_approvedArray = dictionary["category_approved"] as? NSArray{
            print(category_approvedArray)
            
            for i in 0..<category_approvedArray.count{
                approvedOrPendingCategoriesSingleton.append(category_approvedArray[i] as! String)
            }
            
            approvedCount = category_approvedArray.count
            userDefaults.setValue(approvedCount, forKey: "approvedCategoryCount")
            
            userDefaults.set(approvedOrPendingCategoriesSingleton, forKey: "approvedCategoriesIdArrayNew")
        }
        
        if let category_pendingArray = dictionary["category_pending"] as? NSArray{
            print(category_pendingArray)
            
            for i in 0..<category_pendingArray.count{
                pendingCategoriesIdArray.append(category_pendingArray[i] as! String)
            }
            
//            pendingCount = category_pendingArray.count
//            userDefaults.setValue(pendingCount, forKey: "pendingCategoryCount")
        }
        
        print("Approved and Pending Categories Id:\(approvedOrPendingCategoriesSingleton)")
        userDefaults.set(approvedOrPendingCategoriesSingleton, forKey: "approvedOrPendingCategoriesIdArray")
        
        self.approvedCategoriesIdArray = userDefaults.stringArray(forKey: "approvedOrPendingCategoriesIdArray") ?? [String]()
        print("ApprovedCategories ID retrieved from userdefaults:\(self.approvedCategoriesIdArray)")
        (self.approvedCategoriesIdArray.count > 0 ? (btnMenu.isHidden = false) : (btnMenu.isHidden = true))
        
        if isBackButtonHidden{
        }else{
            btnMenu.isHidden = false
        }

        
        listCategoryServerCall()
    }
    
    func loadSelectedCategories() {
        selectedCategoriesSingleton.removeAll()
        for value in selectedCategories{
            selectedCategoriesSingleton.append(categoriesArray[value])
        }
    }
    
    //MARK: - MENU BUTTON ACTION
    
    @IBAction func btnMenuAction(_ sender: Any) {
        
        if isFromAssignedTrainerVC || FromTrainerProfileBool {
            navigationController?.popViewController(animated: true)
        }else{
            performSegue(withIdentifier: "categoryListToSideMenuSegue", sender: self)
        }
    }
    
    //MARK: - SERVER CALLS
    
    func CategoryApproveServerCall(){
        
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
        var parameters = [String: Any]()
        
        if isFromAssignedTrainerVC {
            parameters = ["user_id" : trainerID,
                          "user_type" : "trainer"
                ] as [String : Any]
        }else{
            parameters = ["user_id" : appDelegate.UserId,
                          "user_type" : appDelegate.USER_TYPE
                ] as [String : Any]
        }
        
        print("Parameters:\(parameters)")
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: CATEGORY_APPROVED_STATUS, parameters: parameters, onCompletion: { (jsondata) in
            
            print("*** Category Approval Result:",jsondata)
            CommonMethods.hideProgress()
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    let datadict = jsondata["data"] as! NSDictionary as! [String: Any]
                    print(datadict)
                    
                    let categoriesAproved = datadict["category_approved"] as! NSArray
                    let categoriesPending = datadict["category_pending"] as! NSArray

                    for i in 0..<self.ShowCategoryListModelArray.count{
                        for j in 0..<categoriesAproved.count{
                    
                            if self.ShowCategoryListModelArray[i].categoryId == String(describing: categoriesAproved[j]){
                                self.ShowCategoryListModelArray[i].categoryStatus = "approved"
                                self.PendingcategoryModelArray.append(self.ShowCategoryListModelArray[i])
                                
                                //for Listing categories of trainer when coming from assigned trainer profile view
                                self.approvedCategories.append(self.ShowCategoryListModelArray[i])
                            }
                        }
                    }
                    
                    for i in 0..<self.ShowCategoryListModelArray.count{
                        for j in 0..<categoriesPending.count{
                            if self.ShowCategoryListModelArray[i].categoryId == String(describing: categoriesPending[j]){
                                self.ShowCategoryListModelArray[i].categoryStatus = "pending"
                                self.PendingcategoryModelArray.append(self.ShowCategoryListModelArray[i])
                            }
                        }
                    }

                    self.reloadCollectionView()
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }else{
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: REQUEST_TIMED_OUT, buttonTitle: "Ok")
            }
        })
    }
    
    func listCategoryServerCall() {
        
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }

        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: CATEGORY_URL, parameters: [:], onCompletion: { (jsondata) in
            
//            print("*** Category Listing Result:",jsondata)
            
            CommonMethods.hideProgress()
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    let (categories,subcategories) = self.categoryModelObj.getCategoryModelFromJSONDict(dictionary: jsondata)
                    
                    self.ShowCategoryListModelArray = categories
                    
//                    print("*** Categories:",categories)
//                    print("*** SubCategories:",subcategories)

                    //Remove approved categories from listing
                    self.categoriesArray.removeAll()
                    
                    //For filtering approved categories from All Category List
                    self.filterApprovedCategoriesFromAllCategories(categoryModelArray: categories)
                    
                    self.approvedAndPendingFilteredArray.removeAll()
                    print("self.categoriesArray:\(self.categoriesArray)")
                    print("pendingCategoriesIdArray.count:\(self.pendingCategoriesIdArray.count)")

                    //For filtering pending categories from All Category List
                    self.filterPendingCategoriesFromAllCategories()
                    
                    print("FromTrainerProfileBool:\(self.FromTrainerProfileBool)")
                    print("isFromAssignedTrainerVC:\(self.isFromAssignedTrainerVC)")

                    if !self.FromTrainerProfileBool && !self.isFromAssignedTrainerVC {
                        //Change latest on Jan 10
                        self.categoriesArray.removeAll()
                        self.categoriesArray = self.approvedAndPendingFilteredArray
                    }
                    
                    print("******* Filtered list of categories *******")
                    print("REMAINING COUNT",self.categoriesArray.count)
                    print("approvedAndPendingFilteredArray:\(self.approvedAndPendingFilteredArray)")
                   
                    self.categoryModelObj.insertCategoriesToDB(categories: categories)
                    self.subCategoryModelObj.insertSubCategoriesToDB(subCategories: subcategories)
                    
                    if self.FromTrainerProfileBool || self.isFromAssignedTrainerVC {
                        self.CategoryApproveServerCall()
                    }else{
                         self.reloadCollectionView()
                    }
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }else{
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: REQUEST_TIMED_OUT, buttonTitle: "Ok")
            }
        })
    }
    
    //MARK: - FILTER CATEGORIES - APPROVED AND PENDING 
    
    func filterApprovedCategoriesFromAllCategories(categoryModelArray: [CategoryModel]) {
        
        var isCategoryAlreadyApproved = false
        for i in 0..<categoryModelArray.count{
            for j in 0..<self.approvedCategoriesIdArray.count{
                if categoryModelArray[i].categoryId == self.approvedCategoriesIdArray[j]{
                    isCategoryAlreadyApproved = true
                    break
                }
            }
            if !isCategoryAlreadyApproved{
                self.categoriesArray.append(categoryModelArray[i])
            }
            isCategoryAlreadyApproved = false
        }
    }
    
    func filterPendingCategoriesFromAllCategories() {
        
        var isCategoryAlreadyPending = false
        for i in 0..<self.categoriesArray.count{
            for j in 0..<self.pendingCategoriesIdArray.count{
                
                if self.categoriesArray[i].categoryId == self.pendingCategoriesIdArray[j]{
                    isCategoryAlreadyPending = true
                    break
                }
            }
            if !isCategoryAlreadyPending{
                self.approvedAndPendingFilteredArray.append(self.categoriesArray[i])
            }
            isCategoryAlreadyPending = false
        }
    }
    
    //MARK: - RELOAD COLLECTION VIEW
    
    func reloadCollectionView() {
        
        CommonMethods.hideProgress()
        if self.categoriesArray.count > 0 {
            
            if self.FromTrainerProfileBool || self.isFromAssignedTrainerVC {
                self.collectionViewBottomConstraint.constant = 0
                self.categoryCollectionView.reloadData()
                btnNext.isHidden = true
            }else{
                self.collectionViewBottomConstraint.constant = 64
                self.categoryCollectionView.reloadData()
                btnNext.isHidden = false
            }
        }else{
            self.categoryCollectionView.isHidden = true
            btnNext.isHidden = true
        }
    }
    
    //MARK: - NEXT ACTION
    
    @IBAction func categoryNextAction(_ sender: Any) {
        
        if selectedCategories.count > 0{
            
            if approvedCategoriesIdArray.count > 0 {
                performSegue(withIdentifier: "categoryToSubCategorySelectionSegue", sender: self)
            }else{
                performSegue(withIdentifier: "CategoryToQuestion1Segue", sender: self)
            }
        }else{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHOOSE_ATLEAST_ONE_CATEGORY, buttonTitle: "OK")
        }
    }

    //MARK: - PREPARE FOR SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
        print("SELECTED CATEGS:",categoriesArray)
        if segue.identifier == "CategoryToQuestion1Segue" || segue.identifier == "categoryToSubCategorySelectionSegue" {
            print("Selected Categories are :",selectedCategories)
            loadSelectedCategories()
            print("Selected Categories are 111",selectedCategoriesSingleton)
            var subCategoryIDsArray = [String]()
            selectedSubCategories = [SubCategoryModel]()

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: -  COLLECTION VIEW DATASOURCE

extension CategoryListVC : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if FromTrainerProfileBool {
            return self.PendingcategoryModelArray.count
        }else if isFromAssignedTrainerVC {
            return self.approvedCategories.count
        }else if isFromAddCategoryVC {
            return self.approvedAndPendingFilteredArray.count
        }else{
            return categoriesArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CategoryListCell

        if FromTrainerProfileBool {
            
            //For Displaying Approved and Pending Categories list
            self.btnNext.isHidden = true
            
            if PendingcategoryModelArray[indexPath.row].categoryStatus == "approved" {
                
                cell.lblCategoryName.text = PendingcategoryModelArray[indexPath.row].categoryName
                print("CATEG Image URL:",PendingcategoryModelArray[indexPath.row].categoryImage)
                cell.categoryImage.sd_setImage(with: URL(string: PendingcategoryModelArray[indexPath.row].categoryImage), placeholderImage: UIImage(named: ""))
                //cell.cellSelectionView.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
//                cell.pendingstatus_lbl.isHidden = true
                cell.imgPendingStatus.image = #imageLiteral(resourceName: "approved")
            }else{
                
                cell.lblCategoryName.numberOfLines = 0;
                cell.lblCategoryName.text = "\(PendingcategoryModelArray[indexPath.row].categoryName)"
                print("CATEG Image URL:",PendingcategoryModelArray[indexPath.row].categoryImage)
                cell.categoryImage.sd_setImage(with: URL(string: PendingcategoryModelArray[indexPath.row].categoryImage), placeholderImage: UIImage(named: ""))
                cell.imgPendingStatus.image = #imageLiteral(resourceName: "pending")
            }
        }else if isFromAssignedTrainerVC {
            
            cell.lblCategoryName.text = approvedCategories[indexPath.row].categoryName
            print("CATEG Image URL:",approvedCategories[indexPath.row].categoryImage)
            cell.categoryImage.sd_setImage(with: URL(string: approvedCategories[indexPath.row].categoryImage), placeholderImage: UIImage(named: ""))
            //cell.cellSelectionView.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            //                cell.pendingstatus_lbl.isHidden = true
            cell.imgPendingStatus.image = #imageLiteral(resourceName: "approved")
        }else if isFromAddCategoryVC {
            
            cell.lblCategoryName.text = approvedAndPendingFilteredArray[indexPath.row].categoryName
            print("CATEG Image URL:",approvedAndPendingFilteredArray[indexPath.row].categoryImage)
            cell.categoryImage.sd_setImage(with: URL(string: approvedAndPendingFilteredArray[indexPath.row].categoryImage), placeholderImage: UIImage(named: ""))
            cell.imgPendingStatus.isHidden = true
            if selectedCategories.contains(indexPath.row){
                cell.cellSelectionView.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            }else{
                cell.cellSelectionView.backgroundColor = UIColor.white
            }
        }else{
            
            //For Adding Category for a Trainer
            cell.lblCategoryName.text = categoriesArray[indexPath.row].categoryName
            print("CATEG Image URL:",categoriesArray[indexPath.row].categoryImage)
            cell.categoryImage.sd_setImage(with: URL(string: categoriesArray[indexPath.row].categoryImage), placeholderImage: UIImage(named: ""))
//             cell.pendingstatus_lbl.isHidden = true
            cell.imgPendingStatus.isHidden = true
            
            if selectedCategories.contains(indexPath.row){
                cell.cellSelectionView.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            }else{
                cell.cellSelectionView.backgroundColor = UIColor.white
            }
        }
        return cell
    }
}

//MARK: - COLLECTION VIEW LAYOUT FUNCTIONS

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

//MARK: - COLLECTION VIEW DELEGATE FUNCTIONS

extension CategoryListVC : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if FromTrainerProfileBool{
            
        }else{
            print("selectedCategories:\(selectedCategories)")
            if selectedCategories.contains(indexPath.row){
                print("Cell deselected")
                selectedCategories.remove(at: selectedCategories.index(of: indexPath.row)!)
            }else{
                print("Cell Selected")
                selectedCategories.append(indexPath.row)
            }
            print("selectedCategories:\(selectedCategories)")
            categoryCollectionView.reloadItems(at: [indexPath])
            
            if selectedCategories.count > 0 {
                btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            }else{
                btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: DARK_GRAY_COLOR)
            }
        }
    }
}
