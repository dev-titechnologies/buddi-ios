//
//  ChooseSessionAndGenderVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 03/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import GoogleMaps
import GooglePlacePicker

class ChooseSessionAndGenderVC: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var chooseSessionAndGenderTable: UITableView!
    @IBOutlet weak var btnNext: UIButton!
   
    let headerSectionTitles = ["Choose Session Duration" ,"Choose Trainer Gender","Choose Location"]
    var collapseArray = [Bool]()
    var sessionChoosed = Int()
    var headerChoosed = Int()
    
    var isChoosedSessionDuration = Bool()
    var isChoosedGender = Bool()
    var isChoosedLocation = Bool()

    var locationManager: CLLocationManager!
    var lat = String()
    var long = String()
    var isLocationAccessAllowed = Bool()
    
    //Selected Preference Values
    var choosed_session_duration = String()
    var choosed_trainer_gender = String()
    var choosed_location_name = String()
    
    var trainingLocationModelObj = TrainingLocationModel()
    
//MARK: - VIEW CYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = PAGE_TITLE.CHOOSE_SESSION_AND_GENDER
        
        sessionChoosed = -1
        headerChoosed = -1
        
        for _ in 0..<headerSectionTitles.count{
            collapseArray.append(false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getCurrentLocationDetails()
    }
    
    //MARK: - OTHER FUNCTIONS 
    
    @IBAction func nextButtonActions(_ sender: Any) {
        moveToShowTrainersOnMapPage()
    }
        
    func moveToShowTrainersOnMapPage() {
        
        if choosedSessionOfTrainee.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHOOSE_SESSION_DURATION, buttonTitle: "Ok")
        }else if choosedTrainerGenderOfTrainee.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHOOSE_PREFERRED_GENDER, buttonTitle: "Ok")
        }else if choosed_location_name.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHOOSE_PREFERRED_LOCATION, buttonTitle: "Ok")
        }else{
            if isLocationAccessAllowed{
                
                //This userdefault value will be used to check the previous booking from when reopening the app.
                //1 . Instant Booking - instantBooking, 2. Usual Booking Request - usualBooking
                userDefaults.set("usualBooking", forKey: "previousBookingRequestVia")

                showTrainersList(parameters: getShowTrainersListParameters())
            }else{
                openDeviceSettingsForLocationAccess()
            }
        }
    }
    
    func openDeviceSettingsForLocationAccess() {
        
        let alertController = UIAlertController (title: ALERT_TITLE, message: PLEASE_ALLOW_LOCATION_ACCESS, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
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
    
    func getShowTrainersListParameters() -> Dictionary <String,Any> {
        
        let parameters = ["user_id" : appDelegate.UserId,
                          "gender" : choosedTrainerGenderOfTrainee,
                          "category" : choosedCategoryOfTrainee.categoryId,
                          "latitude" : lat,
                          "longitude" : long
            ] as [String : Any]
        
        //Add below two parameters for training preferred location
        
        return parameters
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "afterChoosingSessionAndGenderSegue" {
            let showTrainersOnMapObj =  segue.destination as! ShowTrainersOnMapVC
            showTrainersOnMapObj.trainingLocationModelObject = trainingLocationModelObj
        }
    }
    
    func GooglePlacePicker(){
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
}

//MARK: - TABLEVIEW DATASOURCE
extension ChooseSessionAndGenderVC: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return trainingDurationArray.count
        }else if section == 1{
            return 1
        }else {
            return 0
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
            
            genderCell.btnMale.tag = 1
            genderCell.btnFemale.tag = 2
            genderCell.btnNopreferance.tag = 3
            
            genderCell.btnMale.addTarget(self, action: #selector(ChooseSessionAndGenderVC.choosedGender(sender:)), for: .touchUpInside)
            genderCell.btnFemale.addTarget(self, action: #selector(ChooseSessionAndGenderVC.choosedGender(sender:)), for: .touchUpInside)
            genderCell.btnNopreferance.addTarget(self, action: #selector(ChooseSessionAndGenderVC.choosedGender(sender:)), for: .touchUpInside)
            
            switch choosed_trainer_gender {
            case "Male":
                genderCell.btnMale.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
                genderCell.btnFemale.backgroundColor = .white
                genderCell.btnNopreferance.backgroundColor = .white
           
            case "Female":
                genderCell.btnMale.backgroundColor = .white
                genderCell.btnFemale.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
                genderCell.btnNopreferance.backgroundColor = .white

            case "No Preference":
                genderCell.btnMale.backgroundColor = .white
                genderCell.btnFemale.backgroundColor = .white
                genderCell.btnNopreferance.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)

            default:
                print("Default case in gender color")
            }

            return genderCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 85
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
    
//MARK: - TABLEVIEW HEADER SECTION VIEW
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
        
        switch section {
        case 0:
            cell.lblSelectedValue.text = choosed_session_duration
        case 1:
            cell.lblSelectedValue.text = choosed_trainer_gender
        case 2:
            cell.lblSelectedValue.text = choosed_location_name
            
        default:
            print("View for sectionheader Default Case catched")
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapSectionHeader(_:)))
        cell.contentView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        tapGesture.view?.tag = section
        
        return cell.contentView
    }
    
    func choosedGender(sender : UIButton){
        print("Button Tapped 123")
        
        switch sender.tag {
        case 1:
            choosed_trainer_gender = "Male"
            choosedTrainerGenderOfTrainee = "male"
        case 2:
            choosed_trainer_gender = "Female"
            choosedTrainerGenderOfTrainee = "female"
        case 3:
            choosed_trainer_gender = "No Preference"
            choosedTrainerGenderOfTrainee = "nopreference"

        default:
            print("Gender Default Case catched")
        }
        
        userDefaults.set(choosedTrainerGenderOfTrainee, forKey: "backupTrainingGenderChoosed")
        
        isChoosedGender = true
        if isChoosedSessionDuration && isChoosedLocation {
            btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        }else{
            btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: DARK_GRAY_COLOR)
        }
        
        let indexPath1 = IndexPath(row: 0, section: 1)
        self.chooseSessionAndGenderTable.reloadSections(IndexSet(integer: 1), with: .automatic)
        self.chooseSessionAndGenderTable.reloadRows(at: [indexPath1], with: .automatic)
    }

    func didTapSectionHeader(_ sender: UITapGestureRecognizer) {
        print("Please Help!")
        
        let indexpath: IndexPath = IndexPath.init(row: 0, section: (sender.view?.tag)!)
        print("Tapped Index:",indexpath.section)
        
        if indexpath.section == 0 || indexpath.section == 1 {
            print("*** Tapped on Section 1 & 2")
            headerChoosed = (sender.view?.tag)!
            let collapsed = collapseArray[indexpath.section]
            collapseArray[indexpath.section] = !collapsed
            self.chooseSessionAndGenderTable.reloadSections(IndexSet(integer: sender.view!.tag), with: .automatic)
        }else{
            print("*** Tapped on Section 3")
            GooglePlacePicker()
        }
    }
}

//MARK: TABLEVIEW DELEGATE

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
        
            isChoosedSessionDuration = true
            choosed_session_duration = trainingDurationArray[indexPath.row]
        }
        print("Choosed Session:\(choosedSessionOfTrainee)")
        userDefaults.set(choosedSessionOfTrainee, forKey: "backupTrainingSessionChoosed")
        
        if isChoosedSessionDuration && isChoosedGender && isChoosedLocation{
            btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        }else{
            btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: DARK_GRAY_COLOR)
        }
        
        self.chooseSessionAndGenderTable.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }
}

//MARK: - LOCATION MANAGER DELEGATE
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
//            isFetchedLatAndLong = true
            //self.locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print("*** didChangeAuthorization: \(status.rawValue)")
       
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            isLocationAccessAllowed = true
        }else{
            isLocationAccessAllowed = false
        }
    }
}

extension ChooseSessionAndGenderVC: GMSPlacePickerViewControllerDelegate {
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        
        print("Place name \(place.name)")
        print("STATUS",place.openNowStatus.rawValue)
        
        trainingLocationModelObj.locationName = place.name
        trainingLocationModelObj.locationLatitude = String(place.coordinate.latitude)
        trainingLocationModelObj.locationLongitude = String(place.coordinate.longitude)
        
        userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: CommonMethods.getDictionaryFromTrainingLocationModel(training_location_model: trainingLocationModelObj)), forKey: "TrainingLocationModelBackup")

        isChoosedLocation = true
        
        if isChoosedSessionDuration && isChoosedGender {
            btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
        }else{
            btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: DARK_GRAY_COLOR)
        }

        choosed_location_name = place.name
        self.chooseSessionAndGenderTable.reloadSections(IndexSet(integer: 2), with: .automatic)
    }
        
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
}




