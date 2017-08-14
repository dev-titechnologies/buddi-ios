//
//  TrainerTraineeRouteViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 07/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

class TrainerTraineeRouteViewController: UIViewController {
    @IBOutlet weak var mapview: GMSMapView!
    @IBOutlet weak var collectionview: UICollectionView!
    var locationManager: CLLocationManager!
    var lat = Float()
    var long = Float()
    var trainerProfileDetails = TrainerProfileModal()

    var parameterdict = NSMutableDictionary()
    var datadict = NSMutableDictionary()
    var parameterdict1 = NSMutableDictionary()
    var datadict1 = NSMutableDictionary()
    let imagearray = ["play","close","message","stop"]
    let imagearrayDark = ["play-dark","close-dark","message-dark","stop-dark"]
    let cell1 = MapBottamButtonCell()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // print("PROFILE NAMEEE",trainerProfileDetails.firstName)
        SocketIOManager.sharedInstance.establishConnection()

        
        collectionview.delegate = self
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 70, height: 70)
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        flowLayout.minimumLineSpacing = 100
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        collectionview.collectionViewLayout = flowLayout

        
        

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if appDelegate.USER_TYPE == "trainer"
        {
            
        }
        else{
            self.navigationItem.leftBarButtonItem = nil
        }
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func DrowRoute(OriginLat: Float, OriginLong: Float, DestiLat: Float, DestiLong: Float){
        
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
                        
                         self.MarkPoints(latitude: Double(DestiLat), logitude: Double(DestiLong))
                        
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
    //MARK: - SOCKET CONNECTION
    
    func addHandlers() {
        
        datadict.setValue(appDelegate.UserId, forKey: "user_id")
        datadict.setValue(appDelegate.USER_TYPE, forKey: "user_type")
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
        datadict1.setValue(trainerProfileDetails.userid, forKey: "trainer_id")
        parameterdict1.setValue(datadict1, forKey: "data")
        print("PARADICT_ReceivedTrainerLocation",parameterdict1)
        // SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict1)
        SocketIOManager.sharedInstance.connectToServerWithParams(params: parameterdict1)
        
        SocketIOManager.sharedInstance.getSocketdata { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                print("Socket Message Info1",messageInfo)
                
                // print(Float(messageInfo["longitude"] as! String)!)
                
                
                 self.MarkPoints(latitude: Double((messageInfo["message"] as! NSDictionary)["latitude"] as! String)!, logitude: Double((messageInfo["message"] as! NSDictionary)["longitude"] as! String!)!)
                
                self.DrowRoute(OriginLat: Float(self.lat), OriginLong: Float(self.long), DestiLat: Float((messageInfo["message"] as! NSDictionary)["latitude"] as! String)!, DestiLong: Float((messageInfo["message"] as! NSDictionary)["longitude"] as! String!)!)
                
            })
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension TrainerTraineeRouteViewController: CLLocationManagerDelegate {
    
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
            
            
            lat = Float(location.coordinate.latitude)
            long = Float(location.coordinate.longitude)
            
        }
        
        
        if appDelegate.USER_TYPE == "trainer"
        {
            self.addHandlers()
        }
        else{
            
            self.DrowRoute(OriginLat: lat, OriginLong: long, DestiLat: Float(trainerProfileDetails.Lattitude)!, DestiLong: Float(trainerProfileDetails.Longitude)!)
            
            self.addHandlersTrainer()

            
            
        }
        
        
        
        
        locationManager.stopUpdatingLocation()
        
        
        
        
        
    }
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapview.isMyLocationEnabled = true
        }
    }
}
extension TrainerTraineeRouteViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapBottamButtonid", for: indexPath as IndexPath) as! MapBottamButtonCell
        //        cell.imageview.layer.cornerRadius = 18
        //        cell.imageview.clipsToBounds = true
        cell.bgview.layer.cornerRadius = 25
        cell.bgview.clipsToBounds = true
        
        cell.imageview.backgroundColor = UIColor.clear
        cell.imageview.image = UIImage(named:imagearrayDark[indexPath.row])
        
        
        
        return cell
    }
}


extension TrainerTraineeRouteViewController : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("INDEXPATH",indexPath.row)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapBottamButtonid", for: indexPath as IndexPath) as! MapBottamButtonCell

         cell.imageview.image = UIImage(named:imagearray[indexPath.row])
        
        switch (indexPath.row) {
        case 0:
            print("zero")
            
        case 1:
            
            print("one")
            
        case 2:
            
            print("two")
        case 3:
            
            print("three")
            
        default:
            
            print("Integer out of range")
        
        
        
        
    }
}
}
