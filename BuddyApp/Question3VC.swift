//
//  Question3VC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 21/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class Question3VC: UIViewController {

    @IBOutlet weak var txtHowLongTraining: UITextField!
    
    @IBOutlet weak var btnYesEverCompletedCategory: UIButton!
    @IBOutlet weak var btnNoEverCompletedCategory: UIButton!
    
    @IBOutlet weak var btnYesEverCoachedAnybody: UIButton!
    @IBOutlet weak var btnNoEverCoachedAnybody: UIButton!
    
    @IBOutlet weak var btnYesCertifiedTrainer: UIButton!
    @IBOutlet weak var btnNoCertifiedTrainer: UIButton!
    
    var isAnsweredEverCompletedCategory = Bool()
    var isAnsweredEverCoachedAnybody = Bool()
    var isAnsweredCertifiedTrainer = Bool()
   
    var objDropDown:VDropDownViewController!
    var SelectedData = Array<String>()
    
    @IBOutlet weak var pickerCardView: CardView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(trainingExperienceYearsArray)
        print(trainingExperienceMonthsArray)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        btnYesEverCompletedCategory.addShadowView()
        btnNoEverCompletedCategory.addShadowView()
        btnYesEverCoachedAnybody.addShadowView()
        btnNoEverCoachedAnybody.addShadowView()
        btnYesCertifiedTrainer.addShadowView()
        btnNoCertifiedTrainer.addShadowView()
    }

    @IBAction func yesBtnActionEverCompletedCategory(_ sender: Any) {
        colorChangeSelectedAnswerButton(button: true, questionNumber: 1)
        trainerTestAnswers.categoryTrainingCompletion = true
    }
    
    @IBAction func noBtnActionEverCompletedCategory(_ sender: Any) {
        colorChangeSelectedAnswerButton(button: false, questionNumber: 1)
        trainerTestAnswers.categoryTrainingCompletion = false
    }

    @IBAction func yesBtnActionEverCoached(_ sender: Any) {
        colorChangeSelectedAnswerButton(button: true, questionNumber: 2)
        trainerTestAnswers.isAnybodyCoachedCategory = true
    }

    @IBAction func noBtnActionEverCoached(_ sender: Any) {
        colorChangeSelectedAnswerButton(button: false, questionNumber: 2)
        trainerTestAnswers.isAnybodyCoachedCategory = false
    }
    
    @IBAction func yesBtnActionCertifiedTrainer(_ sender: Any) {
        colorChangeSelectedAnswerButton(button: true, questionNumber: 3)
        trainerTestAnswers.isCertifiedTrainer = true
    }
    
    @IBAction func noBtnActionCertifiedTrainer(_ sender: Any) {
        colorChangeSelectedAnswerButton(button: false, questionNumber: 3)
        trainerTestAnswers.isCertifiedTrainer = false
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        
        if txtHowLongTraining.text == "" || !isAnsweredEverCompletedCategory || !isAnsweredEverCoachedAnybody || !isAnsweredCertifiedTrainer{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_ANSWER_ABOVE_QUESTIONS, buttonTitle: "OK")
        }else{
            trainerTestAnswers.trainingExperience = txtHowLongTraining.text!
            performSegue(withIdentifier: "afterQ3VCSegue", sender: self)
        }
    }
    
    func colorChangeSelectedAnswerButton(button: Bool,questionNumber: Int) {
        
        if questionNumber == 1{
            isAnsweredEverCompletedCategory = true
            if button{
                btnYesEverCompletedCategory.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
                btnNoEverCompletedCategory.backgroundColor = UIColor.white
            }else{
                btnYesEverCompletedCategory.backgroundColor = UIColor.white
                btnNoEverCompletedCategory.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            }
        }else if questionNumber == 2{
            isAnsweredEverCoachedAnybody = true
            if button{
                btnYesEverCoachedAnybody.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
                btnNoEverCoachedAnybody.backgroundColor = UIColor.white
            }else{
                btnYesEverCoachedAnybody.backgroundColor = UIColor.white
                btnNoEverCoachedAnybody.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            }
        }else if questionNumber == 3{
            isAnsweredCertifiedTrainer = true
            if button{
                btnYesCertifiedTrainer.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
                btnNoCertifiedTrainer.backgroundColor = UIColor.white
            }else{
                btnYesCertifiedTrainer.backgroundColor = UIColor.white
                btnNoCertifiedTrainer.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            }
        }
    }
    
    @IBAction func pickerCloseAction(_ sender: Any) {
        pickerCardView.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

extension Question3VC: UITextFieldDelegate {
    
    //MARK:- Textfield Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField == txtHowLongTraining{
            pickerCardView.isHidden = false
//            ShowDropDown(isMultipleSelectionAllow: false, vc: self, OnView: textField, ArrData: trainingExperienceOrderedSet, ArrSelectedData: SelectedData)
            return false
        }else{
            return true
        }
    }
}

//extension Question3VC: VDropDown{
//    
//    //MARK:- Delegate method DropDown
//    func VDropDownDidSelect(_ tableView: UITableView, View:UIView, Index: IndexPath, SelectedItem:String, MultipleSelectedItems:Array<String>, isMulple:Bool) {
//        
//        if View is UITextField {
//            
//            print("Indexpath:",Index.row)
////            var strJoinValue = MultipleSelectedItems.joined(separator: ",")
////            SelectedData = MultipleSelectedItems
////            if MultipleSelectedItems.count == 0 {
////                strJoinValue = ""
////            }
//            txtHowLongTraining.text = SelectedItem
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


extension Question3VC: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return trainingExperienceYearsArray.count
        }else {
            return trainingExperienceMonthsArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return String(trainingExperienceYearsArray[row])
        }else {
            return String(trainingExperienceMonthsArray[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let selectedValueFirstRow = pickerView.selectedRow(inComponent: 0)
        let selectedValueSecondRow = pickerView.selectedRow(inComponent: 1)

        print("Year:\(trainingExperienceYearsArray[selectedValueFirstRow]) & Month: \(trainingExperienceMonthsArray[selectedValueSecondRow])")
        txtHowLongTraining.text = String(trainingExperienceYearsArray[selectedValueFirstRow]) + " Years and " + String(trainingExperienceMonthsArray[selectedValueSecondRow]) + " Months"
    }

}
