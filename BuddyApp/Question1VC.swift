//
//  Question1VC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 21/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class Question1VC: UIViewController {

    @IBOutlet weak var txtZipCode: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func nextButtonAction(_ sender: Any) {
        
        if txtZipCode.text == "" {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_ENTER_ZIPCODE, buttonTitle: "OK")
        }else{
            trainerTestAnswers.zipCode = txtZipCode.text!
            performSegue(withIdentifier: "afterZipCodeVCSegue", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
