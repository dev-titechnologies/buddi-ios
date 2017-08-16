//
//  BookingDetailsVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class BookingDetailsVC: UIViewController {
    
    var bookingModel = BookingHistoryModel()
    
    @IBOutlet weak var imgTrainingPic: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgTrainerPic: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Received Booking Ref:",bookingModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        parsingBookingDetails(bookingModel: bookingModel)
    }
    
    func parsingBookingDetails(bookingModel: BookingHistoryModel) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
