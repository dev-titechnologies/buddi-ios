//
//  ProfileVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import CountryPicker
import libPhoneNumber_iOS

class ProfileVC: UIViewController,UIImagePickerControllerDelegate,CountryPickerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var edit_btn: UIBarButtonItem!
    @IBOutlet weak var flage_img: UIImageView!
    @IBOutlet weak var contycode_lbl: UILabel!
    @IBOutlet weak var lastname_txt: UITextField!
    @IBOutlet weak var firstname_txt: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var image_edit_btn: UIButton!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblGender: UILabel!

    let imagePicker = UIImagePickerController()
    
    var imgData = NSData()
    var ProfileImageURL = String()
    var imageArray = Array<ProfileImageDB>()
    var objdata = NSData()
    var countrypicker = CountryPicker()

    let profileDetails : ProfileModel = ProfileModel()
    var ProfileDict: NSDictionary!
    var profileArray = Array<ProfileDB>()
    
    var isEditingProfile = Bool()
    var isUpdatingProfileImage = Bool()
    
    var isFromRouteVC = Bool()
    var userType = String()
    var userId = String()
    var countryAlphaCode = String()
    
    @IBOutlet weak var btnMenu: UIButton!
    
    //MARK: - VIEW CYCLES 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        
        self.title = PAGE_TITLE.TRAINEE_PROFILE
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("*** viewWillAppear")

        if !isUpdatingProfileImage{
            changeTextColorGrey()
            
            if isFromRouteVC{
                btnMenu.isHidden = true
                edit_btn.title = "Done"
            }
            
            fetchFromDBAndServer()
        }else{
            changeTextColorBlack()
        }
    }
    
    func fetchFromDBAndServer() {
        
        if let result = ProfileDB.fetchUser() {
            if result.count == 0{
                ProfileDataAPI()
            }else{
                print("from db")
                DispatchQueue.global(qos: .background).async {
                    self.FetchFromDb()
                    DispatchQueue.main.async {
                        print("This is run on the main queue, after the previous code in outer block")
                        self.ProfileDataAPI()
                    }
                }
//                FetchFromDb()
//                DispatchQueue.global(qos: .background).async {
//                    print("This is run on the background queue")
//                    self.ProfileDataAPI()
//                }
            }
        }else{
            print("from api")
            ProfileDataAPI()
        }
    }
    
    func changeTextColorBlack() {
        
        edit_btn.title = "Save"
        firstname_txt.textColor = .black
        lastname_txt.textColor = .black
        
        firstname_txt.isUserInteractionEnabled = true
        lastname_txt.isUserInteractionEnabled = true
        
        image_edit_btn.isUserInteractionEnabled = true
        image_edit_btn.isHidden = false
    }

    func changeTextColorGrey() {
        
        edit_btn.title = "Edit"
        firstname_txt.textColor = .gray
        lastname_txt.textColor = .gray
        lblEmail.textColor = .gray
        contycode_lbl.textColor = .gray
        lblMobile.textColor = .gray
        lblGender.textColor = .gray
        
        firstname_txt.isUserInteractionEnabled = false
        lastname_txt.isUserInteractionEnabled = false
        
        image_edit_btn.isUserInteractionEnabled = false
        image_edit_btn.isHidden = true
    }
    
    func FetchFromDb() {
        
        if let result = ProfileDB.fetchUser() {
            self.profileArray = result as! Array<ProfileDB>
            
            print("DBBB",self.profileArray[0])
   
            let profile = ProfileModel(profileImage: self.profileArray[0].value(forKey: "profileImageURL") as! String,
                                       firstName: self.profileArray[0].value(forKey: "firstname") as! String,
                                       lastName: self.profileArray[0].value(forKey: "lastname") as! String,
                                       email: self.profileArray[0].value(forKey: "email") as! String,
                                       mobile: self.profileArray[0].value(forKey: "mobile") as! String,
                                       gender: self.profileArray[0].value(forKey: "gender") as! String,
                                       userid: "")
            
            if profile.profileImage != "" {
                print("Image URL Found :\(profile.profileImage)")
                self.ProfileImageURL = profile.profileImage
            }
            
     // profileImage.sd_setImage(with: URL(string: profile.profileImage))
            firstname_txt.text = profile.firstName
            lastname_txt.text = profile.lastName
            lblEmail.text = profile.email
            lblGender.text = (profile.gender).uppercased()
            
            lblMobile.text = CommonMethods.phoneNumberSplit(number: profile.mobile).1
            contycode_lbl.text = CommonMethods.phoneNumberSplit(number: profile.mobile).0
            
            countrypicker.countryPickerDelegate = self
            countrypicker.showPhoneNumbers = true
           // countrypicker.setCountryByPhoneCode(CommonMethods.phoneNumberSplit(number: profile.mobile).0)
            
             self.mobileNumberValidation(number: profile.mobile)
            
            DispatchQueue.global(qos: .background).async {
                print("This is run on the background queue")
                
                if let imagearray = ProfileImageDB.fetchImage() {
                    self.imageArray = imagearray as! Array<ProfileImageDB>
                   
                    guard self.imageArray.count > 0 else{
                        return
                    }

                    self.objdata = self.imageArray[0].value(forKey: "imageData") as! NSData
                    DispatchQueue.main.async {
                        print("This is run on the main queue, after the previous code in outer block")
                        self.profileImage.image = UIImage(data: self.objdata as Data)
                    }
                }
            }
        }
    }
    
    @IBAction func editImage_action(_ sender: Any) {
        ProfilePicChoose()
    }
    
    @IBAction func editProfile_action(_ sender: Any) {
        
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
        guard !isFromRouteVC else {
            print("Poping viewcontroller as isFromRouteVC is true")
            navigationController?.popViewController(animated: true)
            return
        }
        
        if isEditingProfile == true{
            isEditingProfile = false
            changeTextColorGrey()
            EditProfileAPI()
        }else{
            isEditingProfile = true
            changeTextColorBlack()
        }
    }
    
    @IBAction func testupload(_ sender: Any) {
        
    }
    
    func EditProfileAPI(){
        
        let parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId,
                          "first_name":self.firstname_txt.text!,
                          "last_name":self.lastname_txt.text!,
                          "gender":(self.lblGender.text!).lowercased(),
                          "user_image":self.ProfileImageURL,
                          "profile_desc":"tt" ] as [String : Any]
        
        print("PARAMS",parameters)
        
        CommonMethods.serverCall(APIURL: EDIT_PROFILE, parameters: parameters , onCompletion: { (jsondata) in
            print("EDIT PROFILE RESPONSE",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    self.ProfileDict = jsondata["data"]  as! NSDictionary
                    
                    self.parseProfileDetails(profiledict: self.ProfileDict as! Dictionary<String, Any>)
                    
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Profile updated successfully", buttonTitle: "Ok")

                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
   func ProfilePicChoose(){
   
        let actionSheet: UIAlertController = UIAlertController(title: "Edit Profile Picture", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction) -> Void in
            actionSheet.dismiss(animated: true, completion: {() -> Void in
            })
        }))
        actionSheet.addAction(UIAlertAction(title: "From Gallery", style: .default, handler: {(action: UIAlertAction) -> Void in
            self.fromgallary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Take Picture", style: .default, handler: {(action: UIAlertAction) -> Void in
            self.FromCamera()
        }))
        self.present(actionSheet, animated: true, completion: { _ in })
    }
    
    func parseProfileDetails(profiledict: Dictionary<String, Any>) {
        
        print("FINAL DICT",profiledict)
        
        let profile = ProfileModel(
            profileImage : (profiledict["user_image"] as? String)!,
            firstName: (profiledict["first_name"] as? String)!,
            lastName: (profiledict["last_name"] as? String)!,
            email: (profiledict["email"] as? String)!,
            mobile: (profiledict["mobile"] as? String)!,
            gender: (profiledict["gender"] as? String)!,
            userid: ""
        )
        
        ProfileDB.createProfileEntry(profileModel: profile)
        
        lblMobile.text = CommonMethods.phoneNumberSplit(number: profile.mobile).1
        contycode_lbl.text = CommonMethods.phoneNumberSplit(number: profile.mobile).0
        
        let userName = profile.firstName + " " + profile.lastName as String
       
        if isFromRouteVC{
        }else{
             userDefaults.set(userName, forKey: "userName")
        }
        
        

        firstname_txt.text = profile.firstName
        lastname_txt.text = profile.lastName
        lblEmail.text = profile.email
        lblGender.text = (profile.gender).uppercased()
        
        countrypicker.countryPickerDelegate = self
        countrypicker.showPhoneNumbers = true
       // countrypicker.setCountryByPhoneCode(CommonMethods.phoneNumberSplit(number: profile.mobile).0)
       // countrypicker.setCountryByPhoneCode("+1")
        
//        self.mobileNumberValidation(number: "+1-4313354415")
        self.mobileNumberValidation(number: profile.mobile)
        
        
        if let image_url = profiledict["user_image"] as? String{
            if image_url != ""{
                 if isFromRouteVC{
                    
                    profileImage.sd_setImage(with: URL(string: image_url), placeholderImage: UIImage(named: "profileDemoImage"))
                 }else{
                    saveAndDisplayProfileImage(image_URL: image_url)
                }
            }
        }else{
            profileImage.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: "profileDemoImage"))
        }
    }
    func mobileNumberValidation(number : String){
        
        let phoneUtil = NBPhoneNumberUtil()
        do {
            let phoneNumber: NBPhoneNumber = try phoneUtil.parse(number, defaultRegion: countryAlphaCode)
            print("Is Valid Phone Number",phoneUtil.isValidNumber(phoneNumber))
            print("Country code",phoneUtil.getRegionCode(for: phoneNumber))
            countrypicker.setCountry(phoneUtil.getRegionCode(for: phoneNumber))
           // return phoneUtil.isValidNumber(phoneNumber)
        }catch{
           // return false
        }
    }

    func saveAndDisplayProfileImage(image_URL: String) {
        
        print("saveAndDisplayProfileImage",self.ProfileDict)
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
//            self.ProfileImageURL = (self.ProfileDict ["user_image"] as? String)!
            if let image_data = NSData.init(contentsOf: URL(string:image_URL)!){
                appDelegate.profileImageData = image_data
                self.profileImage.image = UIImage(data: image_data as Data)
                ProfileImageDB.save(imageURL: image_URL, imageData: image_data)
            }
        }
    }
    
    public func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        
        print("COUNTRY DETAILS\(name),\(countryCode),\(phoneCode)")
        flage_img.image = flag
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func ProfileDataAPI() {
        
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
        var parameters = [String : Any]()
        
        if isFromRouteVC{
            parameters = ["user_type": userType,
                          "user_id": userId] as [String : Any]
        }else{
            parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId] as [String : Any]
        }
        
        print("PARAMS",parameters)
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: VIEW_PROFILE, parameters: parameters , onCompletion: { (jsondata) in
            print("PROFILE RESPONSE",jsondata)
            
            CommonMethods.hideProgress()

            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    CommonMethods.hideProgress()
                    self.ProfileDict = jsondata["data"]  as! NSDictionary
                    self.parseProfileDetails(profiledict: self.ProfileDict as! Dictionary<String, Any>)

                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    func fromgallary() {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func FromCamera(){
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
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        dismiss(animated: true, completion: nil)
        
        CommonMethods.showProgress()
        var imagePickedData = NSData()
        imagePickedData = UIImageJPEGRepresentation(chosenImage, 1.0)! as NSData
//        imagePickedData = UIImagePNGRepresentation(chosenImage)! as NSData
        self.UploadImageAPI(imagedata: imagePickedData)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func UploadImageAPI(imagedata : NSData) {
        
        let headers = [
            "token" : appDelegate.Usertoken,
            "user_type" : appDelegate.USER_TYPE
        ]
        
        let parameters = ["file_type":"img",
                          "upload_type":"profile"]
        
        print("PARAMS",parameters)
        print("HEADERS",headers)
        
        let imageUploadURL = SERVER_URL + UPLOAD_VIDEO_AND_IMAGE
        print("Image Upload URL",imageUploadURL)
//        print("Image imagedata",imagedata)

        var uploadImageData = NSData()
        uploadImageData = imagedata
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            for (key, value) in parameters {
                
                print("PARAMETER1",value)
                print("PARAMETER11",key)
                
                multipartFormData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
            }

            multipartFormData.append(uploadImageData as Data, withName: "file_name", fileName: "image.png", mimeType: "image/png")

//            if let imageData = UIImageJPEGRepresentation(self.profileImage.image!, 0.6) {
//               // multipartFormData.append(data: imageData, name: "image", fileName: "file.png", mimeType: "image/png")
//                multipartFormData.append(uploadImageData as Data, withName: "file_name", fileName: "image.png", mimeType: "image/png")
//            }else{
//                print("NODATAAA")
//            }
         }, to: imageUploadURL,
           method:.post,
           headers:headers,
            
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Image upload response:\(response)")
                    if let jsonDic = response.result.value as? NSDictionary{
                        print("DICT ",jsonDic)
                        
                        if let status = jsonDic["status"] as? Int{
                            
                            if status == RESPONSE_STATUS.SUCCESS{
                                
                                self.profileImage.image = UIImage(data:(uploadImageData as NSData) as Data,scale:1.0)
                                 self.ProfileImageURL = (jsonDic["Url"] as? String)!
                                //self.EditProfileAPI()
                                
                                self.EditProfileAPIforImage()
                                
                                ProfileImageDB.save(imageURL: (jsonDic["Url"] as? String)!, imageData: uploadImageData as Data as Data as NSData)
                            }else if status == RESPONSE_STATUS.FAIL{
                                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsonDic["message"] as? String, buttonTitle: "Ok")
                            }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                                self.dismissOnSessionExpire()
                            }
                        }
                    }else{
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please try again", buttonTitle: "Ok")
                        self.ProfileImageURL = ""
                        self.changeTextColorBlack()
                    }
                }
            case .failure(let encodingError):
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please try again", buttonTitle: "Ok")
                self.ProfileImageURL = ""
                print(encodingError)
                self.changeTextColorBlack()
            }
        })
    }
    
    func EditProfileAPIforImage(){
        
        let parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId,
                          "first_name":self.firstname_txt.text!,
                          "last_name":self.lastname_txt.text!,
                          "gender":(self.lblGender.text!).lowercased(),
                          "user_image":self.ProfileImageURL,
                          "profile_desc":"tt" ] as [String : Any]
        
        print("PARAMS",parameters)
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: EDIT_PROFILE, parameters: parameters , onCompletion: { (jsondata) in
            print("EDIT PROFILE API IMAGE RESPONSE",jsondata)
            
            CommonMethods.hideProgress()
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    self.ProfileDict = jsondata["data"]  as! NSDictionary
                    self.parseProfileDetails(profiledict: self.ProfileDict as! Dictionary<String, Any>)
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PROFILE_PICTURE_UPDATED, buttonTitle: "Ok")
                    
                    self.changeTextColorBlack()
                }
                else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }else{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }
            }
        })
    }
}
