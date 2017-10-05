//
//  BookingDetailsVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import MapKit

class BookingDetailsVC: UIViewController {
    
    var bookingModel = BookingHistoryModel()
    let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    @IBOutlet weak var paymentstatus_lbl: UILabel!
    @IBOutlet weak var location_lbl: UILabel!
   
    @IBOutlet weak var trainingstatus_lbl: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgTrainerPic: UIImageView!
    
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var imgTrainingPic: UIImageView!

    @IBOutlet weak var ratingview: SwiftyStarRatingView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        ratingview.isUserInteractionEnabled = false
       
        ratingview.allowsHalfStars = true

        print("Received Booking Ref:",bookingModel)
        self.title = PAGE_TITLE.TRAINING_DETAILS
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        location_lbl.numberOfLines = 0
        location_lbl.sizeToFit()
        
        parsingBookingDetails(bookingModel: bookingModel)
    }
    
    func parsingBookingDetails(bookingModel: BookingHistoryModel) {
        
               
        
        if appDelegate.USER_TYPE == "trainer"{
            lblDescription.text = bookingModel.category + " session with " + bookingModel.traineeName
            lblTrainerName.text = "You rated " + bookingModel.traineeName
        }else{
           lblDescription.text = bookingModel.category + " session with " + bookingModel.trainerName
            lblTrainerName.text = "You rated " + bookingModel.trainerName
        }

        paymentstatus_lbl.text = bookingModel.paymentStatus
        trainingstatus_lbl.text = bookingModel.trainingStatus
        
        lblDate.text =  CommonMethods.convert24hrsTo12hrs(date: bookingModel.trainedDate)
        lblAmount.text = "$" + bookingModel.amount
        imgTrainingPic.sd_setImage(with: URL(string: bookingModel.categoryImage), placeholderImage: UIImage(named: ""))
        
        
        imgTrainerPic.sd_setImage(with: URL(string: bookingModel.profilePic), placeholderImage: UIImage(named: "profileDemoImage"))
       
        
        ratingview.value = CGFloat((bookingModel.rating as NSString).floatValue)
        
        ReverseGeoCoding()
        
    }
    func ReverseGeoCoding()
    {
        var myStringArr = bookingModel.location.components(separatedBy: "/")
        
        
        let longitude :CLLocationDegrees = Double(myStringArr[1] as String)!
        let latitude :CLLocationDegrees = Double(myStringArr[0] as String)!
        
        
        self.getAddressForLatLng(latitude: myStringArr[0] as String, longitude: myStringArr[1] as String)
    }
    func getAddressForLatLng(latitude: String, longitude: String) {
        
        print(latitude)
        print(longitude)
        
        let url = NSURL(string: "\(baseUrl)latlng=\(latitude),\(longitude)&key=\(GOOGLE_API_KEY)")
        let data = NSData(contentsOf: url! as URL)
        let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
        if let result = json["results"] as? NSArray {
//            if let address = result[0]["address_components"] as? NSArray {
//                let number = address[0]["short_name"] as! String
//                let street = address[1]["short_name"] as! String
//                let city = address[2]["short_name"] as! String
//                let state = address[4]["short_name"] as! String
//                let zip = address[6]["short_name"] as! String
//                print("\n\(number) \(street), \(city), \(state) \(zip)")
//            }
            
            
            
            
            print((result[0] as! NSDictionary)["formatted_address"]!)
            
            location_lbl.text = (result[0] as! NSDictionary)["formatted_address"]! as? String
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
