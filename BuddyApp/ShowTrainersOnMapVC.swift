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

class ShowTrainersOnMapVC: UIViewController {

    @IBOutlet weak var mapview: GMSMapView!
    var locationManager: CLLocationManager!
    var lat = String()
    var long = String()
    var mapView = GMSMapView()
    var jsonarray = NSArray()
    var jsondict = NSDictionary()
    var TrainerProfileDictionary: NSDictionary!
    
    let TrainerprofileDetails : TrainerProfileModal = TrainerProfileModal()

    override func viewDidLoad() {
        super.viewDidLoad()
//        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 13.0)
//        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//    

        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getCurrentLocationDetails()
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
        
        CommonMethods.showProgress()
        
        RandomSelectTrainer()
    }
    
    func RandomSelectTrainer()
    {
        
        let headers = [
            "token":appDelegate.Usertoken]
        
        let parameters = ["user_id" : appDelegate.UserId,
                          "gender" : choosedTrainerGenderOfTrainee,
                          "category" : choosedCategoryOfTrainee.categoryId,
                          "latitude" : lat,
                          "longitude" : long,
                          "duration" : choosedSessionOfTrainee
            ] as [String : Any]
        
        print("Header:\(headers)")
        print("Params:\(parameters)")
        
        CommonMethods.serverCall(APIURL: RANDOM_SELECTOR, parameters: parameters, headers: headers, onCompletion: { (jsondata) in
            
            print("*** Random Trainer Result:",jsondata)
            
            guard (jsondata["status"] as? Int) != nil else {
                 CommonMethods.hideProgress()
                
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                  //  print(jsondata)
                    
                    
                    CommonMethods.hideProgress()
                    
                    self.TrainerProfileDictionary = jsondata["data"] as? NSDictionary
                    
                    
                  //  self.TrainerprofileDetails.getTrainerProfileModelFromDict(dictionary: jsondata["data"] as? NSDictionary as! Dictionary<String, Any>)
                    
//                     let modelObject = self.TrainerprofileDetails.getTrainerProfileModelFromDict(dictionary: self.TrainerProfileDictionary as! Dictionary<String, Any>)
//                    
                    
                    self.performSegue(withIdentifier: "totrainerprofile", sender: self)
                    
                    
                }else if status == RESPONSE_STATUS.FAIL{
                     CommonMethods.hideProgress()
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                     CommonMethods.hideProgress()
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
                    
                    
                    for jsondict in self.jsonarray
                    {
                    
                        self.jsondict = jsondict as! NSDictionary
                        
                        print(Double(self.jsondict["latitude"] as! String)!)
                        
                self.MarkPoints(latitude: Double(self.jsondict["latitude"] as! String)!, logitude: Double(self.jsondict["longitude"] as! String)!)
                        
                }
                    
                    
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "totrainerprofile"
        {
            
            let TrainerProPage =  segue.destination as! AssignedTrainerProfileView
        
        TrainerProPage.TrainerprofileDictionary = self.TrainerProfileDictionary
            
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
            
//             marker.iconView = markerView
//            marker.title = "Sydney"
//            marker.snippet = "Australia"
//            marker.map = mapview
            
            lat = String(location.coordinate.latitude)
            long = String(location.coordinate.longitude)
            
//            //For Demo
//            lat = "8.9300"
//            long = "76.9065"
            

            self.locationManager.stopUpdatingLocation()
            
            
            
            showTrainersList()
        }
        
        
       
        
        
        
        
        
    }
    func MarkPoints(latitude: Double, logitude: Double )
    {
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
