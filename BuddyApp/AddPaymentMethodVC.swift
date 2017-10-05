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
    
    @IBOutlet weak var promocode_txt: UITextField!
    @IBOutlet weak var lblCardEndingWith: UILabel!
    @IBOutlet weak var imgCardIcon: UIImageView!
    @IBOutlet weak var selectPaymentModeView: UIView!
    
    @IBOutlet weak var testView: BTUIKPaymentOptionCardView!
    @IBOutlet weak var btnAddPayment: UIButton!
    
    @IBOutlet weak var lblPromoCodeSuccessfull: UILabel!
    @IBOutlet weak var imgPromoCodeSuccessTick: UIImageView!
    @IBOutlet weak var promoCodeSuccessfullView: CardView!

    var isFromBookingPage = Bool()
    var isControlInSamePage = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = PAGE_TITLE.ADD_PAYMENT_METHOD

        promoCodeSuccessfullView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("**** Add payment Method ViewWillAppear")
        isControlInSamePage = true
        btnAddPayment.addShadowView()
        selectPaymentModeView.isHidden = true
        checkIfAnyPromoCodeApplied()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("**** Add payment Method ViewDidAppear ****")
        getClientToken()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        isControlInSamePage = false
    }
    
    func checkIfAnyPromoCodeApplied() {
        
        if userDefaults.value(forKey: "promocode") != nil{
            promoCodeSuccessfullView.isHidden = false
            lblPromoCodeSuccessfull.text = "Applied Promocode : \(userDefaults.value(forKey: "promocode") as! String)"
        }
    }
    
    @IBAction func applyPromoCodeAction(_ sender: Any) {
        
        if promocode_txt.text!.isEmpty {
             CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Enter a promo code", buttonTitle: "OK")
        }else{
           applyPromoCode()
        }
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
        
        if clientToken == "" {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_WAIT_FETCHING_PAYMENT_METHODS, buttonTitle: "OK")
        }else{
            showDropIn(clientTokenOrTokenizationKey: self.clientToken)
        }
    }
    
    func fetchExistingPaymentMethod(clientToken: String) {
        
        print("***** Fetch Existing payment method *****")
        BTDropInResult.fetch(forAuthorization: clientToken, handler: { (result, error) in
            
            if (error != nil) {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PAYMENT_METHOD_FETCH_ERROR, buttonTitle: "OK")
                print("ERROR")
            } else if let result = result {
                
                let selectedPaymentOptionType = result.paymentOptionType
                let selectedPaymentMethod = result.paymentMethod
                let selectedPaymentMethodIcon = result.paymentIcon
                let selectedPaymentMethodDescription = result.paymentDescription
                
                print("Method: \(String(describing: selectedPaymentMethod))")
                print("paymentOptionType: \(selectedPaymentOptionType.rawValue)")
                print("paymentDescription: \(selectedPaymentMethodDescription)")
                print("paymentIcon: \(selectedPaymentMethodIcon)")
                
                if selectedPaymentMethod == nil{
                    CommonMethods.hideProgress()
                    return
                }
                
                if self.isFromBookingPage{
                    print("*** Returning back to booking Page after adding payment method123")
                    self.navigationController?.popViewController(animated: true)
                }
                
                self.selectPaymentModeView.isHidden = false
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
                
                if self.isFromBookingPage{
                    print("*** Returning back to booking Page after adding payment method")
                    self.navigationController?.popViewController(animated: true)
                }
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func applyPromoCode(){
        let headers = [
            "token":appDelegate.Usertoken]
        
        let parameters =  ["user_id": appDelegate.UserId,
                           "promocode" : promocode_txt.text!
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
                    
                    if let procode = (jsondata["data"]  as! NSDictionary)["code"] as? String{
                        print(procode)
                        userDefaults.set(procode, forKey: "promocode")
                    }
                    self.promoCodeSuccessfullView.isHidden = false
                    self.lblPromoCodeSuccessfull.text = "Applied Promocode : \(self.promocode_txt.text!)"
                    self.promocode_txt.text = ""

                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PROMO_CODE_APPLIED_SUCCESSFULL, buttonTitle: "Ok")
                    
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
