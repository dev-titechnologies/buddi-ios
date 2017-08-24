//
//  TrainerProfilePage.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 14/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import CountryPicker
import Alamofire
import MapKit

class TrainerProfilePage: UIViewController {

    //Trainer Header Outlets
    @IBOutlet weak var StatusSwitch: UISwitch!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblHeight: UILabel!
    @IBOutlet weak var lblWeight: UILabel!
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    //SOCKET
    var parameterdict = NSMutableDictionary()
    var datadict = NSMutableDictionary()
    var timer = Timer()

    
    var isEditingProfile = Bool()
    var isUpdatingProfileImage = Bool()
    
    var profileImageURL = String()
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var btnChooseProfileImage: UIButton!
    var trainerProfileViewTableCaptionsArray = [String]()
    let trainerProfileModel = TrainerProfileModal()
    var locationManager: CLLocationManager!
    var lat = Float()
    var long = Float()

    var countrypicker = CountryPicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = PAGE_TITLE.TRAINER_PROFILE

        SocketIOManager.sharedInstance.establishConnection()
        StatusSwitch.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        self.UpdateLocationAPI(Status: "online")
        
        imagePicker.delegate = self
        trainerProfileViewTableCaptionsArray = ["Gym Subscriptions", "Training Category", "Certifications"]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("*** viewDidAppear Trainer")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("*** viewWillAppear Trainer")
        if !isUpdatingProfileImage{
            changeTextColorGrey()
            parseTrainerProfileDetails()
        }
        getCurrentLocationDetails()
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
    
    @IBAction func StatusSwitch_action(_ sender: Any) {
        
    }
    
    //MARK: - SOCKET CONNECTION
    
    func addHandlers() {
        
        datadict.setValue(appDelegate.UserId, forKey: "user_id")
        datadict.setValue(appDelegate.USER_TYPE, forKey: "user_type")
        datadict.setValue(lat, forKey: "latitude")
        datadict.setValue(long, forKey: "longitude")
        datadict.setValue("online", forKey: "avail_status")
        
        parameterdict.setValue("/location/addLocation", forKey: "url")
        parameterdict.setValue(datadict, forKey: "data")
        print("PARADICT11",parameterdict)
        
        SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict)
        SocketIOManager.sharedInstance.getSocketdata { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                print("Socket Message InfoProfile",messageInfo)
            })
        }
    }

    func switchValueDidChange(sender:UISwitch!) {
        if sender.isOn{
            print("ON STATUS")
            self.UpdateLocationAPI(Status: "online")
            timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.updateLocation), userInfo: nil, repeats: true)
        }else{
            print("OFF STATUS")
            self.UpdateLocationAPI(Status: "offline")
        }
    }
    
    func updateLocation(){
        NSLog("counting..")
        addHandlers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func parseTrainerProfileDetails() {
    
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
        let parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId] as [String : Any]
        
        let headers = [
            "token":appDelegate.Usertoken ]
        
        print("PARAMS",parameters)
        print("HEADER",headers)
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: VIEW_PROFILE, parameters: parameters , headers: headers , onCompletion: { (jsondata) in
            print("PROFILE RESPONSE",jsondata)
            
            CommonMethods.hideProgress()
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    let profileDict = jsondata["data"]  as! NSDictionary
                    print(profileDict)

//                    let profileObj = self.trainerProfileModel.getTrainerProfileModelFromDict(dictionary: profileDict as! Dictionary<String, Any>)
                    self.fillValuesInForm(profile: profileDict)
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }else{
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: REQUEST_TIMED_OUT, buttonTitle: "OK")
            }
        })
    }
    
    func UpdateLocationAPI(Status: String){
        
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
        let parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId,
                          "avail_status":Status
            ] as [String : Any]
        
        let headers = [
            "token":appDelegate.Usertoken ]
        
        print("PARAMS",parameters)
        print("HEADER",headers)
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: UPDATE_LOCATION_STATUS, parameters: parameters , headers: headers , onCompletion: { (jsondata) in
            print("**** Availability status response",jsondata)
            
            CommonMethods.hideProgress()
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    if jsondata["status"] as? String == "online"{
                        self.addHandlers()
                    }else{
                        self.timer.invalidate()
                    }
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    func changeTextColorBlack() {
        
        btnEdit.title = "Save"
        txtFirstName.textColor = .black
        txtLastName.textColor = .black
        
        txtFirstName.isUserInteractionEnabled = true
        txtLastName.isUserInteractionEnabled = true
        
        btnChooseProfileImage.isUserInteractionEnabled = true
        btnChooseProfileImage.isHidden = false
    }
    
    func changeTextColorGrey() {
        
        btnEdit.title = "Edit"
        
        txtFirstName.textColor = .gray
        txtLastName.textColor = .gray
        lblEmail.textColor = .gray
        lblCountryCode.textColor = .gray
        lblMobile.textColor = .gray
        lblGender.textColor = .gray
        
        txtFirstName.isUserInteractionEnabled = false
        txtLastName.isUserInteractionEnabled = false
        
        btnChooseProfileImage.isUserInteractionEnabled = false
        btnChooseProfileImage.isHidden = true
    }

    @IBAction func editAction(_ sender: Any) {
        
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }

        if isEditingProfile{
            isEditingProfile = false
            changeTextColorGrey()
            editProfileServerCall()
        }else{
            isEditingProfile = true
            changeTextColorBlack()
        }
    }
    
    func editProfileServerCall() {
        
        print("***** Edit profile Server Call *****")
        let parameters = ["user_type" : appDelegate.USER_TYPE,
                          "user_id" : appDelegate.UserId,
                          "first_name" : txtFirstName.text!,
                          "last_name" :txtLastName.text!,
                          "gender" : (lblGender.text!).lowercased(),
                          "user_image": profileImageURL,
                          "profile_desc":"tt" ] as [String : Any]
        
        let headers = [
            "token":appDelegate.Usertoken]
        
        print("PARAMS",parameters)
        print("HEADER",headers)
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: EDIT_PROFILE, parameters: parameters, headers: headers , onCompletion: { (jsondata) in
            print("EDIT PROFILE RESPONSE",jsondata)
            
            CommonMethods.hideProgress()
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    
                    let profileDict = jsondata["data"]  as! NSDictionary
                    print(profileDict)
                    
                   // let profileObj = self.trainerProfileModel.getTrainerProfileModelFromDict(dictionary: profileDict as! Dictionary<String, Any>)
                    self.fillValuesInForm(profile: profileDict)
                    
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PROFILE_UPDATED_SUCCESSFULLY, buttonTitle: "Ok")
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }else{
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "Ok")
                return
            }
        })
    }
    
    @IBAction func chooseProfileImageAction(_ sender: Any) {
    
        isUpdatingProfileImage = true
        chooseProfilePicture()
    }
    
    func fillValuesInForm(profile: NSDictionary) {
        
        print("*** fillValuesInForm :\(profile)")
        let userName = (profile["first_name"] as! String) + " " + (profile["last_name"] as! String)
        userDefaults.set(userName, forKey: "userName")
        
        if let age = profile["age"] as? String{
            lblAge.text = "Trainer \(age))"
        }else{
            lblAge.text = "Trainer"
        }

        lblTrainerName.text = (profile["first_name"] as! String) + " " + (profile["last_name"] as! String)
//        lblHeight.text = "\(CommonMethods.checkStringNull(val:profile["height"] as? String)) cm"
//        lblWeight.text = "\(CommonMethods.checkStringNull(val:profile["weight"] as? String)) lbs"
        txtFirstName.text = profile["first_name"] as? String
        txtLastName.text = profile["last_name"] as? String
        lblEmail.text = profile["email"] as? String
        lblCountryCode.text = CommonMethods.phoneNumberSplit(number: profile["mobile"] as! String).0
        lblMobile.text = CommonMethods.phoneNumberSplit(number: profile["mobile"] as! String).1
        lblGender.text = (profile["gender"] as! String).uppercased()
        
        if let image_url = profile["user_image"] as? String{
            profileImage.sd_setImage(with: URL(string:image_url)) { (image, error, cacheType, imageURL) in
                
                print("Image completion block")
                if image != nil {
                    print("image found")
                    self.profileImage.image = image
                }else{
                    print("image not found")
                    self.profileImage.image = UIImage(named: "profileDemoImage")
                }
            }
        }else{
            profileImage.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: "profileDemoImage"))
        }

        countrypicker.countryPickerDelegate = self
        countrypicker.showPhoneNumbers = true
        countrypicker.setCountryByPhoneCode(CommonMethods.phoneNumberSplit(number: profile["mobile"] as! String).0)
    }
}

extension TrainerProfilePage: CountryPickerDelegate{
    
    public func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        imgFlag.image = flag
    }
}

//MARK: - TABLEVIEW DATASOURCE FUNCTIONS

extension TrainerProfilePage: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainerProfileViewTableCaptionsArray.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 {
            let cell: AssignedTrainerProfileTableCaptionsCell = tableView.dequeueReusableCell(withIdentifier: "captionCellId") as! AssignedTrainerProfileTableCaptionsCell
            
            cell.title_lbl.text = trainerProfileViewTableCaptionsArray[indexPath.row]
            
            return cell
            
        }else if indexPath.row == 3{
            let cell: AssignedTrainerSocialMediaCell = tableView.dequeueReusableCell(withIdentifier: "socialMediaCellId") as! AssignedTrainerSocialMediaCell
            return cell
            
        }else{
            let cell: AssignedTrainerEmailCell = tableView.dequeueReusableCell(withIdentifier: "emailCellId") as! AssignedTrainerEmailCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var row = 0.0
        
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 {
            row = 60.0
        }else if indexPath.row == 3{
            row = 123.0
        }else{
            row = 60.0
        }
        return CGFloat(row)
    }
}

//MARK: - TABLEVIEW DELEGATE FUNCTIONS

extension TrainerProfilePage: UITableViewDelegate{
    
}

//MARK: - CHOOSE PROFILE PICTURE

extension TrainerProfilePage: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func chooseProfilePicture(){
        
        let actionSheet: UIAlertController = UIAlertController(title: "Edit Profile Picture", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction) -> Void in
            actionSheet.dismiss(animated: true, completion: {() -> Void in
            })
        }))
        actionSheet.addAction(UIAlertAction(title: "From Gallery", style: .default, handler: {(action: UIAlertAction) -> Void in
            self.fromGallery()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Take Picture", style: .default, handler: {(action: UIAlertAction) -> Void in
            self.fromCamera()
        }))
        self.present(actionSheet, animated: true, completion: { _ in })
    }
    
    func fromGallery() {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func fromCamera(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker,
                animated: true,
                completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print("*** didFinishPickingMediaWithInfo")
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        dismiss(animated: true, completion: nil)
    
        var imagePickedData = NSData()
        imagePickedData = UIImageJPEGRepresentation(chosenImage, 1.0)! as NSData
        self.uploadImageAPI(imagedata: imagePickedData)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImageAPI(imagedata : NSData) {
        
        print("**** uploadImageAPI")
        let headers = [
            "token":appDelegate.Usertoken ]
        let parameters = ["file_type":"img",
                          "upload_type":"profile"]
        
        print("PARAMS",parameters)
        print("HEADERS",headers)
        
        let imageUploadURL = SERVER_URL + UPLOAD_VIDEO_AND_IMAGE
        print("Image Upload URL",imageUploadURL)
        
        CommonMethods.showProgress()
        var uploadImageData = NSData()
        uploadImageData = imagedata
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            for (key, value) in parameters {
                
                print("PARAMETER1",value)
                print("PARAMETER11",key)
                
                multipartFormData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
            }
            
            if UIImageJPEGRepresentation(self.profileImage.image!, 0.6) != nil {
                multipartFormData.append(uploadImageData as Data, withName: "file_name", fileName: "image.png", mimeType: "image/png")
            }else{
                print("NODATAAA")
            }
        }, to: imageUploadURL,
           method:.post,
           headers:headers,
           
           encodingCompletion: { encodingResult in
            
            switch encodingResult {
                
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    debugPrint(response)
                    if let jsonDic = response.result.value as? NSDictionary{
                        print("DICT ",jsonDic)
                        
                        if let status = jsonDic["status"] as? Int{
                            
                            if status == RESPONSE_STATUS.SUCCESS{
                                
                                CommonMethods.hideProgress()
                                self.profileImage.image = UIImage(data:(uploadImageData as NSData) as Data,scale:1.0)
                                self.profileImageURL = (jsonDic["Url"] as? String)!
                                self.isUpdatingProfileImage = false
//                                print("*** editProfileServerCall inside Image upload")
//                                self.editProfileServerCall()
                                
                                ProfileImageDB.save(imageURL: (jsonDic["Url"] as? String)!, imageData: uploadImageData as Data as Data as NSData)
                            }else if status == RESPONSE_STATUS.FAIL{
                                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsonDic["message"] as? String, buttonTitle: "Ok")
                            }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                                self.dismissOnSessionExpire()
                            }
                        }else{
                            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please try again", buttonTitle: "Ok")
                            self.profileImageURL = ""
                        }
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }

}
extension TrainerProfilePage: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            
            print("**********************")
            print("Long \(location.coordinate.longitude)")
            print("Lati \(location.coordinate.latitude)")
            print("Alt \(location.altitude)")
            print("Sped \(location.speed)")
            print("Accu \(location.horizontalAccuracy)")
            
            print("**********************")
            
            lat = Float(location.coordinate.latitude)
            long = Float(location.coordinate.longitude)
            
        }
//        self.addHandlers()
               locationManager.stopUpdatingLocation()
        
    }
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
          
        }
    }
}
