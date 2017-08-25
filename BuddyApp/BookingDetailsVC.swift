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
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgTrainerPic: UIImageView!
    
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var imgTrainingPic: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Received Booking Ref:",bookingModel)
        self.title = PAGE_TITLE.TRAINING_DETAILS
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        parsingBookingDetails(bookingModel: bookingModel)
    }
    
    func parsingBookingDetails(bookingModel: BookingHistoryModel) {
        
        let stringDate = CommonMethods.getStringFromDate(date: bookingModel.trainedDate)
        
        lblDate.text = stringDate
        lblDescription.text = bookingModel.category + " session with " + bookingModel.trainerName
        lblAmount.text = "$" + bookingModel.amount
        imgTrainingPic.sd_setImage(with: URL(string: bookingModel.categoryImage), placeholderImage: UIImage(named: ""))
        
        lblTrainerName.text = "You rated " + bookingModel.trainerName
        imgTrainerPic.sd_setImage(with: URL(string: bookingModel.trainerImage), placeholderImage: UIImage(named: "profileDemoImage"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
