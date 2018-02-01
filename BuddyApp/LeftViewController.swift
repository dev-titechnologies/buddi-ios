//
//  LeftViewController.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 19/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import SideMenu
import QuartzCore

class LeftViewController: UIViewController {
    @IBOutlet weak var profileimage: UIImageView!
    @IBOutlet weak var leftMenuTableview: UITableView!
    
    var imageArray = Array<ProfileImageDB>()
    var objdata = NSData()
    var leftMenuArrayTraineeCopy = [String]()
    var isTraineeAlreadyTrainer = Bool()
    var TimerDict = NSDictionary()
    var numOfDays = Int()

    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var lblEmailId: UILabel!
    var isTimerStarted = Bool()
    
    @IBOutlet weak var lblWalletAmount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SideMenuManager.menuAnimationBackgroundColor = .clear
        
        if let isTraineeAlreadyTrainerHasValue = userDefaults.value(forKey: "ifAlreadyTrainer") as? Bool {
            isTraineeAlreadyTrainer = isTraineeAlreadyTrainerHasValue
        }
        
        if isTraineeAlreadyTrainer {
            leftMenuArrayTraineeCopy = leftMenuTraineeAndTrainerAlso
        }else{
            leftMenuArrayTraineeCopy = leftMenuTrainee
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

        print("**** Left view viewWillAppear")
        parseNameAndImage()
        
        if let walletBalance = userDefaults.value(forKey: "walletBalance"){
            lblWalletAmount.text = "$ \(String(describing: walletBalance))"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("**** Left view viewDidAppear")
    }
        
    func parseNameAndImage() {
        
        print("**** parseNameAndImage ****")
        profileName.text = userDefaults.value(forKey: "userName") as? String
        lblEmailId.text = userDefaults.value(forKey: "userEmailId") as? String
        
        //Load profile image from NSData which is stored when login/register time
        if appDelegate.profileImageData.length != 0 {
            self.profileimage.image = UIImage(data: appDelegate.profileImageData as Data)
        }
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            if let imagearray = ProfileImageDB.fetchImage() {
                self.imageArray = imagearray as! Array<ProfileImageDB>
                
                guard self.imageArray.count > 0 else{
                    return
                }
                self.objdata = self.imageArray[0].value(forKey: "imageData") as! NSData
                DispatchQueue.main.async {
                    print("Left ViewController Image Data to imageview")
                    self.profileimage.image = UIImage(data: self.objdata as Data)
                }
            }
        }
    }
    
    func TimerCheck(){
        
        print("** TimerCheck function call in LeftViewController **")
        if userDefaults.value(forKey: "TimerData") != nil {
            TimerDict = userDefaults.value(forKey: "TimerData") as! NSDictionary
            print("TIMERDICT",TimerDict)
            
            let date = ((TimerDict["currenttime"] as! Date).addingTimeInterval(TimeInterval(TimerDict["TimeRemains"] as! Int)))
            
            print("Expected time for session completion:",date)
            print("Current date and time:",Date())
            
            if date > Date(){
                print("Session is Ongoing")
                numOfDays = Date().daysBetweenDate(toDate: date)
                
                print("Time difference:",numOfDays)
                isTimerStarted = true
                self.performSegue(withIdentifier: "leftmenutotimerview", sender: self)
                
            }else{
                print("Session completed")
                userDefaults.removeObject(forKey: "TimerData")
                TrainerProfileDetail.deleteBookingDetails()
            }
        }
    }
    
    //MARK: - PREPARE FOR SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "blankPageSegue" {
            let path = leftMenuTableview.indexPathForSelectedRow!

            let blankPage =  segue.destination as! BlankViewController
            if appDelegate.USER_TYPE == "trainer"{
                blankPage.blankTextValue = leftMenuTrainer[path.row]
            }else{
                if isTraineeAlreadyTrainer {
                    blankPage.blankTextValue = leftMenuTraineeAndTrainerAlso[path.row]
                }else{
                    blankPage.blankTextValue = leftMenuTrainee[path.row]
                }
            }
        }else if segue.identifier == "leftmenutotimerview" {
            
            let timerPage =  segue.destination as! TrainerTraineeRouteViewController

            if !isTimerStarted{
                print("**** Timer not started ****")
                if let trainerProfileDictData = userDefaults.value(forKey: "TrainerProfileDictionary") as? NSData {
                    let trainerProfileDict = NSKeyedUnarchiver.unarchiveObject(with: trainerProfileDictData as Data) as! NSDictionary
                    print("trainerProfileDict:\(trainerProfileDict)")
                    
                    if appDelegate.USER_TYPE == "trainer"{
                        timerPage.TrainerProfileDictionary = trainerProfileDict
                    }else{
                        let trainerProfileModelObj = TrainerProfileModal()
                        var trainerProfileModel = TrainerProfileModal()
                        trainerProfileModel = trainerProfileModelObj.getTrainerProfileModelFromDict(dictionary: trainerProfileDict as! Dictionary<String, Any>)

                        timerPage.trainerProfileDetails = trainerProfileModel
                    }
                    timerPage.seconds = Int(trainerProfileDict["training_time"] as! String)!*60
                    print("SECONDSSSS",timerPage.seconds)
                }
            }else{
                print("**** Timer started ****")
                print("******** Timer Check Value is setting as True\(numOfDays) ******")
                timerPage.seconds = numOfDays
                timerPage.TIMERCHECK = true
            }
        }else if segue.identifier == "fromlefttocatgory" {
            let addCategory =  segue.destination as! CategoryListVC
            addCategory.isFromAddCategoryVC = true
        }
    }
    
    @IBAction func viewProfileButtonAction(_ sender: Any) {
        
        if appDelegate.USER_TYPE == "trainer"{
            self.performSegue(withIdentifier: "trainerProfileSegue", sender: self)
        }else{
            self.performSegue(withIdentifier: "traineeProfileSegue", sender: self)
        }
    }
    
    func logoutAlert() {
        
        let alert = UIAlertController(title: ALERT_TITLE, message: ARE_YOU_SURE_WANT_TO_LOGOUT, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            
            self.LogOutAPI()
        }))
        alert.addAction(UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: { action in
            
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func currentlyInSessionAlert() {
        
        let alert = UIAlertController(title: ALERT_TITLE, message: YOU_ARE_CURRENTLY_IN_SESSION, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in

            if appDelegate.timerrunningtime{
                self.TimerCheck()
            }else if userDefaults.bool(forKey: "sessionBookedNotStarted") {
                self.isTimerStarted = false
                self.performSegue(withIdentifier: "leftmenutotimerview", sender: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func LogOutAPI(){
        
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
        let headers = [
            "device_id": appDelegate.DeviceToken,
            "device_imei": UIDevice.current.identifierForVendor!.uuidString,
            "device_type": "ios",
            "token":appDelegate.Usertoken
            ]
        
        print("Header:",headers)
        
        CommonMethods.showProgress()
        CommonMethods.serverCallCopy(APIURL: "login/logout", parameters: ["":""], headers: headers , onCompletion: { (jsondata) in
            print("LOGOUT RESPONSE",jsondata)
            
            CommonMethods.hideProgress()
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    self.dismissOnSessionExpire()
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "OK")
                    
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }else{
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: REQUEST_TIMED_OUT, buttonTitle: "OK")
            }
        })
    }
}

extension LeftViewController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if appDelegate.USER_TYPE == "trainer"{
            return leftMenuTrainer.count
        }else{
            return leftMenuArrayTraineeCopy.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: LeftMenuTableCell = tableView.dequeueReusableCell(withIdentifier: "leftMenuCellId") as! LeftMenuTableCell
        
        if indexPath.row == 3{
            cell.walletamount_lbl.isHidden = false
            cell.walletamount_lbl.textColor = UIColor.white
            cell.walletamount_lbl.textAlignment = .center
            cell.walletamount_lbl.layer.masksToBounds = true
            cell.walletamount_lbl.layer.cornerRadius = 10.0
            cell.walletamount_lbl.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
           // cell.walletamount_lbl.text = "$ 450000"
            if let walletBalance = userDefaults.value(forKey: "walletBalance"){
                cell.walletamount_lbl.text = "\(CommonMethods.showWalletAmountInFloat(amount: String(describing: walletBalance)))  "
            }
            cell.walletamount_lbl.sizeToFit()
        }else{
            cell.walletamount_lbl.isHidden = true
        }
        if appDelegate.USER_TYPE == "trainer" {
            //For Trainer
            cell.lblLeftMenuTitle.text = leftMenuTrainer[indexPath.row]
            cell.icon_img.image = UIImage(named: ImageArrayTrainer[indexPath.row])
        }else{
            //For Trainee
            if isTraineeAlreadyTrainer{
                cell.lblLeftMenuTitle.text = leftMenuTraineeAndTrainerAlso[indexPath.row]
                cell.icon_img.image = UIImage(named: ImageArrayTraineeAndTrainerAlso[indexPath.row])
            }else{
                cell.lblLeftMenuTitle.text = leftMenuArrayTraineeCopy[indexPath.row]
                cell.icon_img.image = UIImage(named: ImageArrayTrainee[indexPath.row])
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1{
            
            if appDelegate.USER_TYPE == USER_TYPE.TRAINEE {
                return 50
            }else {
                return 0
            }
        }else{
            return 50
        }
    }
}

extension LeftViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if appDelegate.USER_TYPE == "trainer"{

            switch (indexPath.row) {
            case 0:
                print("Zero")
                print("Home")
                
                if appDelegate.timerrunningtime{
                    TimerCheck()
                }else if userDefaults.bool(forKey: "sessionBookedNotStarted") {
                    isTimerStarted = false
                    self.performSegue(withIdentifier: "leftmenutotimerview", sender: self)
                }else{
                    self.performSegue(withIdentifier: "trainerProfileSegue", sender: self)
                }
                
            case 1:
                print("One")
                print("Settings")
                self.performSegue(withIdentifier: "fromLeftMenuToSettingsPageSegue", sender: self)
                
            case 2:
                print("Two")
                print("Payment Method")
                self.performSegue(withIdentifier: "addPaymentMethodSegue", sender: self)
                
            case 3:
                print("Three")
                print("Wallet System")
                self.performSegue(withIdentifier: "walletSystemSegue", sender: self)
                
            case 4:
                print("Four")
                print("Add Category")
                
                if appDelegate.timerrunningtime{
                    TimerCheck()
                }else{
                    self.performSegue(withIdentifier: "fromlefttocatgory", sender: self)
                }
                
            case 5:
                print("Five")
                print("Training History")
                self.performSegue(withIdentifier: "bookingHistorySegue", sender: self)
                
            case 6:
                print("Six")
                print("Invite Friends")
                self.performSegue(withIdentifier: "fromLeftMenuToInviteFriendsSegue", sender: self)
               
            case 7:
                print("Seven")
                print("Help")
                self.performSegue(withIdentifier: "leftMenuToHelpPageSegue", sender: self)
                
            case 8:
                print("Eight")
                print("Legal")
                self.performSegue(withIdentifier: "leftMenuToLegalPageSegue", sender: self)
                
            case 9:
                print("Nine")
                print("Logout")
                if userDefaults.bool(forKey: "isCurrentlyInTrainingSession") {
                    currentlyInSessionAlert()
                }else{
                    logoutAlert()
                }
            default:
                print("Integer out of range")
            }
        }else{
            //For Trainee
                        
            switch (indexPath.row)
            {
            case 0:
                print("zero")
                print("Home")
                
                if appDelegate.timerrunningtime {
                    TimerCheck()
                }else if userDefaults.bool(forKey: "sessionBookedNotStarted") {
                    isTimerStarted = false
                    self.performSegue(withIdentifier: "leftmenutotimerview", sender: self)
                }else{
                   self.performSegue(withIdentifier: "leftMenuToTraineeHomeSegue", sender: self)
                }
                
            case 1:
                print("one")
                print("Settings")
                self.performSegue(withIdentifier: "fromLeftMenuToSettingsPageSegue", sender: self)
                
            case 2:
                print("two")
                print("Payment Method")
                self.performSegue(withIdentifier: "addPaymentMethodSegue", sender: self)
                
            case 3:
                print("three")
                print("Wallet System")
                self.performSegue(withIdentifier: "walletSystemSegue", sender: self)
                
            case 4:
                print("four")
                
                if isTraineeAlreadyTrainer{
                    //Already a Trainer
                    print("Training History")
                    self.performSegue(withIdentifier: "bookingHistorySegue", sender: self)
                }else{
                    print("Become a Trainer")
                    self.performSegue(withIdentifier: "fromlefttocatgory", sender: self)
                }
                
            case 5:
                print("five")
                if isTraineeAlreadyTrainer{
                    print("Invite Friends")
                    self.performSegue(withIdentifier: "fromLeftMenuToInviteFriendsSegue", sender: self)
                }else{
                    print("Training History")
                    self.performSegue(withIdentifier: "bookingHistorySegue", sender: self)
                }
                
            case 6:
                print("six")
                if isTraineeAlreadyTrainer{
                    print("Help")
                    self.performSegue(withIdentifier: "leftMenuToHelpPageSegue", sender: self)
                }else{
                    print("Invite Friends")
                    self.performSegue(withIdentifier: "fromLeftMenuToInviteFriendsSegue", sender: self)
                }
                
            case 7:
                print("seven")
                if isTraineeAlreadyTrainer{
                    print("Legal")
                    self.performSegue(withIdentifier: "leftMenuToLegalPageSegue", sender: self)
                }else{
                    print("Help")
                    self.performSegue(withIdentifier: "leftMenuToHelpPageSegue", sender: self)
                }

            case 8:
                print("eight")
                if isTraineeAlreadyTrainer{
                    print("Logout")
                    if userDefaults.bool(forKey: "isCurrentlyInTrainingSession") {
                        currentlyInSessionAlert()
                    }else{
                        logoutAlert()
                    }
                }else{
                    print("Legal")
                    self.performSegue(withIdentifier: "leftMenuToLegalPageSegue", sender: self)
                }
                
            case 9:
                print("nine")
                if isTraineeAlreadyTrainer{
                    
                }else{
                    print("Logout")
                    if userDefaults.bool(forKey: "isCurrentlyInTrainingSession") {
                        currentlyInSessionAlert()
                    }else{
                        logoutAlert()
                    }
                }
                
            default:
                print("Integer out of range")
            }
        }
    }
}


