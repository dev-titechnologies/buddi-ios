//
//  ShowTrainersOnMapVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 03/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GoogleMaps
import Alamofire
import Braintree
import BraintreeDropIn
import Toaster
//import Toast_Swift

class ShowTrainersOnMapVC: UIViewController {

    @IBOutlet weak var mapview: GMSMapView!
    var locationManager: CLLocationManager!
    var lat = String()
    var long = String()
    var mapView = GMSMapView()
    var jsonarray = NSArray()
    var jsondict = NSDictionary()
    var TrainerProfileDictionary: NSDictionary!
    
    var paymentNonce = String()
    var isNoncePresent = Bool()
    var isClientTokenPresent = Bool()
    
    var parameterdict = NSMutableDictionary()
    var datadict = NSMutableDictionary()
    var parameterdict1 = NSMutableDictionary()
    var datadict1 = NSMutableDictionary()
    var trainersCount = Int()
    
    @IBOutlet weak var btnNext: UIButton!
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 5.0, left: 0, bottom: 0, right: 0)
    fileprivate let itemsPerRow: CGFloat = 4

    let imagearray = ["play","close","message","stop"]
    
    //Payment Transaction Variables
    var transactionId = String()
    var transactionStatus = String()
    var transactionAmount = String()
    var isPaymentSuccess = Bool()
    var isPromoCodeExists = Bool()
    
    var selectedTrainerProfileDetails : TrainerProfileModal = TrainerProfileModal()
    
    @IBOutlet weak var btnRefresh: UIButton!
    var isFromSplashScreen = Bool()
    var isFromInstantBooking = Bool()
    var InstantDict = NSDictionary()
    var previousBookingRequestVia = String()
    
    var trainingLocationModelObject = TrainingLocationModel()
    var preferenceModelObj = PreferenceModel()

    @IBOutlet weak var btnHome: UIButton!
    
    var isPaidAlready40Minutes = Bool()
    var isPaidAlready60Minutes = Bool()

    var clientSign = String()
    var parentSign = String()

    //MARK: - VIEW CYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = PAGE_TITLE.TRAINERS_LISTING
        btnRefresh.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        getPendingTransactionDetails()
        checkForBookingRequestVia()
        
//        fetchTrainingLocationModelDatasFromUserDefault()
        getCurrentLocationDetails()

        if isFromSplashScreen{
            
            //This will not called as a latest change. User will be redirected to the Trainee home page and he can book with previous payment details
            print("**** ShowTrainersOnMap Page from Splash screen")
            self.navigationItem.hidesBackButton = true
            btnRefresh.isHidden = false

            if userDefaults.value(forKey: "isWaitingForTrainerAcceptance") as! Bool{
                print("*** Showing Waiting for acceptance page")
                showWaitingForAcceptancePage()
            }
        }
//        else{
//            if userDefaults.value(forKey: "promocode") != nil{
//            
//            }else{
//                fetchClientTokenFromUserDefault()
//            }
//        }
    }
    
    func checkIsPaymentSuccess(){
        print("***** checkIsPaymentSuccess ******")
        
        if let status = userDefaults.value(forKey: "backupIsTransactionSuccessfull_40Minutes") as? Bool{
            print("Payment Status from backup for backupIsTransactionSuccessfull_40Minutes:\(status)")
            isPaidAlready40Minutes = true
            isPaymentSuccess = true
        }

        if let status = userDefaults.value(forKey: "backupIsTransactionSuccessfull_60Minutes") as? Bool{
            print("Payment Status from backup for backupIsTransactionSuccessfull_60Minutes:\(status)")
            isPaidAlready60Minutes = true
            isPaymentSuccess = true
        }
    }
    
    func checkForBookingRequestVia() {
        
        if userDefaults.value(forKey: "previousBookingRequestVia") as? String != nil{
            
            previousBookingRequestVia = userDefaults.value(forKey: "previousBookingRequestVia") as! String
            print("***** PreviousBookingRequestVia : \(previousBookingRequestVia)")
            //Values would be = instantBooking & usualBooking
            
            if previousBookingRequestVia == "instantBooking"{
                
                print("previousBookingRequestVia value is 'instantBooking'")

                if userDefaults.value(forKey: "save_preferance") as? NSDictionary != nil{
                    let preferenceDict = userDefaults.value(forKey: "save_preferance") as! NSDictionary
                    preferenceModelObj = CommonMethods.getPreferenceObjectFromDictionary(dictionary: preferenceDict)
                    print("Preference Dictionary:\(preferenceDict)")
                }
                
            }else if previousBookingRequestVia == "usualBooking"{
                
                print("previousBookingRequestVia value is 'usualBooking'")
                fetchTrainingLocationModelDatasFromUserDefault()
                preferenceModelObj.locationName = trainingLocationModelObject.locationName
                preferenceModelObj.locationLattitude = trainingLocationModelObject.locationLatitude
                preferenceModelObj.locationLongitude = trainingLocationModelObject.locationLongitude
            }
        }
    }
    
    func fetchTrainingLocationModelDatasFromUserDefault() {
        
        if let unarchivedData = userDefaults.value(forKey: "TrainingLocationModelBackup") as? NSData {
            
            let dict = NSKeyedUnarchiver.unarchiveObject(with: unarchivedData as Data) as! NSMutableDictionary
            trainingLocationModelObject = CommonMethods.getTrainingLocationModelObjectFromDictionary(location_dictionary: dict)
            print("UnArchived Training Location Model:\(trainingLocationModelObject)")
        }
    }
    
    func showWaitingForAcceptancePage() {

        let waitingForAcceptancePage : WaitingForAcceptancePage = storyboardSingleton.instantiateViewController(withIdentifier: "WaitingForAcceptanceVCID") as! WaitingForAcceptancePage
        waitingForAcceptancePage.descriptionText = WAITING_FOR_TRAINER_ACCEPTANCE
        waitingForAcceptancePage.forUserType = "trainee"
        waitingForAcceptancePage.trainersFoundCount = trainersCount
        //self.navigationController?.pushViewController(waitingForAcceptancePage, animated: true)
        self.present(waitingForAcceptancePage, animated: true, completion: nil)
    }
    
    func fetchClientTokenFromUserDefault() {
        
        if let clientToken = userDefaults.value(forKey: "clientTokenForPayment") as? String{
            fetchExistingPaymentMethod(clientToken: clientToken)
            isClientTokenPresent = true
        }
    }
    
    func getCurrentLocationDetails() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestAlwaysAuthorization()
            self.mapview?.isMyLocationEnabled = true
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func Next_action(_ sender: Any) {
                
        if userDefaults.bool(forKey: "isPromoCodeApplied"){
            print("Promo code already applied")
            applyPromoCode()
            return
        }else{
            print("Default Card:\(String(describing: userDefaults.value(forKey: "defaultStripeCardId") as? String))")
            if (userDefaults.value(forKey: "defaultStripeCardId") as? String) == nil{
                alertForAddPaymentMethod()
                return
            }
        }
        
        paymentCheckForNextButtonAction()
    }
    
    func paymentCheckForNextButtonAction() {
        
        if isFromSplashScreen{
            print("***** isFromSplashScreen *******")
            RandomSelectTrainer(parameters: getRandomSelectAPIParametersFromBackup())
        }else if isFromInstantBooking{
            print("***** isFromInstantBooking *******")
            
            if userDefaults.value(forKey: "promocode") != nil{
                RandomSelectTrainer(parameters: self.getRandomSelectAPIParameters())
            }else{
                if isPaymentSuccess{
                    print("isPaymentSuccess : \(isPaymentSuccess)")
                    showAlertRegardingPreviousPayment()
                }else{
                    paymentCheckoutWithWallet()
//                    paymentCheckoutStripe()
                }
            }
        }else{
            print("***** Next Action Else Case *******")
            
            if userDefaults.value(forKey: "promocode") != nil{
                RandomSelectTrainer(parameters: self.getRandomSelectAPIParameters())
            }else{
                if isPaymentSuccess{
                    print("isPaymentSuccess : \(isPaymentSuccess)")
                    showAlertRegardingPreviousPayment()
                }else{
                    paymentCheckoutWithWallet()
//                    paymentCheckoutStripe()
                }
            }
        }
    }
    
    func showAlertRegardingPreviousPayment() {

        //var alertMessage = String()
        
        print("isPaidAlready40Minutes:\(isPaidAlready40Minutes)")
        print("isPaidAlready60Minutes:\(isPaidAlready60Minutes)")
        print("choosedSessionOfTrainee:\(choosedSessionOfTrainee)")
        
//        if isPaidAlready40Minutes && !isPaidAlready60Minutes && choosedSessionOfTrainee == "60"{
//            alertMessage = MINUTES_40_PAID_ALERT
//        }else if isPaidAlready60Minutes && !isPaidAlready40Minutes && choosedSessionOfTrainee == "40" {
//            alertMessage = MINUTES_60_PAID_ALERT
//        }else if isPaidAlready40Minutes && choosedSessionOfTrainee == "40" || isPaidAlready60Minutes && choosedSessionOfTrainee == "60" {
//            print("****** Random selector API call from previous transaction details ********")
//            RandomSelectTrainer(parameters: self.getRandomSelectAPIParameters())
//            return
//        }
        
        if choosedSessionOfTrainee == "60" && isPaidAlready40Minutes || choosedSessionOfTrainee == "40" && isPaidAlready60Minutes{
            
            let alert = UIAlertController(title: ALERT_TITLE, message: REGARDING_PREVIOUS_PAYMENT_ABOUT_SESSION, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
//                self.paymentCheckoutStripe()
                self.navigationController?.popViewController(animated: true)
            }))
//            alert.addAction(UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: { action in
//                
//            }))
            self.present(alert, animated: true, completion: nil)
        }else{
            RandomSelectTrainer(parameters: self.getRandomSelectAPIParameters())
        }
    }
    
    func alertForAddPaymentMethod() {
        
        let alert = UIAlertController(title: ALERT_TITLE, message: PLEASE_ADD_PAYMENT_METHOD, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            self.moveToAddPaymentMethodScreen()
        }))
        alert.addAction(UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func moveToAddPaymentMethodScreen() {
        //Method 1
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let paymentMethodPage : AddPaymentMethodVC = mainStoryboard.instantiateViewController(withIdentifier: "AddPaymentVCID") as! AddPaymentMethodVC
        paymentMethodPage.isFromBookingPage = true
        self.navigationController?.pushViewController(paymentMethodPage, animated: true)
//        self.present(paymentMethodPage, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - PREPARE FOR SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "totrainerprofile"{
            let TrainerProPage =  segue.destination as! AssignedTrainerProfileView
            TrainerProPage.TrainerprofileDictionary = self.TrainerProfileDictionary
        }else if segue.identifier == "trainerTraineeRouteVCSegue" {
            let trainerRoutePage =  segue.destination as! TrainerTraineeRouteViewController
            trainerRoutePage.trainerProfileDetails = selectedTrainerProfileDetails
        }
    }

    //MARK: - SOCKET CONNECTION
    
    func addHandlers() {
        
        datadict.setValue(appDelegate.UserId, forKey: "user_id")
        datadict.setValue("trainee", forKey: "user_type")
        datadict.setValue(lat, forKey: "latitude")
        datadict.setValue(long, forKey: "longitude")
        datadict.setValue("online", forKey: "avail_status")
        
        parameterdict.setValue("/location/addLocation", forKey: "url")
        parameterdict.setValue(datadict, forKey: "data")
        print("PARADICT",parameterdict)
        
        SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict)
        SocketIOManager.sharedInstance.getSocketdata { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                print("Socket Message Info",messageInfo)
            })
        }
    }
    
    func addHandlersTrainer(){
        
        parameterdict1.setValue("/location/receiveTrainerLocation", forKey: "url")
        
        datadict1.setValue(appDelegate.UserId, forKey: "user_id")
        datadict1.setValue(self.TrainerProfileDictionary["trainer_id"], forKey: "trainer_id")
        parameterdict1.setValue(datadict1, forKey: "data")
        print("PARADICT_ReceivedTrainerLocation",parameterdict1)
        // SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict1)
        SocketIOManager.sharedInstance.connectToServerWithParams(params: parameterdict1)
        
        SocketIOManager.sharedInstance.getSocketdata { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                print("Socket Message Info Show Trainers on Map",messageInfo)
                
                // print(Float(messageInfo["longitude"] as! String)!)
                
                self.DrowRoute(OriginLat: Float(self.lat)!, OriginLong: Float(self.long)!, DestiLat: Float((messageInfo["message"] as! NSDictionary)["latitude"] as! String)!, DestiLong: Float((messageInfo["message"] as! NSDictionary)["longitude"] as! String!)!)
                
            })
        }
    }
    
    //MARK: - REFRESH/HOME ACTIONS
    
    @IBAction func homeAction(_ sender: Any) {
        print("Home Action")
        
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        print("******* Refresh Action *******")
        
        if isFromInstantBooking{
            showTrainersList(parameters: getShowTrainersListParametersFromPreference())
        }else{
            showTrainersList(parameters: getShowTrainersListParametersFromBackup())
        }
    }
    
    //MARK: - GET PENDING TRANSACTION DETAILS

    func getPendingTransactionDetails() {
        
        let parameters =  ["user_id": appDelegate.UserId,
                           "user_type" : appDelegate.USER_TYPE
                           ] as [String : Any]
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: PENDING_TRANSACTION_DETAILS, parameters: parameters) { (jsondata) in
            print("** getPendingTransactionDetails Response: \(jsondata)")
            
            CommonMethods.hideProgress()
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    if let transactionArray = jsondata["data"] as? NSArray{
                        if transactionArray.count > 0 {
                            print("Transaction array:\(transactionArray)")
                            CommonMethods.storeUnusedTransactionsToUserDefaults(transactionDetailsArray: transactionArray)
                            self.checkIsPaymentSuccess()
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
    
    //MARK: - GET PARAMETERS
    
    func getShowTrainersListParameters() -> Dictionary <String,Any> {
        
        print("***** getShowTrainersListParameters ********")

        if isFromInstantBooking{
//            lat = preferenceModelObj.locationLattitude
//            long = preferenceModelObj.locationLongitude
            choosedTrainerGenderOfTrainee = preferenceModelObj.gender
            choosedCategoryOfTrainee.categoryId = preferenceModelObj.categoryId
        }
        
        let parameters = ["user_id" : appDelegate.UserId,
                          "gender" : choosedTrainerGenderOfTrainee,
                          "category" : choosedCategoryOfTrainee.categoryId,
                          "latitude" : lat,
                          "longitude" : long
            ] as [String : Any]
        
        return parameters
    }
    
    func getShowTrainersListParametersFromBackup() -> Dictionary <String,Any> {
        
        print("***** getShowTrainersListParametersFromBackup ********")
        let transactionCategoryChoosedBackup = userDefaults.value(forKey: "backupTrainingCategoryChoosed") as! String
        let transactionGenderChoosedBackup = userDefaults.value(forKey: "backupTrainingGenderChoosed") as! String
        
        let parameters = ["user_id" : appDelegate.UserId,
                          "gender" : transactionGenderChoosedBackup,
                          "category" : transactionCategoryChoosedBackup,
                          "latitude" : lat,
                          "longitude" : long
            ] as [String : Any]
        
        return parameters
    }
    
    func getShowTrainersListParametersFromPreference() -> Dictionary <String,Any> {
        
        print("***** getShowTrainersListParametersFromPreference ********")
        
        let parameters = ["user_id" : appDelegate.UserId,
                          "gender" : preferenceModelObj.gender,
                          "category" : preferenceModelObj.categoryId,
                          "latitude" : lat,
                          "longitude" : long
            ] as [String : Any]
        
        return parameters
    }
    
    func getRandomSelectAPIParameters() -> Dictionary <String,Any> {
        
        print("***** getRandomSelectAPIParameters ********")

        if isFromInstantBooking{
            lat = preferenceModelObj.locationLattitude
            long = preferenceModelObj.locationLongitude
            choosedTrainerGenderOfTrainee = preferenceModelObj.gender
            choosedCategoryOfTrainee.categoryId = preferenceModelObj.categoryId
        }
        
        var parameters = ["trainee_id" : appDelegate.UserId,
                          "gender" : choosedTrainerGenderOfTrainee,
                          "category" : choosedCategoryOfTrainee.categoryId,
                          "latitude" : lat,
                          "longitude" : long,
                          "training_time" : choosedSessionOfTrainee,
                          "pick_latitude" : preferenceModelObj.locationLattitude,
                          "pick_longitude" : preferenceModelObj.locationLongitude,
                          "pick_location" : preferenceModelObj.locationName,
                          "client_sign" : clientSign,
                          "parent_sign" : parentSign
            ] as [String : Any]
        
        if userDefaults.value(forKey: "promocode") != nil{
            //With Promo Code
            parameters = parameters.merged(with: ["promocode" : userDefaults.value(forKey: "promocode") as! String])
        }else{
            //With Payment Transaction
            
            //if payment has already paid and returned with new booking
//            getTransactionDetailsOncePaymentSuccessFromUserDefault()
//            let transactionDict = ["transaction_id" : transactionId,
//                                   "amount" : transactionAmount,
//                                   "transaction_status" : transactionStatus
//                ] as [String : Any]
//
//            parameters = parameters.merged(with: transactionDict)
            
            let transactionDict = [
                "amount" : transactionAmount
                ] as [String : Any]
            parameters = parameters.merged(with: transactionDict)
        }
        
        return parameters
    }
    
    func getTransactionDetailsOncePaymentSuccessFromUserDefault() {
        
        if choosedSessionOfTrainee == "40" {
            transactionId = userDefaults.value(forKey: "backupPaymentTransactionId_40Minutes") as! String
            transactionAmount = userDefaults.value(forKey: "backupIsTransactionAmount_40Minutes") as! String
            transactionStatus = userDefaults.value(forKey: "backupIsTransactionStatus_40Minutes") as! String
        }else if choosedSessionOfTrainee == "60"{
            transactionId = userDefaults.value(forKey: "backupPaymentTransactionId_60Minutes") as! String
            transactionAmount = userDefaults.value(forKey: "backupIsTransactionAmount_60Minutes") as! String
            transactionStatus = userDefaults.value(forKey: "backupIsTransactionStatus_60Minutes") as! String
        }
        
        print("***** getTransactionDetailsOncePaymentSuccessFromUserDefault *******")
        print("transactionId :\(transactionId)")
        print("transactionAmount :\(transactionAmount)")
        print("transactionStatus :\(transactionStatus)")
    }
    
    func getRandomSelectAPIParametersFromBackup() -> Dictionary <String,Any>{
        
        print("***** getRandomSelectAPIParametersFromBackup ********")

        let transactionIdBackup = userDefaults.value(forKey: "backupPaymentTransactionId") as! String
        let transactionAmountBackup = userDefaults.value(forKey: "backupIsTransactionAmount") as! String
        let transactionCategoryChoosedBackup = userDefaults.value(forKey: "backupTrainingCategoryChoosed") as! String
        let transactionGenderChoosedBackup = userDefaults.value(forKey: "backupTrainingGenderChoosed") as! String
        let transactionSessionChoosedBackup = userDefaults.value(forKey: "backupTrainingSessionChoosed") as! String
        let transactionStatusBackup = userDefaults.value(forKey: "backupIsTransactionStatus") as! String
        let client_sign = userDefaults.value(forKey: "backupClientSign") as! String
        let parent_sign = userDefaults.value(forKey: "backupParentSign") as! String

        var parameters = ["trainee_id" : appDelegate.UserId,
                          "gender" : transactionGenderChoosedBackup,
                          "category" : transactionCategoryChoosedBackup,
                          "latitude" : lat,
                          "longitude" : long,
                          "training_time" : transactionSessionChoosedBackup,
                          "pick_latitude" : preferenceModelObj.locationLattitude,
                          "pick_longitude" : preferenceModelObj.locationLongitude,
                          "pick_location" : preferenceModelObj.locationName,
                          "client_sign" : client_sign,
                          "parent_sign" : parent_sign
                          ] as [String : Any]
        
        if userDefaults.value(forKey: "promocode") != nil{
            //With Promo Code
            parameters = parameters.merged(with: ["promocode" : userDefaults.value(forKey: "promocode") as! String])
            
        }else{
            //With Payment Transaction
            let transactionDict = ["transaction_id" : transactionIdBackup,
                                   "amount" : transactionAmountBackup,
                                   "transaction_status" : transactionStatusBackup
                ] as [String : Any]
            
            parameters = parameters.merged(with: transactionDict)
        }
        
        return parameters
    }
    
    //MARK: - CHECK PROMO CODE
    
    func applyPromoCode(){
        
        guard (userDefaults.value(forKey: "promocode") != nil) else {
            print("** Applied promo code is expired or invalid ***")
            return
        }
        
        let parameters =  ["user_id": appDelegate.UserId,
                           "promocode" : userDefaults.value(forKey: "promocode") as! String
            ] as [String : Any]
        
        CommonMethods.serverCall(APIURL: APPLY_PROMO_CODE, parameters: parameters) { (jsondata) in
            print("Promo Code Response: \(jsondata)")
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    if (jsondata["data"]  as! NSDictionary)["codeStatus"] as? String == "valid" {
                        
//                        Toast(text: "Promo Code \(String(describing: (jsondata["data"] as! NSDictionary)["code"] as! String)) applied successfully").show()
                        
//                        self.view.makeToast("Promo Code \(String(describing: (jsondata["data"] as! NSDictionary)["code"] as! String)) applied successfully", duration: 3.0, position: .bottom)
                        
                    }else if(jsondata["data"]  as! NSDictionary)["codeStatus"] as? String == "expired" {
                        
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Applied promo code \(String(describing: (jsondata["data"]  as! NSDictionary)["code"] as! String)) has been expired and payment with registered card", buttonTitle: "OK")

                        userDefaults.set(false, forKey: "isPromoCodeApplied")
                        userDefaults.removeObject(forKey: "promocode")
                    }
                    
                    print("*** Payment after checking promo code valid/expired ****")
                    self.paymentCheckForNextButtonAction()

                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        }
    }
    
    func getRandomSelectAPIParametersFromPreference() -> Dictionary <String,Any> {
        
        if isFromInstantBooking{
            choosedTrainerGenderOfTrainee = preferenceModelObj.gender
            choosedCategoryOfTrainee.categoryId = preferenceModelObj.categoryId
        }
        
        //if payment has already paid and returned with new booking
//        getTransactionDetailsOncePaymentSuccessFromUserDefault()
        
        var parameters = ["trainee_id" : appDelegate.UserId,
                          "gender" : preferenceModelObj.gender,
                          "category" : preferenceModelObj.categoryId,
                          "latitude" : lat,
                          "longitude" : long,
                          "training_time" : preferenceModelObj.sessionDuration,
                          "pick_latitude" : preferenceModelObj.locationLattitude,
                          "pick_longitude" : preferenceModelObj.locationLongitude,
                          "pick_location" : preferenceModelObj.locationName,
                          "client_sign" : clientSign,
                          "parent_sign" : parentSign
            ] as [String : Any]
        
        if userDefaults.value(forKey: "promocode") != nil{
            //With Promo Code
            parameters = parameters.merged(with: ["promocode" : userDefaults.value(forKey: "promocode") as! String])
        }else{
            //With Payment Transaction
//            let transactionDict = ["transaction_id" : transactionId,
//                                   "amount" : transactionAmount,
//                                   "transaction_status" : transactionStatus
//                ] as [String : Any]
//            
//            parameters = parameters.merged(with: transactionDict)
            
            let transactionDict = [
                "amount" : transactionAmount
                ] as [String : Any]
            
            parameters = parameters.merged(with: transactionDict)
        }
        
        return parameters
    }
    
    //MARK: - API CALLS
    func RandomSelectTrainer(parameters : Dictionary <String,Any>){
        
        print("Parameters:\(parameters)")
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: RANDOM_SELECTOR, parameters: parameters, onCompletion: { (jsondata) in
            
            print("*** Random Trainer Result:",jsondata)
            
            CommonMethods.hideProgress()
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    //Show Waiting for Trainer Acceptance Page
                    if jsondata["status_type"] as? String == "TrainingRequested" {
                        print("Training Requested")
                        userDefaults.set(true, forKey: "isWaitingForTrainerAcceptance")
                        self.trainersCount = jsondata["length"] as! Int
                        self.showWaitingForAcceptancePage()
                    }
                    
                    let trainerProfileModelObj = TrainerProfileModal()
                    
                    if (jsondata["data"] as? NSDictionary) != nil {
                        
                        self.TrainerProfileDictionary = jsondata["data"] as? NSDictionary
                        
                        print("Selected Trainer Details:\(self.TrainerProfileDictionary)")
                        
                        self.selectedTrainerProfileDetails = trainerProfileModelObj.getTrainerProfileModelFromDict(dictionary: self.TrainerProfileDictionary as! Dictionary<String, Any>)
                        
                        TrainerProfileDetail.createProfileBookingEntry(TrainerProfileModal: self.selectedTrainerProfileDetails)
                        self.isPaymentSuccess = false
                        self.performSegue(withIdentifier: "trainerTraineeRouteVCSegue", sender: self)
                    }else{
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"]  as? String, buttonTitle: "Ok")
                    }
                }else if status == RESPONSE_STATUS.FAIL{
                    if jsondata["status_type"] as? String == "NoTrainersFound" {
                        self.getPendingTransactionDetails()
                    }else{
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                    }
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    func showTrainersList(parameters: Dictionary <String,Any>) {
        
        print("Params:\(parameters)")
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: SEARCH_TRAINER, parameters: parameters, onCompletion: { (jsondata) in
            
            print("*** Search Trainer Listing Result:",jsondata)
            
            CommonMethods.hideProgress()
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    print(jsondata)
                    self.jsonarray = jsondata["data"]  as! NSArray
                    if self.jsonarray.count == 0{
                        
                        self.btnNext.isHidden = true
                        self.btnRefresh.isHidden = false
                        
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"]  as? String, buttonTitle: "Ok")
                    } else{
                        self.btnNext.isHidden = false
                        self.btnRefresh.isHidden = true

                        for dict in self.jsonarray{
                            let tempDict = dict as! NSDictionary
                            print(Double(tempDict["latitude"] as! String)!)
                            self.MarkPoints(latitude: Double(tempDict["latitude"] as! String)!, logitude: Double(tempDict["longitude"] as! String)!)
                        }
                    }
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    //MARK: - BRAINTREE FUNCTIONS
    
    func fetchExistingPaymentMethod(clientToken: String) {
        
        print("***** Fetch Existing payment method *****")
        CommonMethods.showProgress()
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
                
                let nounce = result.paymentMethod?.nonce
                self.isNoncePresent = true
                self.paymentNonce = nounce!
                CommonMethods.hideProgress()
                print("New Received nonce:\(String(describing: nounce))")
            }
        })
    }
    
    func postNonceToServer(paymentMethodNonce: String) {
        
        //DEMO NONCE :"fake-valid-nonce"
        print("Nounce:\(paymentMethodNonce)")
        let headers = [
            "token":appDelegate.Usertoken]
        
        let parameters =  ["nonce" : paymentMethodNonce,
                           "training_time" : choosedSessionOfTrainee
            ] as [String : Any]
        print("PARAMS: \(parameters)")
        
        let FinalURL = SERVER_URL + PAYMENT_CHECKOUT
        print("Final Server URL:",FinalURL)
        
        CommonMethods.showProgress()
        Alamofire.request(FinalURL, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON {
            response in
            print("Checkout page Response:\(response)")
            
            CommonMethods.hideProgress()
            if let jsondata = response.value as? [String: AnyObject] {
                print(jsondata)
                
                if let status = jsondata["status"] as? Int{
                    if status == RESPONSE_STATUS.SUCCESS{
                        
                        self.navigationItem.hidesBackButton = true
                        
                        self.isPaymentSuccess = true
                        let transactionDict = jsondata["data"]  as! NSDictionary
                        
                        self.transactionId = transactionDict["transactionId"] as! String
                        self.transactionAmount = transactionDict["amount"] as! String
                        self.transactionStatus = transactionDict["status"] as! String
                        
                        if choosedSessionOfTrainee == "40"{
                            userDefaults.set(self.transactionId, forKey: "backupPaymentTransactionId_40Minutes")
                            userDefaults.set(self.transactionAmount, forKey: "backupIsTransactionAmount_40Minutes")
                            userDefaults.set(self.transactionStatus, forKey: "backupIsTransactionStatus_40Minutes")
                            userDefaults.set(true, forKey: "backupIsTransactionSuccessfull_40Minutes")
                        }else if choosedSessionOfTrainee == "60"{
                            userDefaults.set(self.transactionId, forKey: "backupPaymentTransactionId_60Minutes")
                            userDefaults.set(self.transactionAmount, forKey: "backupIsTransactionAmount_60Minutes")
                            userDefaults.set(self.transactionStatus, forKey: "backupIsTransactionStatus_60Minutes")
                            userDefaults.set(true, forKey: "backupIsTransactionSuccessfull_60Minutes")
                        }
                        
                        //Store Transaction Details and filter criterias to UserDefault for future use if Booking failed
                        userDefaults.set(self.transactionId, forKey: "backupPaymentTransactionId")
                        userDefaults.set(self.transactionAmount, forKey: "backupIsTransactionAmount")
                        userDefaults.set(true, forKey: "backupIsTransactionSuccessfull")
                        userDefaults.set(self.transactionStatus, forKey: "backupIsTransactionStatus")

                        let alert = UIAlertController(title: ALERT_TITLE, message: PAYMENT_SUCCESSFULL, preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                            
                            if self.isFromInstantBooking{
                                print("**** Random Select call - isFromInstantBooking true")
                                self.RandomSelectTrainer(parameters: self.getRandomSelectAPIParametersFromPreference())
                            }else{
                                print("**** Random Select call - Normal Case")
                                self.RandomSelectTrainer(parameters: self.getRandomSelectAPIParameters())
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    }else if status == RESPONSE_STATUS.FAIL{
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                    }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                        self.dismissOnSessionExpire()
                    }
                }else{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: REQUEST_TIMED_OUT, buttonTitle: "OK")
                }
            }
        }
    }
    
    //MARK: - STRIPE PAYMENT CHECKOUT
    
    func paymentCheckoutStripe() {
        
        let parameters =  ["training_time": choosedSessionOfTrainee,
                           ] as [String : Any]
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: PAYMENT_CHECKOUT_STRIPE, parameters: parameters) { (jsondata) in
            print("paymentCheckoutStripe Response: \(jsondata)")
            
            CommonMethods.hideProgress()
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    self.navigationItem.hidesBackButton = true
                    
                    self.isPaymentSuccess = true
                    let transactionDict = jsondata["data"]  as! NSDictionary
                    
                    self.transactionId = transactionDict["id"] as! String
                    self.transactionAmount = String(describing: transactionDict["amount"]!)
                    self.transactionStatus = transactionDict["status"] as! String
                    
                    if choosedSessionOfTrainee == "40"{
                        userDefaults.set(self.transactionId, forKey: "backupPaymentTransactionId_40Minutes")
                        userDefaults.set(self.transactionAmount, forKey: "backupIsTransactionAmount_40Minutes")
                        userDefaults.set(self.transactionStatus, forKey: "backupIsTransactionStatus_40Minutes")
                        userDefaults.set(true, forKey: "backupIsTransactionSuccessfull_40Minutes")
                    }else if choosedSessionOfTrainee == "60"{
                        userDefaults.set(self.transactionId, forKey: "backupPaymentTransactionId_60Minutes")
                        userDefaults.set(self.transactionAmount, forKey: "backupIsTransactionAmount_60Minutes")
                        userDefaults.set(self.transactionStatus, forKey: "backupIsTransactionStatus_60Minutes")
                        userDefaults.set(true, forKey: "backupIsTransactionSuccessfull_60Minutes")
                    }
                    
                    //Store Transaction Details and filter criterias to UserDefault for future use if Booking failed
                    userDefaults.set(self.transactionId, forKey: "backupPaymentTransactionId")
                    userDefaults.set(self.transactionAmount, forKey: "backupIsTransactionAmount")
                    userDefaults.set(true, forKey: "backupIsTransactionSuccessfull")
                    userDefaults.set(self.transactionStatus, forKey: "backupIsTransactionStatus")
                    
                    let alert = UIAlertController(title: ALERT_TITLE, message: PAYMENT_SUCCESSFULL, preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                        
                        if self.isFromInstantBooking{
                            print("**** Random Select call - isFromInstantBooking true")
                            self.RandomSelectTrainer(parameters: self.getRandomSelectAPIParametersFromPreference())
                        }else{
                            print("**** Random Select call - Normal Case")
                            self.RandomSelectTrainer(parameters: self.getRandomSelectAPIParameters())
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        }
    }
    
    //MARK: - WALLET CHECKOUT
    
    func paymentCheckoutWithWallet() {
        
        let parameters =  ["training_time": choosedSessionOfTrainee,
                           ] as [String : Any]
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: WALLET_CHECKOUT, parameters: parameters) { (jsondata) in
            print("paymentCheckoutWithWallet Response: \(jsondata)")
            
            CommonMethods.hideProgress()
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    self.navigationItem.hidesBackButton = true
                    
                    self.isPaymentSuccess = true
                    
                    if let statusType = jsondata["status_type"]  as? String{
                        
                        if statusType == "InsufficientBalance" {
                            
                            let alert = UIAlertController(title: ALERT_TITLE, message: INSUFFICIENT_BALANCE, preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                                
                                if let walletDict = jsondata["data"] as? NSDictionary {
                                    
                                    if let amountRequested = walletDict["amountRequest"] as? Int{
                                        self.transactionAmount = String(amountRequested)
                                    }

                                    if let amountRequired = walletDict["amountRequired"] as? Int{
                                        self.addMoneyToWallet(amount: String(amountRequired))
                                    }
                                }
                            }))
                            alert.addAction(UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: { action in
                            }))
                            self.present(alert, animated: true, completion: nil)
                            
                        }else if statusType == "Success" {
                            let alert = UIAlertController(title: ALERT_TITLE, message: PAYMENT_SUCCESSFULL, preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                                
                                if let walletDict = jsondata["data"] as? NSDictionary {
                                    
                                    if let amountRequested = walletDict["processAmount"] as? Int{
                                        self.transactionAmount = String(amountRequested)
                                    }
                                    
                                    if let walletBalance = walletDict["walletBalance"] as? Int{
                                        userDefaults.set(walletBalance, forKey: "walletBalance")
                                    }
                                }
                                
                                self.triggerRandomSelectAPIBasedOnChoice()
                            }))
                            self.present(alert, animated: true, completion: nil)
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
    
    func triggerRandomSelectAPIBasedOnChoice() {
        
        if self.isFromInstantBooking{
            print("**** Random Select call - isFromInstantBooking true")
            self.RandomSelectTrainer(parameters: self.getRandomSelectAPIParametersFromPreference())
        }else{
            print("**** Random Select call - Normal Case")
            self.RandomSelectTrainer(parameters: self.getRandomSelectAPIParameters())
        }
    }
    
    //MARK: - ADD MONEY TO WALLET
    func addMoneyToWallet(amount: String) {
        
        let parameters =  ["amount" : amount
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
                    
                    if let walletDict = jsondata["data"] as? NSDictionary {
                        
                        if let amountRequested = walletDict["amount"] as? Int{
                            self.transactionAmount = String(amountRequested)
                        }
                        self.paymentCheckoutWithWallet()
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

extension ShowTrainersOnMapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            
            print("**********************")
            print("Long \(location.coordinate.longitude)")
            print("Lati \(location.coordinate.latitude)")
            print("Alt \(location.altitude)")
            print("Sped \(location.speed)")
            print("Accu \(location.horizontalAccuracy)")
            
            print("**********************")
            
            // I have taken a pin image which is a custom image
            let markerImage = UIImage(named: "mapsicon")!.withRenderingMode(.alwaysTemplate)
            
            //creating a marker view
            let markerView = UIImageView(image: markerImage)
            
            //changing the tint color of the image
            markerView.tintColor = UIColor(red: 118.0/255.0, green: 214.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            
            mapview.camera = GMSCameraPosition(target: location.coordinate, zoom: 18, bearing: 0, viewingAngle: 0)
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude:location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            lat = String(location.coordinate.latitude)
            long = String(location.coordinate.longitude)
            
          //  self.addHandlers()
            self.locationManager.stopUpdatingLocation()
            
            if isFromSplashScreen{
                showTrainersList(parameters: getShowTrainersListParametersFromBackup())
            }else{
                showTrainersList(parameters: getShowTrainersListParameters())
            }
        }
    }
    
    func DrowRoute(OriginLat: Float, OriginLong: Float, DestiLat: Float, DestiLong: Float){
        
        print("LAT$LONG",lat)
        
        MarkPoints(latitude: Double(DestiLat), logitude: Double(DestiLong))
        
        
        let origin = "\(OriginLat),\(OriginLong)"
        let destination = "\(DestiLat),\(DestiLong)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(GOOGLE_API_KEY)"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let routes = json["routes"] as! NSArray
                    self.mapview.clear()
                    
                    OperationQueue.main.addOperation({
                        for route in routes
                        {
                            let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: "points")
                            let path = GMSPath.init(fromEncodedPath: points! as! String)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 3
                            polyline.strokeColor = UIColor.init(colorLiteralRed: 118/255, green: 214/255, blue: 255/255, alpha: 1.0)
                            
                            let bounds = GMSCoordinateBounds(path: path!)
                            self.mapview!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                            polyline.map = self.mapview
                        }
                    })
                }catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
    }

    func MarkPoints(latitude: Double, logitude: Double ){
        let marker = GMSMarker()
        // I have taken a pin image which is a custom image
        let markerImage = UIImage(named: "mapsicon")!.withRenderingMode(.alwaysTemplate)
//        let latitude1 = Double(47.15178298950195)
//        let logitude1 = Double(-122.41725158691406)
        
        //creating a marker view
        let markerView = UIImageView(image: markerImage)
        
        //changing the tint color of the image
        markerView.tintColor = UIColor(red: 118.0/255.0, green: 214.0/255.0, blue: 255.0/255.0, alpha: 1.0)

        marker.position = CLLocationCoordinate2D(latitude:CLLocationDegrees(latitude), longitude:CLLocationDegrees(logitude))
        
      //  marker.icon = markerImage
        marker.iconView = markerView
        marker.title = "Trainer"
        marker.snippet = ""
        marker.map = mapview
    }
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        mapview.isMyLocationEnabled = true
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapview.isMyLocationEnabled = true
        }
    }
}

