//
//  ChooseSessionAndGenderVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 03/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import CoreLocation


class ChooseSessionAndGenderVC: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var chooseSessionAndGenderTable: UITableView!
    @IBOutlet weak var btnNext: UIButton!
   
    let headerSectionTitles = ["Choose Session Duration" ,"Choose Trainer Gender"]
    var collapseArray = [Bool]()
    var sessionChoosed = Int()
    var headerChoosed = Int()
    var isChoosedGender = Bool()
    
    var locationManager: CLLocationManager!
    var lat = String()
    var long = String()
    var isFetchedLatAndLong = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sessionChoosed = -1
        headerChoosed = -1
        
        for _ in 0..<headerSectionTitles.count{
            collapseArray.append(false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        choosedSessionOfTrainee = ""
        choosedTrainerGenderOfTrainee = ""
        getCurrentLocationDetails()
    }
    
    @IBAction func nextButtonActions(_ sender: Any) {
        moveToShowTrainersOnMapPage()
    }
    
    func moveToShowTrainersOnMapPage() {
        
        if choosedSessionOfTrainee.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHOOSE_SESSION_DURATION, buttonTitle: "Ok")
        }else if choosedTrainerGenderOfTrainee.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHOOSE_PREFERRED_GENDER, buttonTitle: "Ok")
        }else{
            if !isFetchedLatAndLong{
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: LOCATION_HAS_NOT_FETCH_PLEASE_WAIT, buttonTitle: "OK")
            }else{
                showTrainersList(parameters: getShowTrainersListParameters())
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension ChooseSessionAndGenderVC: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return trainingDurationArray.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let sessionCell: ChooseSessionTableCell = tableView.dequeueReusableCell(withIdentifier: "chooseSessionCellId") as! ChooseSessionTableCell
            
            sessionCell.lblSessionDuration.text = trainingDurationArray[indexPath.row]
            
            if sessionChoosed == indexPath.row{
                sessionCell.backgroundCardView.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            }else{
                sessionCell.backgroundCardView.backgroundColor = .white
            }
            
            return sessionCell
        }else{
            let genderCell: ChooseGenderTableCell = tableView.dequeueReusableCell(withIdentifier: "chooseGenderCellId") as! ChooseGenderTableCell
            
            genderCell.selectionStyle = UITableViewCellSelectionStyle.none
            
            genderCell.btnMale.addShadowView()
            genderCell.btnFemale.addShadowView()
            genderCell.btnNopreferance.addShadowView()
            
            genderCell.btnMale.addTarget(self, action: #selector(ChooseSessionAndGenderVC.choosedGender(sender:)), for: .touchUpInside)
            genderCell.btnFemale.addTarget(self, action: #selector(ChooseSessionAndGenderVC.choosedGender(sender:)), for: .touchUpInside)
            genderCell.btnNopreferance.addTarget(self, action: #selector(ChooseSessionAndGenderVC.choosedGender(sender:)), for: .touchUpInside)

            return genderCell
        }
    }
    
    func choosedGender(sender : UIButton){
        print("Button Tapped 123")
        
        isChoosedGender = true
        if !choosedSessionOfTrainee.isEmpty{
            btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        }else{
            btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: DARK_GRAY_COLOR)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell: SectionHeaderCell = tableView.dequeueReusableCell(withIdentifier: "sectionHeaderCellId") as! SectionHeaderCell
        
        cell.lblHeaderSectionTitle.text = headerSectionTitles[section]
        
        if headerChoosed == -1{
            print("Init")
            cell.imgArrow.image = UIImage(named: "rightArrow")
        }else if collapseArray[headerChoosed]{
            cell.imgArrow.image = UIImage(named: "downArrow")
        }else{
            cell.imgArrow.image = UIImage(named: "rightArrow")
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapSectionHeader(_:)))
        cell.contentView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        tapGesture.view?.tag = section
        
        return cell.contentView
    }
    
    func didTapSectionHeader(_ sender: UITapGestureRecognizer) {
        print("Please Help!")
        
        let indexpath: IndexPath = IndexPath.init(row: 0, section: (sender.view?.tag)!)
        print("Tapped Index:",indexpath.section)
        
        headerChoosed = (sender.view?.tag)!
        let collapsed = collapseArray[indexpath.section]
        collapseArray[indexpath.section] = !collapsed
        self.chooseSessionAndGenderTable.reloadSections(IndexSet(integer: sender.view!.tag), with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if collapseArray[indexPath.section]{
            if indexPath.section == 0{
              return 60
            }else{
                return 114
            }
        }else{
            return 0
        }
    }
    
    func getCurrentLocationDetails() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func showTrainersList(parameters: Dictionary <String,Any>) {
        
        let headers = [
            "token":appDelegate.Usertoken]
        
        print("Header:\(headers)")
        print("Params:\(parameters)")
        
        CommonMethods.serverCall(APIURL: SEARCH_TRAINER, parameters: parameters, headers: headers, onCompletion: { (jsondata) in
            
            print("*** Search Trainer Listing Result:",jsondata)
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    print(jsondata)
                    
                    let trainersFoundArray = jsondata["data"]  as! NSArray
                    if trainersFoundArray.count > 0 {
                        self.performSegue(withIdentifier: "afterChoosingSessionAndGenderSegue", sender: self)
                    }else{
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "No Trainers Found", buttonTitle: "OK")
                    }
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
}

extension ChooseSessionAndGenderVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        sessionChoosed = indexPath.row
        chooseSessionAndGenderTable.reloadSections(IndexSet(integer: 0), with: .automatic)
        
        if indexPath.section == 0{
            if indexPath.row == 0 {
                choosedSessionOfTrainee = "40"
            }else{
                choosedSessionOfTrainee = "60"
            }
        }
        print("Choosed Session:\(choosedSessionOfTrainee)")
        userDefaults.set(choosedSessionOfTrainee, forKey: "backupTrainingSessionChoosed")
        
        if !choosedSessionOfTrainee.isEmpty && isChoosedGender {
            btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        }else{
            btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: DARK_GRAY_COLOR)
        }
    }
}

extension ChooseSessionAndGenderVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            
            print("**********************")
            print("Long \(location.coordinate.longitude)")
            print("Lati \(location.coordinate.latitude)")
            print("Alt \(location.altitude)")
            print("Sped \(location.speed)")
            print("Accu \(location.horizontalAccuracy)")
            
            print("**********************")
            
            lat = String(location.coordinate.latitude)
            long = String(location.coordinate.longitude)
            isFetchedLatAndLong = true
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func getShowTrainersListParameters() -> Dictionary <String,Any> {
        
        let parameters = ["user_id" : appDelegate.UserId,
                          "gender" : choosedTrainerGenderOfTrainee,
                          "category" : choosedCategoryOfTrainee.categoryId,
                          "latitude" : lat,
                          "longitude" : long
            ] as [String : Any]
        
        return parameters
    }
}



