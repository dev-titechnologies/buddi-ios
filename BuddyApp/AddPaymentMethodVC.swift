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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        getClientToken()
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

//        Alamofire.request(FinalURL, method: .post, parameters: parameters, encoding: URLEncoding.httpBody).responseJSON { response in
//            
//            if let data = response.data {
//                let json = String(data: data, encoding: String.Encoding.utf8)
//                self.clientToken = json!
//                print(self.clientToken)
//            }
//        }
        
        Alamofire.request(FinalURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            
            print(response)
            if let result = response.value as? Dictionary<String, Any>{
                self.clientToken = result["data"] as! String
                print("Client token:\(self.clientToken)")

            }
        }
    }

    @IBAction func testPayment(_ sender: Any) {
        showDropIn(clientTokenOrTokenizationKey: self.clientToken)
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
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                print(result.paymentMethod?.nonce as Any)
                
                print("Method: \(String(describing: result.paymentMethod))")
                print("paymentOptionType: \(String(describing: result.paymentOptionType))")
                print("paymentOptionType: \(String(describing: result.paymentOptionType))")
                print("paymentDescription: \(String(describing: result.paymentDescription))")
                print("paymentIcon: \(String(describing: result.paymentIcon))")
                
                print(result)
                self.postNonceToServer(paymentMethodNonce: (result.paymentMethod?.nonce)!)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func postNonceToServer(paymentMethodNonce: String) {
        
        //"fake-valid-nonce"
        
        let headers = [
            "token":appDelegate.Usertoken]

        let parameters =  ["amount" : "10.00",
                           "user_id" : appDelegate.UserId
                           ] as [String : Any]
        print("PARAMS: \(parameters)")
        
        let FinalURL = SERVER_URL + PAYMENT_CHECKOUT
        print("Final Server URL:",FinalURL)

//        Alamofire.request(FinalURL, method: .post, parameters: parameters, encoding: URLEncoding.httpBody).responseJSON { response in
        Alamofire.request(FinalURL, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON {
            response in
        print("Checkout page Response:\(response)")
            if let data = response.data {
                let json = String(data: data, encoding: String.Encoding.utf8)
                print("Response: \(String(describing: json!))")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
