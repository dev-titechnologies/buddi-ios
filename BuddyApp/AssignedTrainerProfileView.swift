//
//  AssignedTrainerProfileView.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 04/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class AssignedTrainerProfileView: UIViewController {

    @IBOutlet weak var imgProfileImage: UIImageView!
    
    @IBOutlet weak var lblProfileName: UILabel!
    @IBOutlet weak var lblTrainerAge: UILabel!
    @IBOutlet weak var lblTrainerHeight: UILabel!
    @IBOutlet weak var lblTrainerWeight: UILabel!
    @IBOutlet weak var lblMeetingDescription: UILabel!
    @IBOutlet weak var trainerDescriptionTable: UITableView!
    
    @IBOutlet weak var reviewview: UIView!
    var assignedTrainerProfileView = [String]()
    var TrainerprofileDictionary: NSDictionary!
    var TrainerId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("VIEWDIDLOAD")

        assignedTrainerProfileView = ["Gym Subscriptions", "Training Category", "Training History", "Coaching History", "Certifications"]
        
        self.parseTrainerProfileDetails()
        
       // print(self.TrainerprofileDictionary)
        
// lblProfileName.text = (self.TrainerprofileDictionary["first_name"] as? String)! + " " + (self.TrainerprofileDictionary["last_name"] as? String)!
        
//        
//        lblTrainerAge.text =  CommonMethods.checkStringNull(val: self.TrainerprofileDictionary["age"] as? String)
//        lblTrainerHeight.text = CommonMethods.checkStringNull(val: self.TrainerprofileDictionary["height"] as? String)
//        lblTrainerWeight.text = CommonMethods.checkStringNull(val: self.TrainerprofileDictionary["weight"] as? String)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
         print("VIEWWILLAPPEAR")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func parseTrainerProfileDetails() {
        
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
        let parameters = ["user_type":"trainer",
                          "user_id":TrainerId] as [String : Any]
        
        let headers = [
            "token":appDelegate.Usertoken ]
        
        print("PARAMS",parameters)
        print("HEADER",headers)
        
        CommonMethods.serverCall(APIURL: VIEW_PROFILE, parameters: parameters , headers: headers , onCompletion: { (jsondata) in
            print("PROFILE RESPONSE",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    self.TrainerprofileDictionary = jsondata["data"]  as! NSDictionary
                    print(self.TrainerprofileDictionary)
                    
                     self.lblProfileName.text = (self.TrainerprofileDictionary["first_name"] as? String)! + " " + (self.TrainerprofileDictionary["last_name"] as? String)!
                    
                           self.lblTrainerAge.text =  CommonMethods.checkStringNull(val: self.TrainerprofileDictionary["age"] as? String)
                            self.lblTrainerHeight.text = CommonMethods.checkStringNull(val: self.TrainerprofileDictionary["height"] as? String)
                            self.lblTrainerWeight.text = CommonMethods.checkStringNull(val: self.TrainerprofileDictionary["weight"] as? String)
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    @IBAction func doneAction(_ sender: Any) {
    }
}

extension AssignedTrainerProfileView: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignedTrainerProfileView.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4 {
            let cell: AssignedTrainerProfileTableCaptionsCell = tableView.dequeueReusableCell(withIdentifier: "captionCellId") as! AssignedTrainerProfileTableCaptionsCell
            
            cell.title_lbl.text = assignedTrainerProfileView[indexPath.row]
            
            
            return cell

        }else if indexPath.row == 5{
            let cell: AssignedTrainerSocialMediaCell = tableView.dequeueReusableCell(withIdentifier: "socialMediaCellId") as! AssignedTrainerSocialMediaCell
            return cell

        }else{
            let cell: AssignedTrainerEmailCell = tableView.dequeueReusableCell(withIdentifier: "emailCellId") as! AssignedTrainerEmailCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        var row = 0.0
        
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4 {
           row = 60.0
        }else if indexPath.row == 5{
            row = 150.0
        }else{
            row = 60.0
        }
        return CGFloat(row)
    }
}

extension AssignedTrainerProfileView: UITableViewDelegate{
    
}
