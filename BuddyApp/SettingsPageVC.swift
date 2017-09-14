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
    let sessionTime = ["40","1"]
    var collapseArray = [Bool]()
    var sessionChoosed = Int()
    var headerChoosed = Int()
    var isChoosedGender = Bool()
    var locationcordinate = CLLocationCoordinate2D()
    var dict = NSMutableDictionary()
    var sessionCell = SessionPreferenceCell()
    var preferanceBool = Bool()
    
    var trainingLocationModelObj = TrainingLocationModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        preferanceBool = false

        self.title = PAGE_TITLE.SETTINGS
        
        sessionChoosed = -1
        headerChoosed = -1

        for _ in 0..<headerSectionTitles.count{
            collapseArray.append(false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        if choosedCategoryOfTrainee.categoryId != nil {
//            print("selected catogary ID",choosedCategoryOfTrainee.categoryId)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func Save_action(_ sender: Any) {
        
//        let gender = choosedTrainerGenderOfTrainee
//        let time = choosedSessionOfTrainee 
//        let catogary = choosedCategoryOfTrainee.categoryId
        
        if locationcordinate.latitude == 0.0{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please select location", buttonTitle: "Ok")
        }
        else if choosedCategoryOfTrainee.categoryId.isEmpty {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please choose category", buttonTitle: "Ok")
        }else if choosedTrainerGenderOfTrainee.isEmpty {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please select gender", buttonTitle: "Ok")
        }
        else if choosedSessionOfTrainee.isEmpty{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please choose session time", buttonTitle: "Ok")
        }else{
            preferanceBool = false
            print("GENDER",choosedTrainerGenderOfTrainee)
            print("TIME",choosedSessionOfTrainee)
            print("CATAGORY",choosedCategoryOfTrainee.categoryId)
            print("location",locationcordinate.latitude)
            
            dict.setValue(String(choosedTrainerGenderOfTrainee), forKey: "gender")
            dict.setValue(String(choosedSessionOfTrainee), forKey: "time")
            dict.setValue(String(choosedCategoryOfTrainee.categoryId), forKey: "catagoryid")
            dict.setValue(String(locationcordinate.latitude), forKey: "lat")
            dict.setValue(String(locationcordinate.longitude), forKey: "long")
            
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
            return sessionTime.count
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
            
            // PREFERANCE SHOWN
            
            if userDefaults.value(forKey: "save_preferance") as? NSDictionary != nil{
                
                let dict = userDefaults.value(forKey: "save_preferance") as? NSDictionary
                print("Preference dict:\(String(describing: dict))")
                let index = self.sessionTime.index(of: dict?["time"] as! String)
                print(index!)
            
              
                
                if  preferanceBool
                {
                    
                }
                else
                {
                     sessionChoosed = index!
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
            
            if userDefaults.value(forKey: "save_preferance") as? NSDictionary != nil{
                let dict = userDefaults.value(forKey: "save_preferance") as? NSDictionary
                
                if dict?["gender"] as! String == "male"{
                    genderCell.btnMale.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
                    genderCell.btnNopreferance.backgroundColor = .white
                    genderCell.btnFemale.backgroundColor = .white
                }else if dict?["gender"] as! String == "female"{
                    genderCell.btnMale.backgroundColor = .white
                    genderCell.btnNopreferance.backgroundColor = .white
                    genderCell.btnFemale.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
                }else{
                    genderCell.btnNopreferance.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
                    genderCell.btnFemale.backgroundColor = .white
                    genderCell.btnMale.backgroundColor = .white
                }
            }
            return genderCell
        }else{
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellid")!
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapSectionHeader(_:)))
        cell.contentView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        tapGesture.view?.tag = section
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         preferanceBool = true
        sessionChoosed = indexPath.row
        settingsTableView.reloadSections(IndexSet(integer: 3), with: .automatic)
        
        if indexPath.section == 0
        {
            
            
        }else if indexPath.section == 3{
            if indexPath.row == 0 {
                choosedSessionOfTrainee = "40"
            }else{
                choosedSessionOfTrainee = "60"
            }
        }
      
        print("Choosed Session:\(choosedSessionOfTrainee)")
        //print("Choosed Session:\(choosedSessionOfTrainee)")
        //userDefaults.set(choosedSessionOfTrainee, forKey: "backupTrainingSessionChoosed")
    }
    
    func didTapSectionHeader(_ sender: UITapGestureRecognizer) {
        print("Please Help!")
        
        let indexpath: IndexPath = IndexPath.init(row: 0, section: (sender.view?.tag)!)
        print("Tapped Index:",indexpath.section)
        
        headerChoosed = (sender.view?.tag)!
        let collapsed = collapseArray[indexpath.section]
        if indexpath.section == 2 || indexpath.section == 3 {
            self.collapseArray[indexpath.section] = !collapsed
            self.settingsTableView.reloadSections(IndexSet(integer: sender.view!.tag), with: .automatic)
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
        
        self.locationcordinate = place.coordinate
        
        print("Place name \(place.name)")
        print("STATUS",place.openNowStatus.rawValue)
        
        
        switch place.openNowStatus {
        case .yes:
            print( "This places is open")
        case .no:
            print( "This places is closed now")
        case .unknown:
            print( "No idea about open status")
        }
        
        trainingLocationModelObj.locationName = place.name
        trainingLocationModelObj.locationLatitude = String(place.coordinate.latitude)
        trainingLocationModelObj.locationLongitude = String(place.coordinate.longitude)
        
        userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: CommonMethods.getDictionaryFromTrainingLocationModel(training_location_model: trainingLocationModelObj)), forKey: "TrainingLocationModelBackup")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
}
