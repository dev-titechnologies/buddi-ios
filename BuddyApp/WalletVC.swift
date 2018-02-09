//
//  WalletVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 23/01/18.
//  Copyright © 2018 Ti Technologies. All rights reserved.
//

import UIKit

class WalletVC: UIViewController {

    @IBOutlet weak var lblWalletAmount: UILabel!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var btnAllTransactions: UIButton!
    
    @IBOutlet weak var btnWithdraw: MMSlidingButton!
    
    @IBOutlet weak var topupView: UIView!
    @IBOutlet weak var withdrawView: UIView!
    
    @IBOutlet weak var amountSlider: CustomUISlider!
    @IBOutlet weak var txtAmountPopUp: UITextField!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var amountViewLeadingConstraint: NSLayoutConstraint!
    
    //MARK: - VIEW CYCLES 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = PAGE_TITLE.WALLET
        self.btnWithdraw.delegate = self

        txtAmountPopUp.text = "0"
        if Int(txtAmountPopUp.text!)! == 0 {
            disableProceedButton(isDisabled: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if appDelegate.USER_TYPE == USER_TYPE.TRAINEE{
            topupView.isHidden = false
            withdrawView.isHidden = true
        }else if appDelegate.USER_TYPE == USER_TYPE.TRAINER{
            topupView.isHidden = true
            withdrawView.isHidden = false
        }
        
        btnProceed.addShadowView()
        fetchWalletBalance()
    }
    
    @IBAction func actionProceed(_ sender: Any) {
        
        if txtAmountPopUp.text == "" {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_ENTER_MONEY_TO_ADD, buttonTitle: "OK")
        }else{
            addMoneyToWallet()
        }
    }
    
    @IBAction func actionAllTransactions(_ sender: Any) {
        
    }
        
    func fetchWalletBalance() {
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: WALLET_BALANCE, parameters: [:]) { (jsondata) in
            print("** fetchWalletBalance Response: \(jsondata)")
            
            CommonMethods.hideProgress()
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    if let dataDict = jsondata["data"] as? NSDictionary {
                        self.lblWalletAmount.text = CommonMethods.showWalletAmountInFloat(amount: String(describing: dataDict["walletBalance"]!))
//                        self.lblWalletAmount.text = "$ \(String(describing: dataDict["walletBalance"]!))"
                        userDefaults.set(dataDict["walletBalance"]!, forKey: "walletBalance")
                    }
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        }
    }
    
    func addMoneyToWallet() {
        
        let parameters =  ["amount": txtAmountPopUp.text!,
            ] as [String : Any]
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: ADD_MONEY_TO_WALLET, parameters: parameters) { (jsondata) in
            print("** addMoneyToWallet Response: \(jsondata)")
            
            CommonMethods.hideProgress()
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    if let dataDict = jsondata["data"] as? NSDictionary {
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: MONEY_HAS_BEEN_ADDED_SUCCESSFULLY, buttonTitle: "OK")
                        self.lblWalletAmount.text = CommonMethods.showWalletAmountInFloat(amount: dataDict["walletBalance"]! as! String)
//                        self.lblWalletAmount.text = "$ \(String(describing: dataDict["walletBalance"]!))"
                        userDefaults.set(dataDict["walletBalance"]!, forKey: "walletBalance")
                    }

                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        }
    }
    
    func moveToAddPaymentMethodScreen() {
        //Method 1
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let paymentMethodPage : AddPaymentMethodVC = mainStoryboard.instantiateViewController(withIdentifier: "AddPaymentVCID") as! AddPaymentMethodVC
        paymentMethodPage.isFromWalletPage = true
        self.navigationController?.pushViewController(paymentMethodPage, animated: true)
        //        self.present(paymentMethodPage, animated: true, completion: nil)
    }
    
    //MARK: - SLIDER ACTIONS
    
    var thumbRect: CGRect {
        let rect = amountSlider.trackRect(forBounds: self.amountSlider.bounds)
        return amountSlider.thumbRect(forBounds: self.amountSlider.bounds, trackRect: rect, value: amountSlider.value)
    }
    
    func moveTipViewPosition() {
        
        print("Rect:\(thumbRect)")
        amountViewLeadingConstraint.constant = thumbRect.origin.x
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        
        if Int(sender.value) == 0 {
            disableProceedButton(isDisabled: true)
        }else{
            disableProceedButton(isDisabled: false)
        }
        
        txtAmountPopUp.text = String(describing:Int(sender.value))
        moveTipViewPosition()
    }
}

//MARK: - TEXTFIELD DELEGATE 

extension WalletVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
        print("** textFieldDidBeginEditing **")
        txtAmountPopUp.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print("** textFieldDidEndEditing **")
        
        if textField.text == "" {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_ENTER_MONEY_TO_ADD, buttonTitle: "OK")
            return
        }
        
        if Int(textField.text!)! == 0 {
            disableProceedButton(isDisabled: true)
        }else{
            disableProceedButton(isDisabled: false)
        }
        
        if Int(textField.text!)! <= 1000 {
            amountSlider.setValue(Float(textField.text!)!, animated: true)
            moveTipViewPosition()
        }else{
            amountSlider.setValue(1000.0, animated: true)
            txtAmountPopUp.text = "1000"
            moveTipViewPosition()
        }
    }
    
    func disableProceedButton(isDisabled: Bool){
        
        if isDisabled{
            btnProceed.isUserInteractionEnabled = false
            btnProceed.backgroundColor = .lightGray
        }else{
            btnProceed.isUserInteractionEnabled = true
            btnProceed.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        }
    }
}

//MARK: - WITHDRAW ACTION USING SLIDER

extension WalletVC: SlideButtonDelegate{
    
    func buttonStatus(_ status: String, sender: MMSlidingButton) {
        
        withdrawWalletBalance()
        print("Button Status:\(status)")
    }
    
    func withdrawWalletBalance() {
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: WALLET_MONEY_WITHDRAWAL, parameters: [:]) { (jsondata) in
            print("** withdrawWalletBalance Response: \(jsondata)")
            
            CommonMethods.hideProgress()
            
            self.btnWithdraw.reset()
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    if let statusType = jsondata["status_type"]  as? String{
                        
                        if statusType == "InsufficientBalance" {
                            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: INSUFFICIENT_BALANCE_TO_WITHDRAW, buttonTitle: "OK")
                        }else if statusType == "Success" {
                            
                            
                            if let amountRevised = ((jsondata["data"] as? NSDictionary)? ["stripeResponse"] as? NSDictionary)? ["amount_reversed"] as? Int{
                                
                                print("Amount Revised:\(amountRevised)")
                                
                                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: WITHDRAWAL_HAS_BEEN_SUCCESS, buttonTitle: "OK")

                                self.lblWalletAmount.text = CommonMethods.showWalletAmountInFloat(amount: String(amountRevised))
//                                self.lblWalletAmount.text = "$ \(amountRevised)"
                                userDefaults.set(amountRevised, forKey: "walletBalance")
                            }
                        }
                    }
                }else if status == RESPONSE_STATUS.FAIL{
                    
                    if let statusType = jsondata["status_type"]  as? String{
                        if statusType == "NoActiveCard" {
                            
                            let alert = UIAlertController(title: ALERT_TITLE, message: PLEASE_ADD_PAYMENT_METHOD, preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                                self.moveToAddPaymentMethodScreen()
                            }))
                            alert.addAction(UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: { action in
                                self.btnWithdraw.reset()
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                    }else{
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                    }
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        }
    }
}

class CustomUISlider : UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        
        //keeps original origin and width, changes height, you get the idea
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 10.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
    //while we are here, why not change the image here as well? (bonus material)
    override func awakeFromNib() {
        self.setThumbImage(UIImage(named: "customThumb"), for: .normal)
        super.awakeFromNib()
    }
}
