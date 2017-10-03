//
//  SettingsPageVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 24/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import GooglePlacePicker

class SettingsPageVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var settingsTableView: UITableView!
    let headerSectionTitles = ["Location Preference" ,"Training Category Preference", "Gender Preference", "Session Length Preference"]
    let sessionTime = ["40","60"]
    var collapseArray = [Bool]()
    var sessionChoosed = Int()
    var headerChoosed = Int()
    var isChoosedGender = Bool()
    var locationcordinate = CLLocationCoordinate2D()
    var dict = NSMutableDictionary()
    var sessionCell = SessionPreferenceCell()
    var preferanceBool = Bool()
    var preferenceValuesDict = NSDictionary()
    
    var locationLatitude = String()
    var locationLongitude = String()
    
    var choosed_session_duration = String()

    var trainingLocationModelObj = TrainingLocationModel()
    var preferenceModelObj = PreferenceModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferanceBool = false

        self.title = PAGE_TITLE.SETTINGS
        
        sessionChoosed = -1
        headerChoosed = -1

        for _ in 0..<headerSectionTitles.count{
            collapseArray.append(false)
        }
        
        getPreferenceModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("Settings Page ViewWillAppear")
        self.settingsTableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }

    func getPreferenceModel() {
        
        if userDefaults.value(forKey: "save_preferance") as? NSDictionary != nil{
            let dict = userDefaults.value(forKey: "save_preferance") as? NSDictionary
            preferenceModelObj = getPreferenceObjectFromDictionary(dictionary: dict!)
        }
    }
    
    func getPreferenceObjectFromDictionary(dictionary: NSDictionary) -> PreferenceModel {
        
        let preference_obj = PreferenceModel()
        
        preference_obj.categoryId = dictionary["categoryid"] as! String
        preference_obj.gender = dictionary["gender"] as! String
        preference_obj.sessionDuration = dictionary["time"] as! String
        preference_obj.locationName = dictionary["locationName"] as! String
        preference_obj.locationLattitude = dictionary["lat"] as! String
        preference_obj.locationLongitude = dictionary["long"] as! String
        preference_obj.categoryName = dictionary["categoryName"] as! String
        
        choosedTrainerGenderOfTraineePreference = preference_obj.gender
        choosedSessionOfTraineePreference = preference_obj.sessionDuration
        choosedCategoryOfTraineePreference.categoryId = preference_obj.categoryId
        choosedCategoryOfTraineePreference.categoryName = preference_obj.categoryName
        choosedTrainingLocationPreference = preference_obj.locationName
        choosed_session_duration = preference_obj.sessionDuration
        
        locationLatitude = preference_obj.locationLattitude
        locationLongitude = preference_obj.locationLongitude
        
        return preference_obj
    }
    
    //MARK: - SAVE ACTION
    
    @IBAction func Save_action(_ sender: Any) {
        
        if choosedTrainingLocationPreference.isEmpty {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please select location", buttonTitle: "Ok")
        }else if choosedCategoryOfTraineePreference.categoryId.isEmpty {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please choose category", buttonTitle: "Ok")
        }else if choosedTrainerGenderOfTraineePreference.isEmpty {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please select gender", buttonTitle: "Ok")
        }else if choosedSessionOfTraineePreference.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please choose session time", buttonTitle: "Ok")
        }else{
            preferanceBool = false
            print("GENDER",choosedTrainerGenderOfTraineePreference)
            print("TIME",choosedSessionOfTraineePreference)
            print("CATEGORY",choosedCategoryOfTraineePreference.categoryId)
            print("location",choosedTrainingLocationPreference)
            
            dict.setValue(choosedTrainerGenderOfTraineePreference, forKey: "gender")
            dict.setValue(choosedSessionOfTraineePreference, forKey: "time")
            dict.setValue(String(choosedCategoryOfTraineePreference.categoryId), forKey: "categoryid")
            dict.setValue(String(choosedCategoryOfTraineePreference.categoryName), forKey: "categoryName")
            dict.setValue(locationLatitude, forKey: "lat")
            dict.setValue(locationLongitude, forKey: "long")
            dict.setValue(choosedTrainingLocationPreference, forKey: "locationName")
            
            print("Save preference Settings dict:\(dict)")

            userDefaults.setValue(dict, forKey: "save_preferance")
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Saved successfully", buttonTitle: "Ok")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingtocatagorylist" {
            let chooseCategoryPage =  segue.destination as! TraineeHomePage
            chooseCategoryPage.isFromSettings = true
        }
    }
    
    func GooglePlacePicker(){
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
}

extension SettingsPageVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 2{
            return 1
        }else if section == 3{
            return trainingDurationArray.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("Indexpath:\(indexPath.row)")
        if indexPath.section == 3{
            //Preferred Session
            sessionCell = tableView.dequeueReusableCell(withIdentifier: "chooseSessionCellId") as! SessionPreferenceCell
            
            sessionCell.lblSessionDuration.text = trainingDurationArray[indexPath.row]
            
            // PREFERENCE SHOWN
            if preferenceModelObj.sessionDuration != "" {
                print("preferenceModelObj.sessionDuration:\(preferenceModelObj.sessionDuration)")
                let session_split = preferenceModelObj.sessionDuration.components(separatedBy: " ") as Array
                print("session_split:\(session_split)")
                let session_duration = self.sessionTime.index(of: session_split[0])
                //let session_duration = session_split[0]
                print("Session Duration:\(String(describing: session_duration))")
                if !preferanceBool{
                    sessionChoosed = Int(session_duration!)
                }
            }
            
            if sessionChoosed == indexPath.row{
                sessionCell.backgroundCardView.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            }else{
                sessionCell.backgroundCardView.backgroundColor = .white
            }
            
            return sessionCell
        }else if indexPath.section == 2{
            //Preferred Gender
            
            let genderCell: GenderPreferenceCell = tableView.dequeueReusableCell(withIdentifier: "chooseGenderCellId") as! GenderPreferenceCell
            
            genderCell.selectionStyle = UITableViewCellSelectionStyle.none
            
            genderCell.btnMale.addShadowView()
            genderCell.btnFemale.addShadowView()
            genderCell.btnNopreferance.addShadowView()
            
            genderCell.btnMale.tag = 1
            genderCell.btnFemale.tag = 2
            genderCell.btnNopreferance.tag = 3
            
            switch choosedTrainerGenderOfTraineePreference {
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
            
            genderCell.btnMale.addTarget(self, action: #selector(ChooseSessionAndGenderVC.choosedGender(sender:)), for: .touchUpInside)
            genderCell.btnFemale.addTarget(self, action: #selector(ChooseSessionAndGenderVC.choosedGender(sender:)), for: .touchUpInside)
            genderCell.btnNopreferance.addTarget(self, action: #selector(ChooseSessionAndGenderVC.choosedGender(sender:)), for: .touchUpInside)
            
            return genderCell
        }else{
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellid")!
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if collapseArray[indexPath.section]{
            if indexPath.section == 3{
                return 60
            }else if indexPath.section == 2{
                return 114
            }else{
                return 0
            }
        }else{
            return 0
        }
    }
    
    func choosedGender(sender : UIButton){
        print("Choose gender Action")
        
        print("Button Tapped 123")
        
        switch sender.tag {
        case 1:
            choosedTrainerGenderOfTraineePreference = "Male"
        case 2:
            choosedTrainerGenderOfTraineePreference = "Female"
        case 3:
            choosedTrainerGenderOfTraineePreference = "No Preference"
            
        default:
            print("Gender Default Case catched")
        }

        self.settingsTableView.reloadSections(IndexSet(integer: 2), with: .automatic)
    }
    
    //MARK: - TABLEVIEW HEADER SECTION VIEW
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell: PreferenceSectionHeader = tableView.dequeueReusableCell(withIdentifier: "sectionHeaderCellId") as! PreferenceSectionHeader
        
        cell.lblHeaderSectionTitle.text = headerSectionTitles[section]
        
        if headerChoosed == -1{
            print("Init")
            cell.imgArrow.image = UIImage(named: "rightArrow")
        }else if collapseArray[headerChoosed] {
            cell.imgArrow.image = UIImage(named: "downArrow")
        }else{
            cell.imgArrow.image = UIImage(named: "rightArrow")
        }
        
        switch section {
        case 0:
            //Location
            print("**** choosedTrainingLocationPreference:\(choosedTrainingLocationPreference)")
            cell.lblSelectedValue.text = choosedTrainingLocationPreference
        case 1:
            //Category
            print("**** choosedCategoryOfTraineePreference categoryName:\(choosedCategoryOfTraineePreference.categoryName)")
            cell.lblSelectedValue.text = choosedCategoryOfTraineePreference.categoryName
        case 2:
            //Gender
            print("**** choosedTrainerGenderOfTraineePreference:\(choosedTrainerGenderOfTraineePreference)")
            cell.lblSelectedValue.text = choosedTrainerGenderOfTraineePreference
        case 3:
            //Session
            print("**** choosed_session_duration:\(choosed_session_duration)")
            if choosed_session_duration == "40" {
                cell.lblSelectedValue.text = "40 Minutes"
            }else if choosed_session_duration == "60" {
                cell.lblSelectedValue.text = "1 Hour"
            }
            
        default:
            print("View for sectionheader Default Case catched")
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapSectionHeader(_:)))
        cell.contentView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        tapGesture.view?.tag = section
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        preferanceBool = true
        sessionChoosed = indexPath.row
//        settingsTableView.reloadSections(IndexSet(integer: 3), with: .automatic)
        
        if indexPath.section == 2{
            print("*** didSelectRowAt: section 2")
            self.settingsTableView.reloadSections(IndexSet(integer: 2), with: .automatic)
        }else if indexPath.section == 3{
            print("*** didSelectRowAt: section 3")
            if indexPath.row == 0 {
                choosedSessionOfTraineePreference = "40"
            }else{
                choosedSessionOfTraineePreference = "60"
            }
            choosed_session_duration = choosedSessionOfTraineePreference
            self.settingsTableView.reloadSections(IndexSet(integer: 3), with: .automatic)
        }
      
        print("Choosed Session:\(choosedSessionOfTraineePreference)")
    }
    
    func didTapSectionHeader(_ sender: UITapGestureRecognizer) {
        print("Please Help!")
        
        let indexpath: IndexPath = IndexPath.init(row: 0, section: (sender.view?.tag)!)
        print("Tapped Index:",indexpath.section)
        
        headerChoosed = (sender.view?.tag)!
        let collapsed = collapseArray[indexpath.section]
        if indexpath.section == 2 || indexpath.section == 3 {
            self.collapseArray[indexpath.section] = !collapsed
            self.settingsTableView.reloadSections(IndexSet(integer: indexpath.section), with: .automatic)

        }else if indexpath.section == 1{
           self.performSegue(withIdentifier: "settingtocatagorylist", sender: self)
        }else{
            self.GooglePlacePicker()
        }
    }
}

extension SettingsPageVC: GMSPlacePickerViewControllerDelegate {
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        guard String(place.coordinate.latitude) != "0.0" else {
            print("Gurad case as no location has been selected")
            return
        }
        
        self.locationcordinate = place.coordinate
        
        print("****** Location Details from Preference Settings ******")
        print("Place name \(place.name)")
        print("coordinate.latitude \(String(place.coordinate.latitude))")
        print("coordinate.longitude \(String(place.coordinate.longitude))")
        
        locationLatitude = String(place.coordinate.latitude)
        locationLongitude = String(place.coordinate.longitude)
        
        trainingLocationModelObj.locationName = place.name
        trainingLocationModelObj.locationLatitude = locationLatitude
        trainingLocationModelObj.locationLongitude = locationLongitude
        
        choosedTrainingLocationPreference = place.name
        self.settingsTableView.reloadSections(IndexSet(integer: 0), with: .automatic)

        userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: CommonMethods.getDictionaryFromTrainingLocationModel(training_location_model: trainingLocationModelObj)), forKey: "TrainingLocationModelBackup")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
}
