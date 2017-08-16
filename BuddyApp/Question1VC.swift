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
    @IBOutlet weak var btnNext: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtZipCode.delegate = self
    }

    @IBAction func nextButtonAction(_ sender: Any) {
        
        let zipCodeText: String = txtZipCode.text!
        
        if txtZipCode.text == "" {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_ENTER_ZIPCODE, buttonTitle: "OK")
        }else if zipCodeText.characters.count != 5 {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_ENTER_VALID_ZIPCODE, buttonTitle: "OK")
        }else{
            trainerTestAnswers.zipCode = txtZipCode.text!
            performSegue(withIdentifier: "afterZipCodeVCSegue", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension Question1VC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtZipCode {
            if textField.text?.characters.count == 4 {
                btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            }else{
                btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: DARK_GRAY_COLOR)
            }
        }
        return true
    }
}
