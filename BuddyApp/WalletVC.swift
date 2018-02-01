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
    @IBOutlet weak var txtAddMoney: UITextField!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var btnAllTransactions: UIButton!
    
    @IBOutlet weak var btnWithdraw: MMSlidingButton!
    
    @IBOutlet weak var topupView: UIView!
    @IBOutlet weak var withdrawView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = PAGE_TITLE.WALLET
        self.btnWithdraw.delegate = self

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
        
        if txtAddMoney.text == "" {
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
        
        let parameters =  ["amount": txtAddMoney.text!,
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
                        self.txtAddMoney.text = ""
                    }

                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
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
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        }
    }
}
