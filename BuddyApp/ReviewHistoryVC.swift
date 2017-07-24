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
        guard let JSONData = Data.ts_dataFromJSONFile("ReviewHistory") else { return }
        let jsonObject = JSON(data: JSONData)
        if jsonObject != JSON.null {
            print("JSON RESP:",jsonObject)
            
            for dict in jsonObject["data"].arrayObject! {
                
                print(dict)
                let reviewModelObj = reviewHistoryModelObj.getReviewHistoryModelFromDict(dictionary: dict as! Dictionary<String, Any>)
                reviewsArray.append(reviewModelObj)
                ReviewHistoryDB.createReviewEntry(reviewModel: reviewModelObj)
            }
            
            self.reviewHistoryTable.reloadData()
        }
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
