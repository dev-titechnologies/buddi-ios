//
//  BookingDetailsVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class BookingDetailsVC: UIViewController {

    @IBOutlet weak var lblBookingId: UILabel!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var lblTrainingStatus: UILabel!
    @IBOutlet weak var lblPaymentStatus: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    
    var bookingModel = BookingHistoryModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Received Booking Ref:",bookingModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        parsingBookingDetails(bookingModel: bookingModel)
    }
    
    func parsingBookingDetails(bookingModel: BookingHistoryModel) {
        
        lblBookingId.text = bookingModel.bookingId
        lblTrainerName.text = bookingModel.trainerName
        lblTrainingStatus.text = bookingModel.trainingStatus
        lblDate.text = bookingModel.trainedDate
        lblPaymentStatus.text = bookingModel.paymentStatus
        lblCategory.text = bookingModel.category
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
