//
//  BookingHistoryVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class BookingHistoryVC: UIViewController {

    @IBOutlet weak var bookingHistoryTable: UITableView!
    var bookingsArray = [BookingHistoryModel]()
    let bookingHistoryModelObj: BookingHistoryModel = BookingHistoryModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = PAGE_TITLE.TRAINING_HISTORY
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         fetchBookingData()
       
    }

    func fetchBookingData() {
        
        let parameters = ["user_id":appDelegate.UserId,
                          "user_type":appDelegate.USER_TYPE]
            as [String : Any]
        
        let headers = ["token":appDelegate.Usertoken]
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: BOOKING_HISTORY_URL, parameters: parameters, headers: headers, onCompletion: { (jsondata) in
            
            CommonMethods.hideProgress()

            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                
                if status == RESPONSE_STATUS.SUCCESS {
                    print("Booking History Response:",jsondata)
                  
                    if let booking_history_array = jsondata["data"] as? NSArray{
                        
                        self.bookingsArray.removeAll()
                    
                        for booking_history in booking_history_array{
                        
                            let modelObject = self.bookingHistoryModelObj.getBookingHistoryModelFromDict(dictionary: booking_history as! Dictionary<String, Any>)
                            print(modelObject.trainedDate)
                            print(modelObject.bookingId)
                            BookingHistoryDB.createBookingEntry(bookingModel: modelObject)
                            self.bookingsArray.append(modelObject)
                            
                            self.bookingsArray.reverse()
                            
                            if self.bookingsArray.count > 0 {
                                
                                print("BOOKING ARRAY COUNT",self.bookingsArray.count)
                                self.bookingHistoryTable.isHidden = false
                                self.bookingHistoryTable.reloadData()
                            }else{
                                self.bookingHistoryTable.isHidden = true
                            }
                        }
                    }
                }else if status == RESPONSE_STATUS.FAIL{
                      CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")

                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    print("Session Expired")
                    self.dismissOnSessionExpire()
                }
            }else{
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: REQUEST_TIMED_OUT, buttonTitle: "OK")
            }
        })
    }
    
    //MARK: - MEMORY WARNING
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - TABLEVIEW DATASOURCE
extension BookingHistoryVC: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookingsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: BookingHistoryTableCell = tableView.dequeueReusableCell(withIdentifier: "bookinghistorycellid") as! BookingHistoryTableCell
        
        let booking = bookingsArray[indexPath.row]
      
       
        cell.date.text = CommonMethods.convert24hrsTo12hrs(date: booking.trainedDate)
        
        
        
        
        if appDelegate.USER_TYPE == "trainer"{
            cell.lblDescription.text = booking.category + " session with " + booking.traineeName
        }else{
             cell.lblDescription.text = booking.category + " session with " + booking.trainerName
        }
        
       
        cell.lblAmount.text = "$" + booking.amount
        cell.imgTrainingPic.sd_setImage(with: URL(string: booking.categoryImage), placeholderImage: UIImage(named: ""))
        
        return cell
    }
}

//MARK: - TABLEVIEW DELEGATES

extension BookingHistoryVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "bookingDetailsSegue"{
            let bookingDetailsPage =  segue.destination as! BookingDetailsVC
            
            if let indexPath = self.bookingHistoryTable.indexPathForSelectedRow {
                let selectedBooking = bookingsArray[indexPath.row]
                print("Selected Booking",selectedBooking)
                bookingDetailsPage.bookingModel = selectedBooking
            }
        }
    }
}
