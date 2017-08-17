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

class TrainerProfilePage: UIViewController {

    //Trainer Header Outlets
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
    
    var isEditingProfile = Bool()
    var isUpdatingProfileImage = Bool()
    
    var profileImageURL = String()
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var btnChooseProfileImage: UIButton!
    var trainerProfileViewTableCaptionsArray = [String]()
    let trainerProfileModel = TrainerProfileModel()
    
    var countrypicker = CountryPicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        trainerProfileViewTableCaptionsArray = ["Gym Subscriptions", "Training Category", "Certifications"]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("*** viewWillAppear Trainer")
        if !isUpdatingProfileImage{
            changeTextColorGrey()
            parseTrainerProfileDetails()
        }
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
        
        CommonMethods.serverCall(APIURL: VIEW_PROFILE, parameters: parameters , headers: headers , onCompletion: { (jsondata) in
            print("PROFILE RESPONSE",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    let profileDict = jsondata["data"]  as! NSDictionary
                    print(profileDict)

                    let profileObj = self.trainerProfileModel.getTrainerProfileModelFromDict(dictionary: profileDict)
                    self.fillValuesInForm(profile: profileObj)
                    
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
                    
                    let profileObj = self.trainerProfileModel.getTrainerProfileModelFromDict(dictionary: profileDict)
                    self.fillValuesInForm(profile: profileObj)
                    
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
    
    func fillValuesInForm(profile: TrainerProfileModel) {
        
        let userName = profile.firstName + " " + profile.lastName as String
        userDefaults.set(userName, forKey: "userName")

        lblTrainerName.text = profile.firstName + " " + profile.lastName
        lblAge.text = "Trainer (\(profile.age))"
        lblHeight.text = "\(profile.height) cm"
        lblWeight.text = "\(profile.weight) lbs"
        txtFirstName.text = profile.firstName
        txtLastName.text = profile.lastName
        lblEmail.text = profile.email
        lblCountryCode.text = CommonMethods.phoneNumberSplit(number: profile.mobile).0
        lblMobile.text = CommonMethods.phoneNumberSplit(number: profile.mobile).1
        lblGender.text = profile.gender.uppercased()
        profileImage.sd_setImage(with: URL(string: profile.profileImage), placeholderImage: UIImage(named: "profileDemoImage"))

        countrypicker.countryPickerDelegate = self
        countrypicker.showPhoneNumbers = true
        countrypicker.setCountryByPhoneCode(CommonMethods.phoneNumberSplit(number: profile.mobile).0)
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
    
        CommonMethods.showProgress()
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
        
        var uploadImageData = NSData()
        uploadImageData = imagedata
        
        CommonMethods.showProgress()
        
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
                                
                                self.profileImage.image = UIImage(data:(uploadImageData as NSData) as Data,scale:1.0)
                                self.profileImageURL = (jsonDic["Url"] as? String)!
                                self.isUpdatingProfileImage = false
                                print("*** editProfileServerCall inside Image upload")
                                self.editProfileServerCall()
                                
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
