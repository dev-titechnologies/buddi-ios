//
//  ReviewHistoryVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReviewHistoryVC: UIViewController {

    @IBOutlet weak var reviewHistoryTable: UITableView!
    var reviewsArray = [ReviewHistoryModel]()
    var reviewHistoryModelObj: ReviewHistoryModel = ReviewHistoryModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        fetchReviewData()
    }
    
    func fetchReviewData() {
        
        let parameters = ["user_id":"21","user_type":"trainer"]
        let headers = ["token":"395883b4b930662706848a34"]
        
        CommonMethods.serverCall(APIURL: REVIEW_HISTORY_URL, parameters: parameters, headers: headers, onCompletion: { (jsondata) in
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                
                if status == RESPONSE_STATUS.SUCCESS {
                    print("Review History Response:",jsondata)
                    
//                    let booking_history_array : Array = jsondata["data"] as! NSArray as Array
//                    for booking_history in booking_history_array{
//                        
//                        let modelObject = self.bookingHistoryModelObj.getBookingHistoryModelFromDict(dictionary: booking_history as! Dictionary<String, Any>)
//                        print(modelObject)
//                        BookingHistoryDB.createBookingEntry(bookingModel: modelObject)
//                        self.bookingsArray.append(modelObject)
//                        self.bookingHistoryTable.reloadData()
//                    }
                }else if status == RESPONSE_STATUS.FAIL {
                    print("Server Resp Fail")
                    
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    print("Session Expired")
                    
                }
            }
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

//MARK: - TABLEVIEW DATASOURCE

extension  ReviewHistoryVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ReviewHistoryTableCell = tableView.dequeueReusableCell(withIdentifier: "reviewHistoryCellId") as! ReviewHistoryTableCell
        
        cell.lblReviewDesc.text = reviewsArray[indexPath.row].reviewDescription
        cell.lblReviewDate.text = reviewsArray[indexPath.row].reviewDate
        cell.lblTraineeName.text = reviewsArray[indexPath.row].traineeName
        cell.lblStarRatingValue.text = reviewsArray[indexPath.row].starRatingValue

        return cell
    }

}
