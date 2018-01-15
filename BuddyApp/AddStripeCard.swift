//
//  AddStripeCard.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 26/10/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import Stripe
import DatePickerDialog


class AddStripeCard: UIViewController, STPPaymentCardTextFieldDelegate {

    //Update Stripe account instances
    
    
    @IBOutlet weak var paymentCardView: STPPaymentCardTextField!
    @IBOutlet weak var updateStripeAccountView: UIView!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtAddressLine1: UITextField!
    @IBOutlet weak var txtAddressLine2: UITextField!
    @IBOutlet weak var txtPostalCode: UITextField!
    @IBOutlet weak var btnDOB: UIButton!
    @IBOutlet weak var txtState: UITextField!
    var dobString = String()
    
    var cardEndingWith = String()
    var cardBrand = String()
    @IBOutlet weak var txtLast4SSN: UITextField!
    var stripeToken = String()
    
    @IBOutlet weak var updateStripeAccountViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: - VIEW CYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()

        paymentCardView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if appDelegate.USER_TYPE == "trainer" {
            updateStripeAccountView.isHidden = false
            updateStripeAccountViewHeightConstraint.constant = 190.0
        }else{
            updateStripeAccountView.isHidden = true
            updateStripeAccountViewHeightConstraint.constant = 0.0
        }
    }
    
    //MARK: - UPDATE STRIPE ACCOUNT
    
    @IBAction func saveStripeAccountAction(_ sender: Any) {
        
        if appDelegate.USER_TYPE == "trainer" {
            validationForTrainers()
        }else if appDelegate.USER_TYPE == "trainee" {
            getStripeToken()
        }
    }
    
    func validationForTrainers() {
        
        if btnDOB.titleLabel?.text == "Date of birth"{
            showAlertView(alertMessage: PLEASE_ENTER_DOB)
        }else if (txtLast4SSN.text?.isEmpty)! || (txtLast4SSN.text)?.characters.count != 4{
            showAlertView(alertMessage: PLEASE_ENTER_SSN_NUMBER)
        }else if (txtCity.text?.isEmpty)! {
            showAlertView(alertMessage: PLEASE_ENTER_CITY)
        }else if (txtAddressLine1.text?.isEmpty)! {
            showAlertView(alertMessage: PLEASE_ENTER_ADDRESS_LINE1)
        }else if (txtAddressLine2.text?.isEmpty)! {
            showAlertView(alertMessage: PLEASE_ENTER_ADDRESS_LINE2)
        }else if (txtPostalCode.text?.isEmpty)! {
            showAlertView(alertMessage: PLEASE_ENTER_POSTAL_CODE)
        }else if (txtState.text?.isEmpty)! {
            showAlertView(alertMessage: PLEASE_ENTER_STATE)
        }else{
            getStripeToken()
        }
    }
    
    func getStripeToken() {
        
        CommonMethods.showProgress()
        let cardParams = paymentCardView.cardParams
        STPAPIClient.shared().createToken(withCard: cardParams) { token, error in
            
            guard token != nil else {
                NSLog("Error creating token: %@", error!.localizedDescription);
                CommonMethods.hideProgress()
                return
            }
            
            self.stripeToken = String(describing: token!)
            
//            userDefaults.set(true, forKey: "isStripeTokenExists")
            self.addCardtoStripe(stripeToken: self.stripeToken)
        }
    }
    
    func showAlertView(alertMessage: String) {
        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: alertMessage, buttonTitle: "Ok")
    }
    
    @IBAction func dobAction(_ sender: Any) {
        
        DatePickerDialog().show(title: "Date of birth", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                
                self.dobString = formatter.string(from: dt)
                self.btnDOB.setTitle(self.dobString, for: .normal)
            }
        }
    }
    
    func addCardtoStripe(stripeToken: String) {
        
        let parameters =  ["card_token": stripeToken] as [String : Any]
        
        print("PARAMS:\(parameters)")
        
        CommonMethods.serverCall(APIURL: ADD_CARD_TO_STRIPE, parameters: parameters) { (jsondata) in
            print("AddCardtoStripe Response: \(jsondata)")
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.hideProgress()
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    let responseData = jsondata["data"] as? NSDictionary
                    CommonMethods.hideProgress()
                    
                    self.cardEndingWith = responseData?["last4"] as! String
                    self.cardBrand = responseData?["brand"] as! String
                    
                    if appDelegate.USER_TYPE == "trainer" {
                        self.updateStripeAccount()
                    }else if appDelegate.USER_TYPE == "trainee" {
                        self.performSegue(withIdentifier: "unwindSegueToAddPaymentMethodVC", sender: self)
                    }
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.hideProgress()
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    CommonMethods.hideProgress()
                    self.dismissOnSessionExpire()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindSegueToAddPaymentMethodVC" {
            let addPaymentMethod =  segue.destination as! AddPaymentMethodVC

            addPaymentMethod.cardEndingWithString = self.cardEndingWith
            addPaymentMethod.cardBrandString = self.cardBrand
        }
    }
    
    func updateStripeAccount() {
        
        let parameters =  ["day": (dobString.components(separatedBy: "/"))[1],
                           "month" : (dobString.components(separatedBy: "/"))[0],
                           "year" : (dobString.components(separatedBy: "/"))[2],
                           "last_4_snn" : txtLast4SSN.text!,
                           "city" : txtCity.text!,
                           "line1" : txtAddressLine1.text!,
                           "line2" : txtAddressLine2.text!,
                           "postal" : txtPostalCode.text!,
                           "state" : txtState.text!,
                           ] as [String : Any]
        
        print("PARAMS:\(parameters)")
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: UPDATE_STRIPE_ACCOUNT, parameters: parameters) { (jsondata) in
            print("updateStripeAccount Response: \(jsondata)")
            
            CommonMethods.hideProgress()
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    self.performSegue(withIdentifier: "unwindSegueToAddPaymentMethodVC", sender: self)
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        }
    }

}
