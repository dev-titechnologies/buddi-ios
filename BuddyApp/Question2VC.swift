//
//  Question2VC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 21/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class Question2VC: UIViewController,VDropDown,UITextFieldDelegate{

    @IBOutlet weak var txtCurrentGymSubscriptions: UITextField!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    var isAnsweredMilitaryInstallations = Bool()
    var gymArray = [GymModel]()
    let gymModelObj : GymModel = GymModel()
    var gymNamesArray = [String]()
    var gymNamesArrayCopy = [Any]()
    
    //DropDown Variable
    var objDropDown:VDropDownViewController!
    var arr:NSMutableOrderedSet = NSMutableOrderedSet()
    var SelectedData = Array<String>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtCurrentGymSubscriptions.delegate = self
        
        arr = ["one","two","three","four","five"]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
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
               // let orderedSet = NSMutableOrderedSet(array: self.gymNamesArray, copyItems: true)
                    
                    self.arr = NSMutableOrderedSet(array: self.gymNamesArray, copyItems: true)
                    print("ARRR",self.arr)
                    
                    }else if status == RESPONSE_STATUS.FAIL{
                    
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
//                    self.dis
                }
            }
        }
    }

    @IBAction func backAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func yesButtonAction(_ sender: Any) {
        colorChangeSelectedAnswerButton(button: true)
        trainerTestAnswers.isHavingMilitaryInstallations = true
    }
    
    @IBAction func noButtonAction(_ sender: Any) {
        colorChangeSelectedAnswerButton(button: false)
        trainerTestAnswers.isHavingMilitaryInstallations = false
    }
    
    func colorChangeSelectedAnswerButton(button: Bool) {
        
        isAnsweredMilitaryInstallations = true
        if button{
            btnYes.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            btnNo.backgroundColor = UIColor.white
        }else{
            btnYes.backgroundColor = UIColor.white
            btnNo.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        }
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        
        if txtCurrentGymSubscriptions.text == "" || !isAnsweredMilitaryInstallations{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_ANSWER_ABOVE_QUESTIONS, buttonTitle: "OK")
        }else{
            trainerTestAnswers.gymSubscriptions = txtCurrentGymSubscriptions.text!
            performSegue(withIdentifier: "afterQ2VCSegue", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: textfield Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField == txtCurrentGymSubscriptions{
            ShowDropDown(isMultipleSelectionAllow: true, vc: self, OnView: textField, ArrData: arr, ArrSelectedData: SelectedData)
            return false
            
        }else{
            return true
        }
    }
    
    //MARK: Delegate method DropDown
    func VDropDownDidSelect(_ tableView: UITableView, View:UIView, Index: IndexPath, SelectedItem:String, MultipleSelectedItems:Array<String>, isMulple:Bool) {
        
        if View is UITextField {
           
                var strJoinValue = MultipleSelectedItems.joined(separator: ",")
                SelectedData = MultipleSelectedItems
                if MultipleSelectedItems.count == 0
                {
                    strJoinValue = ""
                }
                txtCurrentGymSubscriptions.text = strJoinValue
            
            print("LIST",MultipleSelectedItems)
            
        }
    }
    
    func VDropDownHide() {
        print("Hide DropDown")
    }
    
    // MARK: show dropdown on View
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
