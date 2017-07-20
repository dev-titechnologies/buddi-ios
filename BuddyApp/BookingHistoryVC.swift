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

        fetchBookingData()
    }

    func fetchBookingData() {
        guard let JSONData = Data.ts_dataFromJSONFile("BookingHistory") else { return }
        let jsonObject = JSON(data: JSONData)
        if jsonObject != JSON.null {
            print("JSON RESP:",jsonObject)
            
            for dict in jsonObject["data"].arrayObject! {

                let bookingModelObj : BookingHistoryModel = bookingHistoryModelObj.getBookingHistoryModelFromDict(dictionary: dict as! Dictionary<String, Any>)
                bookingsArray.append(bookingModelObj)
                BookingHistoryDB.createBookingEntry(bookingModel: bookingModelObj)
            }
            
            print(bookingsArray)
            self.bookingHistoryTable.reloadData()
        }
    }
    
    func test() {
        
        let parameters = [
            "register_type":"a",
            "email":"test@gmail.com",
            "password":"a",
            "first_name": "a",
            "last_name": "a",
            "mobile": "ios",
            "gender":"a",
            "user_image": "a",
            "user_type": "a",
            "facebook_id": "a",
            "google_id": "ios",
            "profile_desc":"jnkolj"
        ]
        
        let headers = [
            "device_id": "y",
            "device_imei": "yu",
            "device_type": "ios",
            
            ]
        
        print("PARMSSS",parameters)
        
        CommonMethods.serverCall(APIURL: REGISTER_URL, parameters: parameters, headers: headers) { (jsondata) in
            print("1234",jsondata)
          //  print(jsondata["token"].stringValue)
        }
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
        cell.date.text     = bookingsArray[indexPath.row].trainedDate
        
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
