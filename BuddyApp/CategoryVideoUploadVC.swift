//
//  CategoryVideoUploadVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 24/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import Alamofire
import MobileCoreServices

class CategoryVideoUploadVC: UIViewController,UINavigationControllerDelegate {

    let imagePickerController = UIImagePickerController()
    var videoURL: NSURL?
    var subcategories = [SubCategoryModel]()
    var subCategoryIndex = Int()
    let imagePicker = UIImagePickerController()
    var movieData = NSData()

    @IBOutlet weak var lblSubCategoryTitle: UILabel!
    @IBOutlet weak var lblMainDescription: UILabel!
    @IBOutlet weak var lblMalesDescription: UILabel!
    @IBOutlet weak var lblFemalesDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subCategoryIndex = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        subcategories = selectedSubCategoriesAmongSingleton
        lblMainDescription.text = VIDEO_DESC
        loadSubCategoryDetailsInitially()
    }
    
    func loadSubCategoryDetailsInitially() {
        
        displayDetails(subCategoryName: subcategories[subCategoryIndex].subCategoryName)
    }
    
    func displayDetails(subCategoryName: String) {
        
        switch subCategoryName {
            
        case SUB_CATEGORY_TITLES.SQUAT:
            print("SQUAT")
            lblSubCategoryTitle.text = SUB_CATEGORY_TITLES.SQUAT
            lblMalesDescription.text = SQUAT_MALE_DESC
            lblFemalesDescription.text = SQUAT_FEMALE_DESC
            
        case SUB_CATEGORY_TITLES.DEAD_LIFT:
            print("DEAD_LIFT")
            lblSubCategoryTitle.text = SUB_CATEGORY_TITLES.DEAD_LIFT
            lblMalesDescription.text = DEADLIFT_MALE_DESC
            lblFemalesDescription.text = DEADLIFT_FEMALE_DESC

        case SUB_CATEGORY_TITLES.BENCH_PRESS:
            print("BENCH_PRESS")
            lblSubCategoryTitle.text = SUB_CATEGORY_TITLES.BENCH_PRESS
            lblMalesDescription.text = BENCH_PRESS_MALE_DESC
            lblFemalesDescription.text = BENCH_PRESS_FEMALE_DESC
            
        case SUB_CATEGORY_TITLES.SNACH:
            print("SNACH")
            lblSubCategoryTitle.text = SUB_CATEGORY_TITLES.SNACH
            lblMalesDescription.text = SNACH_MALE_DESC
            lblFemalesDescription.text = SNACH_FEMALE_DESC
            
        case SUB_CATEGORY_TITLES.CLEAN_JERK:
            print("CLEAN_JERK")
            lblSubCategoryTitle.text = SUB_CATEGORY_TITLES.CLEAN_JERK
            lblMalesDescription.text = CLEAN_JERK_MALE_DESC
            lblFemalesDescription.text = CLEAN_JERK_FEMALE_DESC
            
        default:
            print("Sub Category not Defined")
        }
    }
    
    @IBAction func pickVideoFromGalleryAction(_ sender: Any) {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePickerController.mediaTypes = ["public.image", "public.movie"]
        
        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func subCategoryNextButton(_ sender: Any) {
        
        subCategoryIndex += 1
        if subCategoryIndex == subcategories.count{
            performSegue(withIdentifier: "afterVideoUploadSegue", sender: self)
        }else{
            displayDetails(subCategoryName: subcategories[subCategoryIndex].subCategoryName)
        }
    }
    
    @IBAction func cameraRoll_action(_ sender: Any) {
       
        
    }
    @IBAction func camera_action(_ sender: Any) {
        
//        imagePicker.sourceType = .camera
//        imagePicker.mediaTypes = [kUTTypeMovie as NSString as String]
//        imagePicker.allowsEditing = false
         imagePicker.delegate = self
        
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
       imagePicker.mediaTypes = [kUTTypeMovie as NSString as String]
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker,
                animated: true,
                completion: nil)

        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func UploadVideoAPI() {
        
        let headers = [
            "token":appDelegate.Usertoken ]
        let parameters = ["file_type":"vid",
                          "upload_type":"other"]
        
        print("PARAMS",parameters)
        print("HEADERS",headers)
        
//        var filetype1 = String()
//        var uploadtype1 = String()
//        
//        filetype = "vid"
//        uploadtype = "other"
        
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            
            
            
            for (key, value) in parameters {
                
                print("PARAMETER1",value)
                print("PARAMETER11",key)
                
                multipartFormData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
                
                
            }
            
          
            
            
      //  multipartFormData.append(movieData, name: "file_name", fileName: "video.mov", mimeType: "video/mov")
            
    multipartFormData.append(self.movieData as Data, withName: "file_name", fileName: "video.mov", mimeType: "video/mov")
            
            
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

extension CategoryVideoUploadVC : UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        videoURL = info["UIImagePickerControllerMediaURL"] as? NSURL
        print("URLL",videoURL!)
        
       // var movieData: NSData?
        do {
            let video = try NSData(contentsOf: (info["UIImagePickerControllerMediaURL"] as? NSURL)! as URL, options: .mappedIfSafe)
            
            movieData = video
            
            print("Total bytes \(movieData.length)")
        } catch {
            print(error)
            return
        }
        
        
        dismiss(animated: true, completion: nil)
         UploadVideoAPI()
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
//    func uploadVideo() {
//        
//        let url = SERVER_URL_Local + "upload/upload"
//        
//        let request = NSMutableURLRequest(URL:url);
//        request.HTTPMethod = "POST";
//        
//        let param = [
//            "firstName"  : "TESTNAME",
//            "lastName"    : "TESTNAMELAST",
//            "userId"    : "10"
//        ]
//        
//        let boundary = generateBoundaryString()
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        let imageData = UIImageJPEGRepresentation(myImageView.image!, 1)
//        if(imageData==nil)  { return; }
//        request.HTTPBody = createBodyWithParameters(param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary)
//        
//        myActivityIndicator.startAnimating();
//        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
//            data, response, error in
//            
//            if error != nil {
//                print("error=\(error)", terminator: "")
//                return
//            }
//            
//            print("******* response = \(response)", terminator: "")
//            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            print("****** response data = \(responseString!)")
//            
//            //let json:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers )) as! NSDictionary
//            dispatch_async(dispatch_get_main_queue(),{
//                self.myActivityIndicator.stopAnimating()
//                self.myImageView.image = nil;
//            });
//        }
//        task.resume()
//    }
    
        
        
//        Alamofire.upload(.POST, "upload/upload", multipartFormData: { (formData:MultipartFormData) in
//            formData.append(videoURL! as URL, withName: "test")
//        }, encodingCompletion: { encodingResult in
//            switch encodingResult {
//            case .Success(let upload, _, _):
//                upload.progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
//                    print(totalBytesRead)
//                }
//                upload.responseJSON { response in
//                    debugPrint(response)
//                    //uploaded
//                }
//            case .Failure(let encodingError):
//                //Something went wrong!
//                if DEBUG_MODE {
//                    print(encodingError)
//                }
//            }
//        })
        
        
    
}

