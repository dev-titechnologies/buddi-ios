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

class ProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

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

    
    let profileDetails : ProfileModel = ProfileModel()
    var ProfileDict: NSDictionary!
    
    var profileArray = Array<ProfileDB>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = 60
        profileImage.clipsToBounds = true
         imagePicker.delegate = self 
      
        
        
        if let result = ProfileDB.fetchUser()      {
            if result.count == 0
            {
               ProfileDataAPI()
                
            
            }
            else
            {
                print("from db")
                FetchFromDb()
            }
            
        }
        else
        {
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
            
            
           // profileImage.image = UIImage.init(named: profile.profileImage)
            firstname_txt.text = profile.firstName
            lastname_txt.text = profile.lastName
            email_txt.text = profile.email
            mobile_txt.text = profile.mobile
            gender_txt.text = profile.gender

            
            
        
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
       // parseProfileDetails()
        
      
        
    }
    @IBAction func editImage_action(_ sender: Any) {
        ProfilePicChoose()
        
    }
    @IBAction func editProfile_action(_ sender: Any) {
        
        
        image_edit_btn.isHidden = false
        
       // self.EditProfileAPI()
    }
    
    @IBAction func testupload(_ sender: Any) {
        var imagePickedData = NSData()
        imagePickedData = UIImageJPEGRepresentation(self.profileImage.image!, 1.0)! as NSData
   //imagePickedData = UIImageJPEGRepresentation(UIImage(named:"AC.png")!, 1.0)! as NSData
        
//        self.UploadImageAPI()
        
        self.UploadImageAPI(imagedata: imagePickedData)
        
    }
    func EditProfileAPI()
    {
        
        
        
        let parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId,
                           "first_name":self.firstname_txt.text!,
                            "last_name":self.lastname_txt.text!,
                           "gender":self.gender_txt.text!,
                         "user_image":"",
                         "profile_desc":"tt" ] as [String : Any]
        
        let headers = [
            "token":appDelegate.Usertoken ]
        
        
        print("PARAMS",parameters)
        print("HEADER",headers)
        
        CommonMethods.serverCall(APIURL: "profile/editProfile", parameters: parameters , headers: headers , onCompletion: { (jsondata) in
            print("EDIT PROFILE RESPONSE",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == 1{
                    
                    self.ProfileDict = jsondata["data"]  as! NSDictionary
                    
                    self.parseProfileDetails(profiledict: self.ProfileDict as! Dictionary<String, Any>)

                }
            }
        })
        
        
    

    }
   func ProfilePicChoose()
   {
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
        
        
        let profile = ProfileModel(profileImage: (profiledict["user_image"] as? String)!, firstName: (profiledict["first_name"] as? String)!, lastName: (profiledict["last_name"] as? String)!, email: (profiledict["email"] as? String)!, mobile: (profiledict["mobile"] as? String)!, gender: (profiledict["gender"] as? String)!, userid: "")
        
        
        
        ProfileDB.createProfileEntry(profileModel: profile)
        
      //  flage_img.image = UIImage.sd_image(with: userDefaults.value(forKey: "flage_img") as! Data)
        
        
        
      //  profileImage.image = UIImage.init(named: profile.profileImage)
        firstname_txt.text = profile.firstName
        lastname_txt.text = profile.lastName
        email_txt.text = profile.email
        mobile_txt.text = profile.mobile
        gender_txt.text = profile.gender
        
        SVProgressHUD.dismiss()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func ProfileDataAPI() {
        
    SVProgressHUD.show()
        
        
        let parameters = ["user_type":appDelegate.USER_TYPE,
                          "user_id":appDelegate.UserId] as [String : Any]
        
        let headers = [
            "token":appDelegate.Usertoken ]

        
        print("PARAMS",parameters)
         print("HEADER",headers)
        
        CommonMethods.serverCall(APIURL: "profile/viewProfile", parameters: parameters , headers: headers , onCompletion: { (jsondata) in
            print("PROFILE RESPONSE",jsondata)
            
            if let status = jsondata["status"] as? Int{
                if status == 1{
                    
                     self.ProfileDict = jsondata["data"]  as! NSDictionary
                    
                    self.parseProfileDetails(profiledict: self.ProfileDict as! Dictionary<String, Any>)
                    
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
        self.profileImage.contentMode = .scaleAspectFit //3
        self.profileImage.image = chosenImage //4
    
    
    
        dismiss(animated: true, completion: nil)
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
        
        var filetype = String()
        var uploadtype = String()
        
        filetype = "img"
        uploadtype = "profile"
        

//
//        let imageData = UIImagePNGRepresentation(self.profileImage.image!)!
//        
//        Alamofire.upload(imageData, to: "http://192.168.1.14:4001/upload/upload",headers: headers ).responseJSON { response in
//            debugPrint(response)
//        }
        
       // let updateUrl = NSURL(string: "http://192.168.1.14:4001/upload/upload" as String)
        
        
        var uploadImageData = NSData()
        
        
       // uploadImageData = UIImageJPEGRepresentation(UIImage(named:"AC.png")!, 1.0)! as NSData
        
        uploadImageData = imagedata
        
        self.flage_img.image = UIImage(data:uploadImageData as Data,scale:1.0)
        
        
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
                
                
              
                
            }
            else{
                print("NODATAAA")
            }
           
            //
//        multipartFormData.append(filetype.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: "file_type")
//             multipartFormData.append(uploadtype.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: "upload_type")
            
            
            
        }, to: "http://192.168.1.14:4001/upload/upload",
           method:.post,
           headers:headers,
           
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    debugPrint(response)
                }
            case .failure(let encodingError):
                print(encodingError)
                
            } })
}
}
