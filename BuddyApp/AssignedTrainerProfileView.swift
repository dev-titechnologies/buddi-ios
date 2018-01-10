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
    
    var assignedTrainerProfileView = [String]()
    var TrainerprofileDictionary: NSDictionary!
    var TrainerId = String()
    
    var trainingLocation = String()
    var trainingCategory = String()
    
    @IBOutlet weak var imgHeightIcon: UIImageView!
    @IBOutlet weak var imgWeightIcon: UIImageView!
    
    var TimerDict = NSDictionary()
    var numOfDays = Int()
    var timerCheckValue = Bool()
    
    //social media urls/links
    var facebookLink = String()
    var instagramLink = String()
    var linkdInLink = String()
    var snapchatLink = String()
    var twitterLink = String()
    var youtubeLink = String()

//MARK: - VIEW CYCLES 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("VIEWDIDLOAD")

        assignedTrainerProfileView = ["Gym Subscriptions", "Training Category", "Training History", "Coaching History", "Certifications"]
        
        self.parseTrainerProfileDetails()
        print(self.TrainerprofileDictionary)
        
// lblProfileName.text = (self.TrainerprofileDictionary["first_name"] as? String)! + " " + (self.TrainerprofileDictionary["last_name"] as? String)!
        
//        
//        lblTrainerAge.text =  CommonMethods.checkStringNull(val: self.TrainerprofileDictionary["age"] as? String)
//        lblTrainerHeight.text = CommonMethods.checkStringNull(val: self.TrainerprofileDictionary["height"] as? String)
//        lblTrainerWeight.text = CommonMethods.checkStringNull(val: self.TrainerprofileDictionary["weight"] as? String)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        print("VIEWWILLAPPEAR")
        
        lblMeetingDescription.text = "You guys are meeting at \(trainingLocation) to train \(trainingCategory)"
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
        
        let parameters = ["user_type" : "trainer",
                          "user_id":TrainerId] as [String : Any]
        
        print("PARAMS",parameters)
        
        CommonMethods.serverCall(APIURL: VIEW_PROFILE, parameters: parameters , onCompletion: { (jsondata) in
            print("PROFILE RESPONSE",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    self.TrainerprofileDictionary = jsondata["data"]  as! NSDictionary
                    print(self.TrainerprofileDictionary)
                    
                    if (self.TrainerprofileDictionary["social_media_links"] as? String) != nil{
                        self.parseSocialMediaLinks(socialMediaLinksArray: (self.TrainerprofileDictionary["social_media_links"] as! String).parseJSONString as! Array<Any>)
                    }
                    
                    self.lblProfileName.text = (self.TrainerprofileDictionary["first_name"] as? String)! + " " + (self.TrainerprofileDictionary["last_name"] as? String)!
                    
                    self.imgProfileImage.sd_setImage(with: URL(string: (self.TrainerprofileDictionary["user_image"] as? String)!), placeholderImage: UIImage(named: "man"))
                    
                    if let age = self.TrainerprofileDictionary["age"] as? String{
                        self.lblTrainerAge.text = "Trainer (\(age))"
                    }else{
                        self.lblTrainerAge.text = "Trainer"
                    }
                    
                    if let height = self.TrainerprofileDictionary["height"] as? String{
                        self.lblTrainerHeight.text = "\(height) cm"
                        self.imgHeightIcon.isHidden = false
                    }else{
                        self.lblTrainerHeight.isHidden = true
                        self.imgHeightIcon.isHidden = true
                    }
                    
                    if let weight = self.TrainerprofileDictionary["weight"] as? String{
                        self.lblTrainerWeight.text = "\(weight) lbs"
                        self.imgWeightIcon.isHidden = false
                    }else{
                        self.lblTrainerWeight.isHidden = true
                        self.imgWeightIcon.isHidden = true
                    }
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    func parseSocialMediaLinks(socialMediaLinksArray: Array<Any>){
        
        print("parseSocialMediaLinks:\(socialMediaLinksArray)")
        print(socialMediaLinksArray[0])
        let dict = (socialMediaLinksArray[0] as! NSDictionary)["social_media_links"] as! NSDictionary
        
        facebookLink = dict["facebook"] as? String ?? ""
        instagramLink = dict["instagram"] as? String ?? ""
        twitterLink = dict["twitter"] as? String ?? ""
        youtubeLink = dict["youtube"] as? String ?? ""
    }
    
    @IBAction func doneAction(_ sender: Any) {
        print("** Done Action **")
        TimerCheck()
    }
    
    //MARK: - PREPARE FOR SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "unwindSegueToRoutePageFromTrainerProfile" {
            print("*** Prepare for segue for SEGUE : unwindSegueToRoutePageFromTrainerProfile ***")
            let timerPage =  segue.destination as! TrainerTraineeRouteViewController
            timerPage.seconds = numOfDays
            timerPage.TIMERCHECK = timerCheckValue
        }else if segue.identifier == "fromAssignedTrainerVCToCategoryVCSegue" {
            let categoryListVC =  segue.destination as! CategoryListVC
//            categoryListVC.FromTrainerProfileBool = true
            categoryListVC.isFromAssignedTrainerVC = true
            categoryListVC.trainerID = TrainerId
//            categoryListVC.assignedTrainerprofileDictionary = self.TrainerprofileDictionary
        }
    }
    
    func TimerCheck(){
        
        print("*** Timer Check in Assigned Trainer Profile View ***")
        if userDefaults.value(forKey: "TimerData") != nil {
            TimerDict = userDefaults.value(forKey: "TimerData") as! NSDictionary
            print("TIMERDICT",TimerDict)
            
            let date = ((TimerDict["currenttime"] as! Date).addingTimeInterval(TimeInterval(TimerDict["TimeRemains"] as! Int)))
            
            print("OLD DATE",date)
            print("CURRENT DATE",Date())
            
            if date > Date(){
                print("ongoing")
                numOfDays = Date().daysBetweenDate(toDate: date)
                print("DIFFERENCE",numOfDays)
                timerCheckValue = true
            }else{
                print("completed")
                
                userDefaults.removeObject(forKey: "TimerData")
                TrainerProfileDetail.deleteBookingDetails()
                timerCheckValue = false
            }
        }
        performSegue(withIdentifier: "unwindSegueToRoutePageFromTrainerProfile", sender: self)
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
            let socialMediaCell: AssignedTrainerSocialMediaCell = tableView.dequeueReusableCell(withIdentifier: "socialMediaCellId") as! AssignedTrainerSocialMediaCell
            
            socialMediaCell.btnFacebook.addTarget(self, action: #selector(AssignedTrainerProfileView.facebookAction(sender:)), for: .touchUpInside)
            socialMediaCell.btnInstagram.addTarget(self, action: #selector(AssignedTrainerProfileView.instagramAction(sender:)), for: .touchUpInside)
            socialMediaCell.btnTwitter.addTarget(self, action: #selector(AssignedTrainerProfileView.twitterAction(sender:)), for: .touchUpInside)
            socialMediaCell.btnYoutube.addTarget(self, action: #selector(AssignedTrainerProfileView.youtubeAction(sender:)), for: .touchUpInside)
            
            return socialMediaCell
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

//MARK: - SOCIAL MEDIA ACTIONS
extension AssignedTrainerProfileView {
    
    func facebookAction(sender : UIButton){
        
//        if let facebook_id = userDefaults.value(forKey: "facebookId") as? String {
//            facebookLink = facebook_id
//        }
        
        if !facebookLink.isEmpty{
            CommonMethods.openFBProfile(facebookUserID: facebookLink)
        }else if facebookLink.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Facebook profile is not linked with the profile", buttonTitle: "OK")
        }
    }
    
    func instagramAction(sender : UIButton){
        
        if !instagramLink.isEmpty{
            CommonMethods.openInstagramProfile(view: self, instagramProfileName: instagramLink)
        }else if instagramLink.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Instagram profile is not linked", buttonTitle: "OK")
        }
    }
    
    func twitterAction(sender : UIButton){
        
        if !twitterLink.isEmpty{
            CommonMethods.openTwitterProfile(view: self, twitterUsername: twitterLink)
        }else if twitterLink.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Twitter profile is not linked", buttonTitle: "OK")
        }
    }
    
    func youtubeAction(sender : UIButton){
        
        if !youtubeLink.isEmpty{
            CommonMethods.openYoutubeLink(view: self, youtubeLink: youtubeLink)
        }else if youtubeLink.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Youtube link not provided", buttonTitle: "OK")
        }
    }
}

extension AssignedTrainerProfileView: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1{
            print("**** Did select Training Category ****")
            self.performSegue(withIdentifier: "fromAssignedTrainerVCToCategoryVCSegue", sender: self)
        }
    }

}


