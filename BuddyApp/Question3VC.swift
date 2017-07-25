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

    @IBAction func yesBtnActionEverCompletedCategory(_ sender: Any) {
        isAnsweredEverCompletedCategory = true
        trainerTestAnswers.categoryTrainingCompletion = true
    }
    
    @IBAction func noBtnActionEverCompletedCategory(_ sender: Any) {
        isAnsweredEverCompletedCategory = true
        trainerTestAnswers.categoryTrainingCompletion = false
    }

    @IBAction func yesBtnActionEverCoached(_ sender: Any) {
        isAnsweredEverCoachedAnybody = true
        trainerTestAnswers.isAnybodyCoachedCategory = true
    }

    @IBAction func noBtnActionEverCoached(_ sender: Any) {
        isAnsweredEverCoachedAnybody = true
        trainerTestAnswers.isAnybodyCoachedCategory = false
    }
    
    @IBAction func yesBtnActionCertifiedTrainer(_ sender: Any) {
        isAnsweredCertifiedTrainer = true
        trainerTestAnswers.isCertifiedTrainer = true
    }
    
    @IBAction func noBtnActionCertifiedTrainer(_ sender: Any) {
        isAnsweredCertifiedTrainer = true
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
