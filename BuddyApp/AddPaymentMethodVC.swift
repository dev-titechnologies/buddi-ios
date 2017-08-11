//
//  AddPaymentMethodVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 07/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import Alamofire
import BraintreeDropIn
import Braintree

class AddPaymentMethodVC: UIViewController {
    
    var clientToken = String()
    var isAppliedPromoCode = Bool()
    
    @IBOutlet weak var lblCardEndingWith: UILabel!
    @IBOutlet weak var imgCardIcon: UIImageView!
    @IBOutlet weak var selectPaymentModeView: UIView!
    
    @IBOutlet weak var testView: BTUIKPaymentOptionCardView!
    @IBOutlet weak var btnAddPayment: UIButton!
    
    var isFromBookingPage = Bool()
    var isControlInSamePage = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        isControlInSamePage = true
        if isFromBookingPage{
            print("**** From Booking Page ****")
        }
        
        CommonMethods.showProgress()
        btnAddPayment.addShadowView()
        selectPaymentModeView.isHidden = true
        getClientToken()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        isControlInSamePage = false
    }
    
    @IBAction func applyPromoCodeAction(_ sender: Any) {
        applyPromoCode()
    }
    
    func getClientToken() {
        
        let headers = ["token" : appDelegate.Usertoken] as HTTPHeaders?
        let parameters =  ["user_id": appDelegate.UserId]
        
        print("PARAMS: \(parameters)")

        let FinalURL = SERVER_URL + CREATE_CLIENT_TOKEN
        print("Final Server URL:",FinalURL)

        CommonMethods.showProgress()
        Alamofire.request(FinalURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            
            print(response)
            if let result = response.value as? Dictionary<String, Any>{
                self.clientToken = result["data"] as! String
                print("Client token:\(self.clientToken)")
                userDefaults.set(self.clientToken, forKey: "clientTokenForPayment")
                
                //Fetch Existing payment methods if any
                if self.isControlInSamePage {
                    self.fetchExistingPaymentMethod(clientToken: self.clientToken)
                }
            }
        }
    }

    @IBAction func addPaymentAction(_ sender: Any) {
        showDropIn(clientTokenOrTokenizationKey: self.clientToken)
    }
    
    func fetchExistingPaymentMethod(clientToken: String) {
        
        CommonMethods.showProgress()
        print("***** Fetch Existing payment method *****")
        BTDropInResult.fetch(forAuthorization: clientToken, handler: { (result, error) in
            if (error != nil) {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PAYMENT_METHOD_FETCH_ERROR, buttonTitle: "OK")
                print("ERROR")
            } else if let result = result {
                
                self.selectPaymentModeView.isHidden = false
                let selectedPaymentOptionType = result.paymentOptionType
                let selectedPaymentMethod = result.paymentMethod
                let selectedPaymentMethodIcon = result.paymentIcon
                let selectedPaymentMethodDescription = result.paymentDescription
                
                print("Method: \(String(describing: selectedPaymentMethod))")
                print("paymentOptionType: \(selectedPaymentOptionType.rawValue)")
                print("paymentDescription: \(selectedPaymentMethodDescription)")
                print("paymentIcon: \(selectedPaymentMethodIcon)")
                
                self.lblCardEndingWith.text = (selectedPaymentMethod?.type)! + " " + selectedPaymentMethodDescription
                
                let paymentMethodType = BTUIKViewUtil.paymentOptionType(forPaymentInfoType: result.paymentMethod?.type)
                
                CommonMethods.hideProgress()

                self.testView.paymentOptionType = paymentMethodType
                let nounce = result.paymentMethod?.nonce
                print("New Received nonce:\(String(describing: nounce))")
                userDefaults.set(nounce, forKey: "paymentNonce")
            }
        })
    }

    func showDropIn(clientTokenOrTokenizationKey: String) {
        
        print("***** showDropIn *****")
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                
                let selectedPaymentOptionType = result.paymentOptionType
                let selectedPaymentMethod = result.paymentMethod
                let selectedPaymentMethodIcon = result.paymentIcon
                let selectedPaymentMethodDescription = result.paymentDescription
                
                print("Method: \(String(describing: selectedPaymentMethod))")
                print("paymentOptionType: \(selectedPaymentOptionType.rawValue)")
                print("paymentDescription: \(selectedPaymentMethodDescription)")
                print("paymentIcon: \(selectedPaymentMethodIcon)")

                self.lblCardEndingWith.text = (selectedPaymentMethod?.type)! + " " + selectedPaymentMethodDescription
                
                let paymentMethodType = BTUIKViewUtil.paymentOptionType(forPaymentInfoType: result.paymentMethod?.type)
                self.testView.paymentOptionType = paymentMethodType
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func applyPromoCode(){
        let headers = [
            "token":appDelegate.Usertoken]
        
        let parameters =  ["user_id": appDelegate.UserId,
                           "promocode" : ""
            ] as [String : Any]
        
        CommonMethods.serverCall(APIURL: APPLY_PROMO_CODE, parameters: parameters, headers: headers) { (jsondata) in
            print("Promo Code Response: \(jsondata)")
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    //isAppliedPromoCode
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
