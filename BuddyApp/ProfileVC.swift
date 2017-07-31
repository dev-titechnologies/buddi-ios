//
//  ProfileVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import AlamofireImage
import CountryPicker

class ProfileVC: UIViewController,UIImagePickerControllerDelegate,CountryPickerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var edit_btn: UIBarButtonItem!
    @IBOutlet weak var gender_txt: UITextField!
    @IBOutlet weak var flage_img: UIImageView!
    @IBOutlet weak var contycode_lbl: UILabel!
    @IBOutlet weak var mobile_txt: UITextField!
    @IBOutlet weak var email_txt: UITextField!
    @IBOutlet weak var lastname_txt: UITextField!
    @IBOutlet weak var firstname_txt: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var lblEmailID: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var image_edit_btn: UIButton!
    let imagePicker = UIImagePickerController()
    var imgData = NSData()
   var ProfileImageURL = String()
    var EditBool = Bool()
    var imageArray = Array<ProfileImageDB>()
    var objdata = NSData()
    
    var countrypicker = CountryPicker()

    
    let profileDetails : ProfileModel = ProfileModel()
    var ProfileDict: NSDictionary!
    
    var profileArray = Array<ProfileDB>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = 60
        profileImage.clipsToBounds = true
         imagePicker.delegate = self 
         EditBool = true
              
        
      

        
        
       
        
        firstname_txt.isUserInteractionEnabled = false
        lastname_txt.isUserInteractionEnabled = false
        email_txt.isUserInteractionEnabled = false
        mobile_txt.isUserInteractionEnabled = false
        gender_txt.isUserInteractionEnabled = false
        
        
        
        
        if let result = ProfileDB.fetchUser()      {
            if result.count == 0
            {
                
                 SVProgressHUD.show()
               ProfileDataAPI()
                
            
            }
            else
            {
                print("from db")
                FetchFromDb()
                
                
                DispatchQueue.global(qos: .background).async {
                    print("This is run on the background queue")
                    
                    self.ProfileDataAPI()
                    
                
                }
                    DispatchQueue.main.async {
                        print("This is run on the main queue, after the previous code in outer block")
                        
                       
                    }
                }
                
     
            
        }
        else
        {
            
             SVProgressHUD.show()
            print("from api")
            ProfileDataAPI()
        }
        
        

        

    }
    func FetchFromDb() {
        
        if let result = ProfileDB.fetchUser()      {
        
         self.profileArray = result as! Array<ProfileDB>
            
            let obj = self.profileArray[0].value(forKey: "firstname")
            print("DBBB",obj!)
            
    let profile = ProfileModel(profileImage: self.profileArray[0].value(forKey: "profileImageURL") as! String, firstName: self.profileArray[0].value(forKey: "firstname") as! String,
        lastName: self.profileArray[0].value(forKey: "lastname") as! String,
        email: self.profileArray[0].value(forKey: "email") as! String,
        mobile: self.profileArray[0].value(forKey: "mobile") as! String,
        gender: self.profileArray[0].value(forKey: "gender") as! String,
        userid: "")
            
     // profileImage.sd_setImage(with: URL(string: profile.profileImage))
            firstname_txt.text = profile.firstName
            lastname_txt.text = profile.lastName
            email_txt.text = profile.email
            gender_txt.text = profile.gender
            
            mobile_txt.text = CommonMethods.phoneNumberSplit(number: profile.mobile).1
            contycode_lbl.text = CommonMethods.phoneNumberSplit(number: profile.mobile).0

            countrypicker.countryPickerDelegate = self
            countrypicker.showPhoneNumbers = true
            countrypicker.setCountryByPhoneCode(CommonMethods.phoneNumberSplit(number: profile.mobile).0)
            
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
    override func viewWillAppear(_ animated: Bool) {
        
       // parseProfileDetails()
        
      
        
    }
    @IBAction func editImage_action(_ sender: Any) {
        ProfilePicChoose()
        
    }
    @IBAction func editProfile_action(_ sender: Any) {
        
        
        guard CommonMethods.networkcheck() else {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_CHECK_INTERNET, buttonTitle: "Ok")
            return
        }
        
        if EditBool == true{
            edit_btn.title = "Save"
            
            EditBool = false
            firstname_txt.isUserInteractionEnabled = true
            lastname_txt.isUserInteractionEnabled = true
            image_edit_btn.isHidden = false
        }else{
            
            firstname_txt.isUserInteractionEnabled = false
            lastname_txt.isUserInteractionEnabled = false
            image_edit_btn.isHidden = true
            edit_btn.title = "Edit"
            EditBool = true
            EditProfileAPI()
        }
    }
    
    @IBAction func testupload(_ sender: Any) {
//        var imagePickedData = NSData()
//        imagePickedData = UIImageJPEGRepresentation(self.profileImage.image!, 1.0)! as NSData
   //imagePickedData = UIImageJPEGRepresentation(UIImage(named:"AC.png")!, 1.0)! as NSData
        
//        self.UploadImageAPI()
        
//        self.UploadImageAPI(imagedata: imagePickedData)
        
    }
    func EditProfileAPI()
    {
        
        
        
        let parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId,
                           "first_name":self.firstname_txt.text!,
                            "last_name":self.lastname_txt.text!,
                           "gender":self.gender_txt.text!,
                         "user_image":self.ProfileImageURL,
                         "profile_desc":"tt" ] as [String : Any]
        
        let headers = [
            "token":appDelegate.Usertoken ]
        
        
        print("PARAMS",parameters)
        print("HEADER",headers)
        
        CommonMethods.serverCall(APIURL: "profile/editProfile", parameters: parameters , headers: headers , onCompletion: { (jsondata) in
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
        
        let profile = ProfileModel(profileImage: (profiledict["user_image"] as? String)!, firstName: (profiledict["first_name"] as? String)!, lastName: (profiledict["last_name"] as? String)!, email: (profiledict["email"] as? String)!, mobile: (profiledict["mobile"] as? String)!, gender: (profiledict["gender"] as? String)!, userid: "" )
        
        ProfileDB.createProfileEntry(profileModel: profile)
        
        mobile_txt.text = CommonMethods.phoneNumberSplit(number: profile.mobile).1
        contycode_lbl.text = CommonMethods.phoneNumberSplit(number: profile.mobile).0
        

        
       // profileImage.sd_setImage(with: URL(string: profile.profileImage))
        firstname_txt.text = profile.firstName
        lastname_txt.text = profile.lastName
        email_txt.text = profile.email
        //mobile_txt.text = profile.mobile
        gender_txt.text = profile.gender
        
        
        countrypicker.countryPickerDelegate = self
        countrypicker.showPhoneNumbers = true
        countrypicker.setCountryByPhoneCode(CommonMethods.phoneNumberSplit(number: profile.mobile).0)
        
        if let imagearray = ProfileImageDB.fetchImage() {
            self.imageArray = imagearray as! Array<ProfileImageDB>
            
            guard self.imageArray.count > 0 else{
                return
            }
            
            self.objdata = self.imageArray[0].value(forKey: "imageData") as! NSData
                           self.profileImage.image = UIImage(data: self.objdata as Data)
            
        }
        SVProgressHUD.dismiss()
    }
    
    public func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
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

        
        let parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId] as [String : Any]
        
        let headers = [
            "token":appDelegate.Usertoken ]

        print("PARAMS",parameters)
        print("HEADER",headers)
        
        CommonMethods.serverCall(APIURL: "profile/viewProfile", parameters: parameters , headers: headers , onCompletion: { (jsondata) in
            print("PROFILE RESPONSE",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    self.ProfileDict = jsondata["data"]  as! NSDictionary

                    if let url = URL(string:(self.ProfileDict ["user_image"] as? String)!){
                        print("Image URL:", url)
                        let data = NSData.init(contentsOf: url)
                        ProfileImageDB.save(imageURL: (self.ProfileDict["user_image"] as? String)!, imageData: data!)
                    }
                    
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
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            
//            self.profileImage.image = pickedImage
//  
    
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
       // self.profileImage.contentMode = .scaleAspectFit //3
       // self.profileImage.image = chosenImage //4

        dismiss(animated: true, completion: nil)
        var imagePickedData = NSData()
        imagePickedData = UIImageJPEGRepresentation(chosenImage, 1.0)! as NSData
        self.UploadImageAPI(imagedata: imagePickedData)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func UploadImageAPI(imagedata : NSData) {
        
        let headers = [
            "token":appDelegate.Usertoken ]
        let parameters = ["file_type":"img",
                          "upload_type":"profile"]
        
        print("PARAMS",parameters)
        print("HEADERS",headers)
        
        
        var uploadImageData = NSData()
        uploadImageData = imagedata
        
       // print("DATTTAAAA",uploadImageData)
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            for (key, value) in parameters {
                
                print("PARAMETER1",value)
                print("PARAMETER11",key)
                
                multipartFormData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
            }

            if let imageData = UIImageJPEGRepresentation(self.profileImage.image!, 0.6) {
               // multipartFormData.append(data: imageData, name: "image", fileName: "file.png", mimeType: "image/png")
                multipartFormData.append(uploadImageData as Data, withName: "file_name", fileName: "image.png", mimeType: "image/png")
            }else{
                print("NODATAAA")
            }
         }, to: "http://192.168.1.14:4001/upload/upload",
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
                                 self.ProfileImageURL = (jsonDic["Url"] as? String)!
                                //self.EditProfileAPI()
                                
                                self.EditProfileAPIforImage()
                                
                                ProfileImageDB.save(imageURL: (jsonDic["Url"] as? String)!, imageData: uploadImageData as Data as Data as NSData)
                            }else if status == RESPONSE_STATUS.FAIL{
                                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsonDic["message"] as? String, buttonTitle: "Ok")
                            }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                                self.dismissOnSessionExpire()
                            }
                        }else{
                             CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please try again", buttonTitle: "Ok")
                            self.ProfileImageURL = ""
                        }
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    func EditProfileAPIforImage()
    {
        
        
        
        let parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId,
                          "first_name":self.firstname_txt.text!,
                          "last_name":self.lastname_txt.text!,
                          "gender":self.gender_txt.text!,
                          "user_image":self.ProfileImageURL,
                          "profile_desc":"tt" ] as [String : Any]
        
        let headers = [
            "token":appDelegate.Usertoken ]
        
        
        print("PARAMS",parameters)
        print("HEADER",headers)
        
        CommonMethods.serverCall(APIURL: "profile/editProfile", parameters: parameters , headers: headers , onCompletion: { (jsondata) in
            print("EDIT PROFILE RESPONSE",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    self.ProfileDict = jsondata["data"]  as! NSDictionary
                    
                    self.parseProfileDetails(profiledict: self.ProfileDict as! Dictionary<String, Any>)
                    
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Profile picture updated", buttonTitle: "Ok")
                }
                else if status == RESPONSE_STATUS.SESSION_EXPIRED
                    
                {
                    self.dismissOnSessionExpire()
                }
                else{
                    
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                    
                }
            }
        })
        
        
        
        
    }
}
