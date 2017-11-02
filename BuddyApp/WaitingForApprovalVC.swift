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
        
//        checkForAdminApprovalServerCall()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func checkForAdminApprovalServerCall() {
        
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
        let parameters = ["user_id" : appDelegate.UserId,"user_type" : appDelegate.USER_TYPE] as [String : Any]
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: CATEGORY_APPROVED_STATUS, parameters: parameters, onCompletion: { (jsondata) in
            
            print("*** Category Approval Result:",jsondata)
            
            CommonMethods.hideProgress()
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    let approvalStatusArray = jsondata["data"] as! NSDictionary as! [String: Any]
                    print("approvalStatusArray:\(approvalStatusArray)")
                    
                    if appDelegate.USER_TYPE == USER_TYPE.TRAINER{
                        if approvalStatusArray["category_status"] as! String == "Approved"{
                            self.performSegue(withIdentifier: "waitingForApprovalToHomePageSegue", sender: self)
                        }else{
                            self.performSegue(withIdentifier: "waitingForApprovalToLoginPageSegue", sender: self)
                        }
                    }else if appDelegate.USER_TYPE == USER_TYPE.TRAINEE{
                        self.performSegue(withIdentifier: "waitingForApprovalToLoginPageSegue", sender: self)
                    }
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }

    @IBAction func checkForAdminApproval(_ sender: Any) {
        
    }
    
    @IBAction func exitAction(_ sender: Any) {
        
        checkForAdminApprovalServerCall()
        
//        if appDelegate.USER_TYPE == "trainer" {
//            self.performSegue(withIdentifier: "waitingForApprovalToLoginPageSegue", sender: self)
//        }else if appDelegate.USER_TYPE == "trainee"{
//            self.performSegue(withIdentifier: "waitingForApprovalToLoginPageSegue", sender: self)
////            self.performSegue(withIdentifier: "waitingForApprovalToHomePageSegue", sender: self)
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
