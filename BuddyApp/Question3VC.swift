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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
