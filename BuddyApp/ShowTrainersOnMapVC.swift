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
    var parameterdict = NSMutableDictionary()
    var datadict = NSMutableDictionary()
    
    let TrainerprofileDetails : TrainerProfileModal = TrainerProfileModal()

    override func viewDidLoad() {
        super.viewDidLoad()
//        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 13.0)
//        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//    

        
     SocketIOManager.sharedInstance.establishConnection()
        
        
        
       
        
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
        
//        let bgview = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width , height: self.view.frame.height))
//        
//        bgview.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
//        
//        self.view.addSubview(bgview)
//        

        
        
        
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
                          "training_time" : choosedSessionOfTrainee,
                          "promocode" : "test"
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
                    
                    if (jsondata["data"] as? NSDictionary) != nil
                    {
                         self.TrainerProfileDictionary = jsondata["data"] as? NSDictionary
                        
                        self.DrowRoute(OriginLat: Float(self.lat)!, OriginLong: Float(self.long)!, DestiLat: Float((self.TrainerProfileDictionary["latitude"] as? String)!)!, DestiLong: Float((self.TrainerProfileDictionary["longitude"] as? String)!)!)
                        

                        
                    }
                    else{
                          CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"]  as? String, buttonTitle: "Ok")
                    }
                    
                    
                    
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
                    
                if self.jsonarray.count == 0
                {
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"]  as? String, buttonTitle: "Ok")
                }
                else{
                    for jsondict in self.jsonarray
                    {
                        
                        self.jsondict = jsondict as! NSDictionary
                        
                        print(Double(self.jsondict["latitude"] as! String)!)
                        
                        self.MarkPoints(latitude: Double(self.jsondict["latitude"] as! String)!, logitude: Double(self.jsondict["longitude"] as! String)!)
                        
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

  //SOCKET CONNECTION
    
    func addHandlers() {
        
        
        parameterdict.setValue("/location/addLocation", forKey: "url")
        
        
       
        datadict.setValue(appDelegate.UserId, forKey: "user_id")
        datadict.setValue("trainee", forKey: "user_type")
        datadict.setValue(lat, forKey: "latitude")
        datadict.setValue(long, forKey: "longitude")
        datadict.setValue("online", forKey: "avail_status")
        

        
        parameterdict.setValue(datadict, forKey: "data")
        print("PARADICT",parameterdict)
        SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict)
        
        
        
        SocketIOManager.sharedInstance.getSocketdata { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                print("Socket Message Info",messageInfo)
                
             
            })
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
            

//            if TrainerProfileDictionary.allValues.isEmpty
//            {
//                
//            }
//            else{
//                
//                self.DrowRoute(OriginLat: Float(self.lat)!, OriginLong: Float(self.long)!, DestiLat: Float((self.TrainerProfileDictionary["latitude"] as? String)!)!, DestiLong: Float((self.TrainerProfileDictionary["longitude"] as? String)!)!)
//                
//
//            }
//            
                        self.addHandlers()
            
            
            self.locationManager.stopUpdatingLocation()
            
            
            
           // showTrainersList()
        }
        
        
       
        
        
        
        
        
    }
    func DrowRoute(OriginLat: Float, OriginLong: Float, DestiLat: Float, DestiLong: Float)
    {
        print("LAT$LONG",lat)
        
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
