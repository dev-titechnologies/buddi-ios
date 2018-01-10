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
import Stripe


class AddPaymentMethodVC: UIViewController, STPPaymentContextDelegate {
    
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
    
    @IBOutlet weak var cardIconImage: UIImageView!
    
    //MARK: - CHECKOUT CONTROLLER
    let stripePublishableKey = "pk_test_heTToPOR6gOdO1wHxNnawxZq"
    let backendBaseURL: String? = "https://buddiiostest.herokuapp.com/"
    let appleMerchantID: String? = nil
    
    let companyName = "Buddi"
    let paymentCurrency = "usd"
    
    var paymentContext: STPPaymentContext = STPPaymentContext()
    
    var cardEndingWithString = String()
    var cardBrandString = String()
    
    @IBOutlet weak var cardsTableView: UITableView!
    var cardsArray = [CardModel]()
    var defaultCardPOS = Int()
    
    //MARK: - VIEW CYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("**** Add payment Method viewDidLoad")
        
        self.title = PAGE_TITLE.ADD_PAYMENT_METHOD
        
        //Stripe Conf Settings
//        stripeConfigurationSettings()
        
        promoCodeSuccessfullView.isHidden = true
        selectPaymentModeView.isHidden = true
//        getStripeToken()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("**** Add payment Method ViewWillAppear")
        isControlInSamePage = true
        btnAddPayment.addShadowView()
//        selectPaymentModeView.isHidden = true
        checkIfAnyPromoCodeApplied()
        
        listCardsFromStripe()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("**** Add payment Method ViewDidAppear ****")
//        getClientToken()
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
    
//    func stripeConfigurationSettings(){
//        
//
//        print("** stripeConfigurationSettings **")
//        let stripePublishableKey = self.stripePublishableKey
//        let backendBaseURL = self.backendBaseURL
//        MyAPIClient.sharedClient.baseURLString = self.backendBaseURL
//        
//        promoCodeSuccessfullView.isHidden = true
//        
//        assert(stripePublishableKey.hasPrefix("pk_"), "You must set your Stripe publishable key at the top of CheckoutViewController.swift to run this app.")
//        assert(backendBaseURL != nil, "You must set your backend base url at the top of CheckoutViewController.swift to run this app.")
//        
//        let config = STPPaymentConfiguration.shared()
//        config.publishableKey = self.stripePublishableKey
//        config.appleMerchantIdentifier = self.appleMerchantID
//        config.companyName = self.companyName
//        config.additionalPaymentMethods = STPPaymentMethodType()
//        
//        let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
//        let paymentContext = STPPaymentContext(customerContext: customerContext,
//                                               configuration: config,
//                                               theme: .default())
//        paymentContext.paymentAmount = 100
//        paymentContext.paymentCurrency = self.paymentCurrency
//        self.paymentContext = paymentContext
//        
//        self.paymentContext.delegate = self
//        paymentContext.hostViewController = self
//    }
    
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
        

        self.performSegue(withIdentifier: "addPaymentMethodToAddStripeCardSegue", sender: self)
        //This is for Stripe
//        let addCardViewController: STPAddCardViewController = STPAddCardViewController()
//        addCardViewController.delegate = self
//
//        let navigationController = UINavigationController(rootViewController: addCardViewController)
//        present(navigationController, animated: true)

        //This is for Braintree
//        if clientToken == "" {
//            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_WAIT_FETCHING_PAYMENT_METHODS, buttonTitle: "OK")
//        }else{
//            showDropIn(clientTokenOrTokenizationKey: self.clientToken)
//        }
    }
    
    //MARK: - UNWIND SEGUE
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        
        if segue.identifier == "unwindSegueToAddPaymentMethodVC" {
            self.selectPaymentModeView.isHidden = false
            self.lblCardEndingWith.text = "\(cardBrandString) ending with \(cardEndingWithString)"
            
            if self.isFromBookingPage{
                print("*** Returning back to booking Page after adding payment method123")
                self.navigationController?.popViewController(animated: true)
            }
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
        
        let parameters =  ["user_id": appDelegate.UserId,
                           "promocode" : promocode_txt.text!
            ] as [String : Any]
        
        CommonMethods.serverCall(APIURL: APPLY_PROMO_CODE, parameters: parameters) { (jsondata) in
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
                        userDefaults.set(true, forKey: "isPromoCodeApplied")
                    }
                    
                    self.promoCodeSuccessfullView.isHidden = false
                    self.lblPromoCodeSuccessfull.text = "Applied Promocode : \(self.promocode_txt.text!)"
                    self.promocode_txt.text = ""

                    if self.isFromBookingPage{
                        print("*** Returning back to booking Page after adding payment method123")
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PROMO_CODE_APPLIED_SUCCESSFULL, buttonTitle: "Ok")
                    }
                
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
    
    //MARK: - GET STRIPE TOKEN
    
    func getStripeToken(){
        
        
        let creditCard = STPCard() //creating a stripe card object
        creditCard.number = "4111111111111111"
        creditCard.cvc = "475"
        
        let expText = "12/19"
        
        //extracting month and year values from expiry date
        if (!expText.isEmpty){
            let expArr = expText.components(separatedBy: "/")
            if (expArr.count > 1)
            {
                var expMonth: NSNumber = NSNumber()
                var expYear: NSNumber = NSNumber()
                
                if let myInteger = Int(expArr[0]) {
                    expMonth = NSNumber(value:myInteger)
                }
                if let myInteger = Int(expArr[1]) {
                    expYear = NSNumber(value:myInteger)
                }
                
                creditCard.expMonth = expMonth.uintValue
                creditCard.expYear = expYear.uintValue
                
                let cardParams = STPCardParams()
                cardParams.number = "4111111111111111"
                cardParams.expMonth = expMonth.uintValue
                cardParams.expYear = expYear.uintValue
                cardParams.cvc = "475"
                
                if STPCardValidator.validationState(forCard: cardParams) == .valid{
                                        
                    STPAPIClient.shared().createToken(withCard: creditCard) { token, error in
                        if let token = token {
                        
                            print("Stripe Token:\(token)")
                        }
                        else {
                            print("ERROR STRIPE:\(String(describing: error?.localizedDescription))")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: STPPaymentContextDelegate
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        print("*** didCreatePaymentResult ***")
        MyAPIClient.sharedClient.completeCharge(paymentResult,
                                                amount: self.paymentContext.paymentAmount,
                                                shippingAddress: self.paymentContext.shippingAddress,
                                                shippingMethod: self.paymentContext.selectedShippingMethod,
                                                completion: completion)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
        print("*** didFinishWith ***")
        let title: String
        let message: String
        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .success:
            title = "Success"
            message = "You bought a AAAA!"
        case .userCancellation:
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
        print("11")

        if let paymentMethod = paymentContext.selectedPaymentMethod {
            self.selectPaymentModeView.isHidden = false
            self.lblCardEndingWith.text = "Card ending with \(paymentMethod.label!)"
            self.cardIconImage.image = paymentMethod.image
            print("Card Desc:\(paymentMethod.label)")
        }else {
            self.selectPaymentModeView.isHidden = true
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print("12")
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // Need to assign to _ because optional binding loses @discardableResult value
            // https://bugs.swift.org/browse/SR-1681
            _ = self.navigationController?.popViewController(animated: true)
        })
        let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.paymentContext.retryLoading()
        })
        alertController.addAction(cancel)
        alertController.addAction(retry)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        let upsGround = PKShippingMethod()
        upsGround.amount = 0
        upsGround.label = "UPS Ground"
        upsGround.detail = "Arrives in 3-5 days"
        upsGround.identifier = "ups_ground"
        let upsWorldwide = PKShippingMethod()
        upsWorldwide.amount = 10.99
        upsWorldwide.label = "UPS Worldwide Express"
        upsWorldwide.detail = "Arrives in 1-3 days"
        upsWorldwide.identifier = "ups_worldwide"
        let fedEx = PKShippingMethod()
        fedEx.amount = 5.99
        fedEx.label = "FedEx"
        fedEx.detail = "Arrives tomorrow"
        fedEx.identifier = "fedex"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if address.country == nil || address.country == "US" {
                completion(.valid, nil, [upsGround, fedEx], fedEx)
            }
            else if address.country == "AQ" {
                let error = NSError(domain: "ShippingError", code: 123, userInfo: [NSLocalizedDescriptionKey: "Invalid Shipping Address",
                                                                                   NSLocalizedFailureReasonErrorKey: "We can't ship to this country."])
                completion(.invalid, error, nil, nil)
            }
            else {
                fedEx.amount = 20.99
                completion(.valid, nil, [upsWorldwide, fedEx], fedEx)
            }
        }
    }
    
}


extension AddPaymentMethodVC: STPAddCardViewControllerDelegate{
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        dismiss(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        print("token received:\(token)")
        userDefaults.set(true, forKey: "isStripeTokenExists")
        addCardtoStripe(stripeToken: String(describing: token))
        dismiss(animated: true)
    }

}


//MARK: - STRIPE SERVER CALLS

extension AddPaymentMethodVC {
    
    func addCardtoStripe(stripeToken: String) {
        
        let parameters =  ["card_token": stripeToken] as [String : Any]
        
        CommonMethods.showProgress()
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
                    self.selectPaymentModeView.isHidden = false
                    self.lblCardEndingWith.text = "\(responseData?["brand"] as! String) ending with \(responseData?["last4"] as! String)"
//                    self.cardIconImage.image = paymentMethod.image
                    
                    if self.isFromBookingPage{
                        print("*** Returning back to booking Page after adding payment method123")
                        self.navigationController?.popViewController(animated: true)
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
    
    func removeCardFromStripe(stripeToken: String) {
        
        let parameters =  ["card_token": stripeToken,
            ] as [String : Any]
        
        CommonMethods.serverCall(APIURL: REMOVE_CARD_FROM_STRIPE, parameters: parameters) { (jsondata) in
            print("removeCardFromStripe Response: \(jsondata)")
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    //isAppliedPromoCode
                }
                else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        }
    }
    
    func listCardsFromStripe() {
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: LIST_STRIPE_CARDS, parameters: ["":""]) { (jsondata) in
            print("listCardsFromStripe Response: \(jsondata)")
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.hideProgress()
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{

                    if let cardsArray = jsondata["data"] as? NSArray {
                        if cardsArray.count > 0 {
                            self.selectPaymentModeView.isHidden = false
                            let responseData = cardsArray[0] as? NSDictionary
                            self.lblCardEndingWith.text = "\(responseData?["brand"] as! String) ending with \(responseData?["last4"] as! String)"
                            CommonMethods.hideProgress()
                            userDefaults.set(true, forKey: "isStripeTokenExists")
                            
                            self.cardsArray = self.getCardModel(cardsArray: cardsArray as! Array<Any>)
                            self.cardsTableView.reloadData()
                            
                            if self.isFromBookingPage{
                                print("*** Returning back to booking Page after adding payment method123")
                                self.navigationController?.popViewController(animated: true)
                            }
                        }else{
                            CommonMethods.hideProgress()
                        }
                    }else{
                        CommonMethods.hideProgress()
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
    
    func getCardModel(cardsArray: Array<Any>) -> [CardModel]{
        
        var cardModelArray = [CardModel]()
        
        for card in cardsArray.enumerated() {
            let cardModel = CardModel()
            let cardElement = card.element as? NSDictionary
            
            if let card_name = cardElement?["name"] as? String{
                cardModel.cardName = card_name
            }else{
                cardModel.cardName = ""
            }
            cardModel.cardId = cardElement?["id"] as! String
            cardModel.brand = cardElement?["brand"] as! String
            cardModel.expiryMonth = String(describing: cardElement?["exp_month"])
            cardModel.expiryYear = String(describing: cardElement?["exp_year"])
            cardModel.endingWith = cardElement?["last4"] as! String
            cardModel.country = cardElement?["country"] as! String
            cardModel.customer = cardElement?["customer"] as! String
            cardModel.defaultStatus = false
            
            defaultCardPOS = 2
            
            cardModelArray.append(cardModel)
        }
        
        return cardModelArray
    }
}

//MARK: - CARDS TABLEVIEW DELEGATE & DATASOURCE

extension AddPaymentMethodVC: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CardsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cardsCellId") as! CardsTableViewCell
        
        cell.lblCardName.text = cardsArray[indexPath.row].brand + " ending with " + cardsArray[indexPath.row].endingWith
        cell.imgCheckBox.image = (cardsArray[indexPath.row].defaultStatus == false ?  #imageLiteral(resourceName: "unchecked") : #imageLiteral(resourceName: "checked"))

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let card = cardsArray[indexPath.row]
        
        if card.defaultStatus == true{
            cardsArray[indexPath.row].defaultStatus = false
        }else{
            cardsArray[indexPath.row].defaultStatus = true
        }
        let indexPath1 = IndexPath(row: defaultCardPOS, section: 0)
        self.cardsTableView.reloadRows(at: [indexPath1], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            
            cardsArray.remove(at: indexPath.row)
            self.cardsTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}


