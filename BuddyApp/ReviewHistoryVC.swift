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
        
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
        let parameters = ["user_id":"21","user_type":"trainee"]
        let headers = ["token":appDelegate.Usertoken]
        
        CommonMethods.serverCall(APIURL: REVIEW_HISTORY_URL, parameters: parameters, headers: headers, onCompletion: { (jsondata) in
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                
                if status == RESPONSE_STATUS.SUCCESS {
                    print("Review History Response:",jsondata)
                    
                    let review_history_array : Array = jsondata["data"] as! NSArray as Array
                    for review_history in review_history_array{
                        
                        let modelObject = self.reviewHistoryModelObj.getReviewHistoryModelFromDict(dictionary: review_history as! Dictionary<String, Any>)
                        print(modelObject)
                        ReviewHistoryDB.createReviewEntry(reviewModel: modelObject)
                        self.reviewsArray.append(modelObject)
                        self.reviewHistoryTable.reloadData()
                    }
                }else if status == RESPONSE_STATUS.FAIL {
                    print("Server Resp Fail")
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    print("Session Expired")
                    self.dismissOnSessionExpire()
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
        
        let stringDate = CommonMethods.getStringFromDate(date: reviewsArray[indexPath.row].reviewDate)
        print(stringDate)

        cell.lblReviewDesc.text = reviewsArray[indexPath.row].reviewDescription
        cell.lblReviewDate.text = stringDate
        cell.lblTraineeName.text = reviewsArray[indexPath.row].traineeName
        cell.lblStarRatingValue.text = reviewsArray[indexPath.row].starRatingValue

        return cell
    }

}
