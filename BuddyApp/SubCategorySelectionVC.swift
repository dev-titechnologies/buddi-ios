//
//  SubCategorySelectionVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 20/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class SubCategorySelectionVC: UIViewController {

    @IBOutlet weak var btnYesLostOrGainWeight: UIButton!
    @IBOutlet weak var btnNoLostOrGainWeight: UIButton!

    @IBOutlet weak var subCategoryTable: UITableView!
    @IBOutlet weak var txtCurrentWeight: UITextField!
    var subCategories = [SubCategoryModel]()
    
    var selectedSubCategoriesFromTable = [Int]()
    
    var isAnsweredLostOrGainWeight = Bool()
    
    var objDropDown:VDropDownViewController!
    var SelectedData = Array<String>()
    
    @IBOutlet weak var pickerCardView: CardView!
    @IBOutlet weak var pickerView: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        subCategories = selectedSubCategoriesSingleton
        print("SubCategories:",subCategories)
        print(currentWeightONEArray)
        print(currentWeightSecondArray)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        btnYesLostOrGainWeight.addShadowView()
        btnNoLostOrGainWeight.addShadowView()
    }
    
    @IBAction func yesBtnActionLostOrGainWeight(_ sender: Any) {
        colorChangeSelectedAnswerButton(button: true)
        trainerTestAnswers.lostOrGainWeightInSixMonths = true
    }
    
    @IBAction func noBtnActionLostOrGainWeight(_ sender: Any) {
        colorChangeSelectedAnswerButton(button: false)
        trainerTestAnswers.lostOrGainWeightInSixMonths = false
    }
    
    func colorChangeSelectedAnswerButton(button: Bool) {
        
        isAnsweredLostOrGainWeight = true
        if button{
            btnYesLostOrGainWeight.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            btnNoLostOrGainWeight.backgroundColor = UIColor.white
        }else{
            btnYesLostOrGainWeight.backgroundColor = UIColor.white
            btnNoLostOrGainWeight.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        }
    }

    @IBAction func nextButtonAction(_ sender: Any) {
        
        if selectedSubCategoriesFromTable.count == 0 {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please choose atleast a subcategory", buttonTitle: "OK")
        }else if txtCurrentWeight.text == "" || !isAnsweredLostOrGainWeight{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_ANSWER_ABOVE_QUESTIONS, buttonTitle: "OK")
        }else{
            trainerTestAnswers.currentWeight = txtCurrentWeight.text!
            loadSelectedSubCategoriesAmong()
            performSegue(withIdentifier: "afterSubCategorySelectionSegue", sender: self)
        }
    }
    
    func loadSelectedSubCategoriesAmong() {
        selectedSubCategoriesAmongSingleton.removeAll()
        for value in selectedSubCategoriesFromTable{
            selectedSubCategoriesAmongSingleton.append(subCategories[value])
        }
    }
    
    @IBAction func pickerCloseAction(_ sender: Any) {
        pickerCardView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SubCategorySelectionVC: UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: SubCategoryTableCell = tableView.dequeueReusableCell(withIdentifier: "subCategoryCellId") as! SubCategoryTableCell
        
        cell.lblSubCategoryName.text = subCategories[indexPath.row].subCategoryName
        
        if selectedSubCategoriesFromTable.contains(indexPath.row){
            cell.cellSelectionView.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        }else{
            cell.cellSelectionView.backgroundColor = UIColor.white
        }

        return cell
    }
}

extension SubCategorySelectionVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        if selectedSubCategoriesFromTable.contains(indexPath.row){
            print("Cell deselected")
            selectedSubCategoriesFromTable.remove(at: selectedSubCategoriesFromTable.index(of: indexPath.row)!)
        }else{
            print("Cell Selected")
            selectedSubCategoriesFromTable.append(indexPath.row)
        }
        subCategoryTable.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension SubCategorySelectionVC: UITextFieldDelegate {
    
    //MARK:- Textfield Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField == txtCurrentWeight{
            pickerCardView.isHidden = false
//            ShowDropDown(isMultipleSelectionAllow: false, vc: self, OnView: textField, ArrData: weightRangeOrderedSet, ArrSelectedData: SelectedData)
            return false
        }else{
            return true
        }
    }
}

//extension SubCategorySelectionVC: VDropDown{
//    
//    //MARK:- Delegate method DropDown
//    func VDropDownDidSelect(_ tableView: UITableView, View:UIView, Index: IndexPath, SelectedItem:String, MultipleSelectedItems:Array<String>, isMulple:Bool) {
//        
//        if View is UITextField {
//            
////            print("Indexpath:",Index.row)
////            var strJoinValue = MultipleSelectedItems.joined(separator: ",")
////            SelectedData = MultipleSelectedItems
////            if MultipleSelectedItems.count == 0 {
////                strJoinValue = ""
////            }
//            txtCurrentWeight.text = SelectedItem
//        }
//    }
//    
//    func VDropDownHide() {
//        print("Hide DropDown")
//    }
//    
//    // MARK:- show dropdown on View
//    func ShowDropDown(isMultipleSelectionAllow:Bool, vc:UIViewController, OnView:UIView, ArrData:NSMutableOrderedSet, ArrSelectedData:Array<String>) -> Void {
//        
//        objDropDown = VDropDownViewController.init(nibName: "DropDownListView", bundle: nil)
//        objDropDown.view.frame = CGRect.init(x: 0, y: 20, width: self.view.frame.size.width, height: self.view.frame.size.height)
//        objDropDown.isMultipleSelectionAllow = isMultipleSelectionAllow
//        objDropDown.mAryPassedData = ArrData
//        objDropDown.delegate = vc as? VDropDown
//        objDropDown.selectedData = ArrSelectedData
//        objDropDown.ShowDropDown(self, OnView:OnView);
//    }
//}

extension SubCategorySelectionVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return currentWeightONEArray.count
        }else {
            return currentWeightSecondArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return String(currentWeightONEArray[row])
        }else {
            return String(currentWeightSecondArray[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let selectedValueFirstRow = pickerView.selectedRow(inComponent: 0)
        let selectedValueSecondRow = pickerView.selectedRow(inComponent: 1)
        
        txtCurrentWeight.text = String(currentWeightONEArray[selectedValueFirstRow] + currentWeightSecondArray[selectedValueSecondRow]) + " lbs"
    }
    
}

