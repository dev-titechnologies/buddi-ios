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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = PAGE_TITLE.WALLET
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        btnProceed.addShadowView()
        //btnAllTransactions.addShadowView()
        
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
                        self.lblWalletAmount.text = "$ \(String(describing: dataDict["walletBalance"]!))"
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
                        self.lblWalletAmount.text = "$ \(String(describing: dataDict["walletBalance"]!))"
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
