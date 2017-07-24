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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchBookingData()
    }

    func fetchBookingData() {
        
        let parameters = ["user_id":"21","user_type":"trainer"]
        let headers = ["token":"395883b4b930662706848a34"]
        
        CommonMethods.serverCall(APIURL: BOOKING_HISTORY_URL, parameters: parameters, headers: headers, onCompletion: { (jsondata) in
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                
                if status == RESPONSE_STATUS.SUCCESS {
                    print("Booking History Response:",jsondata)
                    
                    let booking_history_array : Array = jsondata["data"] as! NSArray as Array
                    for booking_history in booking_history_array{
                        
                        let modelObject = self.bookingHistoryModelObj.getBookingHistoryModelFromDict(dictionary: booking_history as! Dictionary<String, Any>)
                        print(modelObject)
                        BookingHistoryDB.createBookingEntry(bookingModel: modelObject)
                        self.bookingsArray.append(modelObject)
                        self.bookingHistoryTable.reloadData()
                    }
                }else if status == RESPONSE_STATUS.FAIL{
                    print("Server Resp Fail")

                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    print("Session Expired")

                }
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
        
        cell.category.text = bookingsArray[indexPath.row].category
        let stringDate = CommonMethods.getStringFromDate(date: bookingsArray[indexPath.row].trainedDate)
        print(stringDate)
        cell.date.text = stringDate
        
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
