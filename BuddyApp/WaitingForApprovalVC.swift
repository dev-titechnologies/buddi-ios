//
//  WaitingForApprovalVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 27/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class WaitingForApprovalVC: UIViewController {

    @IBOutlet weak var lblApprovalStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    @IBAction func checkForAdminApproval(_ sender: Any) {
        
        let parameters = ["user_id" : appDelegate.UserId,"user_type" : appDelegate.USER_TYPE] as [String : Any]
        let headers = ["token":appDelegate.Usertoken]
        
        CommonMethods.serverCall(APIURL: CATEGORY_APPROVED_STATUS, parameters: parameters, headers: headers, onCompletion: { (jsondata) in
            
            print("*** Category Approval Result:",jsondata)
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS {
                    
                    let approvalStatusArray = jsondata["data"] as! NSDictionary as! [String: Any]
                    print(approvalStatusArray)
//                    self.lblApprovalStatus.text = approvalStatusArray["category_status"] as! String
                    if approvalStatusArray["category_status"] as! String == "approved"{
                        self.performSegue(withIdentifier: "waitingForApprovalToHomePageSegue", sender: self)
                    }
                }
            }
        })
    }
    
    @IBAction func exitAction(_ sender: Any) {
        
        if appDelegate.USER_TYPE == "trainer" {
            
            self.performSegue(withIdentifier: "waitingForApprovalToLoginPageSegue", sender: self)
            
        }else if appDelegate.USER_TYPE == "trainee"{
            
            self.performSegue(withIdentifier: "waitingForApprovalToHomePageSegue", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
