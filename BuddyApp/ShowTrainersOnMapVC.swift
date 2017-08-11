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

class ShowTrainersOnMapVC: UIViewController {

    @IBOutlet weak var collectionview: UICollectionView!
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

    
    fileprivate let sectionInsets = UIEdgeInsets(top: 5.0, left: 0, bottom: 0, right: 0)
    fileprivate let itemsPerRow: CGFloat = 4

    let imagearray = ["play","close","message","stop"]
    
    
    //Payment Transaction Variables
    var transactionId = String()
    var transactionStatus = String()
    var transactionAmount = String()
    
    var isPromoCodeExists = Bool()
    
    var selectedTrainerProfileDetails : TrainerProfileModal = TrainerProfileModal()
    
    
    //MARK: - VIEW CYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionview.delegate = self
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 70, height: 70)
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        flowLayout.minimumLineSpacing = 100
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        collectionview.collectionViewLayout = flowLayout
        SocketIOManager.sharedInstance.establishConnection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getCurrentLocationDetails()
        fetchClientTokenFromUserDefault()
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
//        self.RandomSelectTrainer()
        
        if isNoncePresent {
            postNonceToServer(paymentMethodNonce: paymentNonce)
        }else{
            alertForAddPaymentMethod()
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
    
    //MARK: - API CALLS
    func RandomSelectTrainer(){
        
        isPromoCodeExists = true
        
        let headers = [
            "token":appDelegate.Usertoken]
        
        //Parameters :- If payment is via Promo Code
        var parameters = ["user_id" : appDelegate.UserId,
                          "gender" : choosedTrainerGenderOfTrainee,
                          "category" : choosedCategoryOfTrainee.categoryId,
                          "latitude" : lat,
                          "longitude" : long,
                          "training_time" : choosedSessionOfTrainee,
                          ] as [String : Any]
        
        if isPromoCodeExists{
            //With Promo Code
            parameters = parameters.merged(with: ["promocode" : "TEST CODE"])
        }else{
            //With Payment Transaction
            let transactionDict = ["transaction_id" : transactionId,
                                   "amount" : transactionAmount,
                                   "transaction_status" : transactionStatus
                ] as [String : Any]
            
            parameters = parameters.merged(with: transactionDict)
        }
        
        print("Header:\(headers)")
        print("Parameters:\(parameters)")
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: RANDOM_SELECTOR, parameters: parameters, headers: headers, onCompletion: { (jsondata) in
            
            print("*** Random Trainer Result:",jsondata)
            
            CommonMethods.hideProgress()
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    let trainerProfileModelObj = TrainerProfileModal()
                    if (jsondata["data"] as? NSDictionary) != nil {
                        
                        self.TrainerProfileDictionary = jsondata["data"] as? NSDictionary
                        
                        print("Selected Trainer Details:\(self.TrainerProfileDictionary)")
                        
                        self.selectedTrainerProfileDetails = trainerProfileModelObj.getTrainerProfileModelFromDict(dictionary: self.TrainerProfileDictionary as! Dictionary<String, Any>)
                        self.performSegue(withIdentifier: "trainerTraineeRouteVCSegue", sender: self)
                        
//                        self.DrowRoute(OriginLat: Float(self.lat)!, OriginLong: Float(self.long)!, DestiLat: Float(((self.TrainerProfileDictionary["trainer_details"] as? NSDictionary)?["trainer_latitude"] as? String)!)!, DestiLong: Float(((self.TrainerProfileDictionary["trainer_details"] as? NSDictionary)?["trainer_longitude"] as? String)!)!)
                        
//                        self.addHandlersTrainer()
                    }else{
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"]  as? String, buttonTitle: "Ok")
                    }
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    func showTrainersList() {
        
        let headers = [
            "token":appDelegate.Usertoken]
        
        let parameters = ["user_id" : appDelegate.UserId,
                          "gender" : choosedTrainerGenderOfTrainee,
                          "category" : choosedCategoryOfTrainee.categoryId,
                          "latitude" : lat,
                          "longitude" : long
            ] as [String : Any]
        
        print("Header:\(headers)")
        print("Params:\(parameters)")
        
        CommonMethods.serverCall(APIURL: SEARCH_TRAINER, parameters: parameters, headers: headers, onCompletion: { (jsondata) in
            
            print("*** Search Trainer Listing Result:",jsondata)
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    print(jsondata)
                    self.jsonarray = jsondata["data"]  as! NSArray
                    if self.jsonarray.count == 0{
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"]  as? String, buttonTitle: "Ok")
                    } else{
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
                print("Socket Message Info1",messageInfo)
                
               // print(Float(messageInfo["longitude"] as! String)!)
                
               self.DrowRoute(OriginLat: Float(self.lat)!, OriginLong: Float(self.long)!, DestiLat: Float((messageInfo["message"] as! NSDictionary)["latitude"] as! String)!, DestiLong: Float((messageInfo["message"] as! NSDictionary)["longitude"] as! String!)!)
                
            })
        }
    }
    
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
        
        let parameters =  ["nonce" : paymentMethodNonce
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
                        
                        let transactionDict = jsondata["data"]  as! NSDictionary
                        self.transactionId = transactionDict["transactionId"] as! String
                        self.transactionAmount = transactionDict["amount"] as! String
                        self.transactionStatus = transactionDict["status"] as! String
                        
                        let alert = UIAlertController(title: ALERT_TITLE, message: PAYMENT_SUCCESSFULL, preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                            self.RandomSelectTrainer()
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
    
    @IBAction func reviewAction(_ sender: Any) {
        performSegue(withIdentifier: "trainerReviewPageSegue", sender: self)
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
            
            
            
          
            showTrainersList()
        }
    }
    
    func DrowRoute(OriginLat: Float, OriginLong: Float, DestiLat: Float, DestiLong: Float){
        
        print("LAT$LONG",lat)
        
        MarkPoints(latitude: Double(DestiLat), logitude: Double(DestiLong))
        
        
        let origin = "\(OriginLat),\(OriginLong)"
        let destination = "\(DestiLat),\(DestiLong)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyCSZe_BrUnVvqOg4OCQUHY7fFem6bvxOkc"
        
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
        
        //creating a marker view
        let markerView = UIImageView(image: markerImage)
        
        //changing the tint color of the image
        markerView.tintColor = UIColor(red: 118.0/255.0, green: 214.0/255.0, blue: 255.0/255.0, alpha: 1.0)

        marker.position = CLLocationCoordinate2D(latitude:CLLocationDegrees(latitude), longitude:CLLocationDegrees(logitude))
        
      //  marker.icon = markerImage
        marker.iconView = markerView
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapview
    }
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        mapview.isMyLocationEnabled = true
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapview.isMyLocationEnabled = true
        }
    }
}

extension ShowTrainersOnMapVC : UICollectionViewDelegateFlowLayout {
    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
//        let availableWidth = view.frame.width - paddingSpace
//        let widthPerItem = availableWidth / itemsPerRow
//        
//        return CGSize(width: 50, height: 50)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return sectionInsets
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return sectionInsets.left
//    }
}
extension ShowTrainersOnMapVC : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapBottamButtonid", for: indexPath as IndexPath) as! MapBottamButtonCell
//        cell.imageview.layer.cornerRadius = 18
//        cell.imageview.clipsToBounds = true
        cell.bgview.layer.cornerRadius = 30
        cell.bgview.clipsToBounds = true
        
        cell.imageview.backgroundColor = UIColor.clear
        cell.imageview.image = UIImage(named:imagearray[indexPath.row])
        
   
        
        return cell
    }
}


extension ShowTrainersOnMapVC : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    print("INDEXPATH",indexPath.row)
    
    }
}
