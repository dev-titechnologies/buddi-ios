//
//  Question2VC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 21/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class Question2VC: UIViewController {

    @IBOutlet weak var txtCurrentGymSubscriptions: UITextField!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    var isAnsweredMilitaryInstallations = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        btnYes.addShadowView()
        btnNo.addShadowView()
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
}