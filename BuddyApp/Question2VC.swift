//
//  Question2VC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 21/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class Question2VC: UIViewController{

    @IBOutlet weak var txtCurrentGymSubscriptions: UITextField!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    var isAnsweredMilitaryInstallations = Bool()
    
    var gymArray = [GymModel]()
    var gymArraySelected = [GymModel]()
    let gymModelObj : GymModel = GymModel()
    var gymNamesArray = [String]()
    var gymNamesArrayCopy = [Any]()
    var orderedSet = NSMutableOrderedSet()
    @IBOutlet weak var btnNext: UIButton!
    
    //DropDown Variable
    var objDropDown:VDropDownViewController!
    var arr:NSMutableOrderedSet = NSMutableOrderedSet()
    var SelectedData = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtCurrentGymSubscriptions.delegate = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        self.navigationController?.isNavigationBarHidden = true
        getGymDetails()
        btnYes.addShadowView()
        btnNo.addShadowView()
    }
    
    func getGymDetails() {
        
        CommonMethods.serverCall(APIURL: "gym/listGyms", parameters: [:], headers: nil) { (jsondata) in
            print("GYM RESP:",jsondata)
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    let gym_array : Array = jsondata["data"] as! NSArray as Array
                    for gym in gym_array{
                        
                        let modelObject = self.gymModelObj.gymModelFromDict(dictionary: gym as! Dictionary<String, Any>)
                        print(modelObject)
                        self.gymArray.append(modelObject)
                        self.gymNamesArray.append(modelObject.gymName)
                    }
                    self.orderedSet = NSMutableOrderedSet(array: self.gymNamesArray, copyItems: true)
                }else if status == RESPONSE_STATUS.FAIL{
                    print("Gym Details fetch issue")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED {
                    print("Gym Details fetch issue1")
                }
            }
        }
    }
    
    //MARK: - YES/NO BUTTON ACTIONS
    @IBAction func yesButtonAction(_ sender: Any) {
        colorChangeSelectedAnswerButton(button: true)
        trainerTestAnswers.isHavingMilitaryInstallations = true
    }
    
    @IBAction func noButtonAction(_ sender: Any) {
        colorChangeSelectedAnswerButton(button: false)
        trainerTestAnswers.isHavingMilitaryInstallations = false
    }
    
    //MARK: - OTHER FUNCTIONS

    func colorChangeSelectedAnswerButton(button: Bool) {
        
        isAnsweredMilitaryInstallations = true
        if button{
            btnYes.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            btnNo.backgroundColor = UIColor.white
        }else{
            btnYes.backgroundColor = UIColor.white
            btnNo.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        }
        
        if txtCurrentGymSubscriptions.text != "" {
            btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        }else{
            btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: DARK_GRAY_COLOR)
        }
    }
    
    //MARK:- NEXT/BACK BUTTON ACTIONS
    @IBAction func nextButtonAction(_ sender: Any) {
        
        if txtCurrentGymSubscriptions.text == "" || !isAnsweredMilitaryInstallations{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_ANSWER_ABOVE_QUESTIONS, buttonTitle: "OK")
        }else{
            trainerTestAnswers.gymSubscriptions = gymArraySelected
            performSegue(withIdentifier: "afterQ2VCSegue", sender: self)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension Question2VC: UITextFieldDelegate {
    
    //MARK:- Textfield Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField == txtCurrentGymSubscriptions{
            ShowDropDown(isMultipleSelectionAllow: true, vc: self, OnView: textField, ArrData: orderedSet, ArrSelectedData: SelectedData)
            return false
        }else{
            return true
        }
    }
}

extension Question2VC: VDropDown{
    
    //MARK:- Delegate method DropDown
    func VDropDownDidSelect(_ tableView: UITableView, View:UIView, Index: IndexPath, SelectedItem:String, MultipleSelectedItems:Array<String>, isMulple:Bool) {
        
        if View is UITextField {
            
            print("Indexpath:",Index.row)
            var strJoinValue = MultipleSelectedItems.joined(separator: ",")
            SelectedData = MultipleSelectedItems
            if MultipleSelectedItems.count == 0 {
                strJoinValue = ""
            }
            txtCurrentGymSubscriptions.text = strJoinValue
            print("LIST",MultipleSelectedItems)
            gymArraySelected.append(gymArray[Index.row])
            
            if txtCurrentGymSubscriptions.text != "" && isAnsweredMilitaryInstallations {
                btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            }else{
                btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: DARK_GRAY_COLOR)
            }
        }
    }
    
    func VDropDownHide() {
        print("Hide DropDown")
    }
    
    // MARK:- show dropdown on View
    func ShowDropDown(isMultipleSelectionAllow:Bool, vc:UIViewController, OnView:UIView, ArrData:NSMutableOrderedSet, ArrSelectedData:Array<String>) -> Void {
        
        objDropDown = VDropDownViewController.init(nibName: "DropDownListView", bundle: nil)
        objDropDown.view.frame = CGRect.init(x: 0, y: 20, width: self.view.frame.size.width, height: self.view.frame.size.height)
        objDropDown.isMultipleSelectionAllow = isMultipleSelectionAllow
        objDropDown.mAryPassedData = ArrData
        objDropDown.delegate = vc as? VDropDown
        objDropDown.selectedData = ArrSelectedData
        objDropDown.ShowDropDown(self, OnView:OnView);
    }
}
