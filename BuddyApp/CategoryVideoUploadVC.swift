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
import AVFoundation

class CategoryVideoUploadVC: UIViewController,UINavigationControllerDelegate {

    let imagePickerController = UIImagePickerController()
    var videoURL: NSURL?
    var subcategories = [SubCategoryModel]()
    var subCategoryIndex = Int()
    let imagePicker = UIImagePickerController()
    var movieData = NSData()
    var ResponseVideoURL = String()

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
    
    @IBAction func camera_action(_ sender: Any) {
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
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                
                print("PARAMETER1",value)
                print("PARAMETER11",key)
                multipartFormData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
            }
            multipartFormData.append(self.movieData as Data, withName: "file_name", fileName: "video.mov", mimeType: "video/mov")
        }, to: "http://192.168.1.14:4001/upload/upload",
           method:.post,
           headers:headers,
           
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    debugPrint(response)
                    print("Video Upload Response:",response)
                    
//                    self.loadSubCategoryURLToSingletonArray()
                    
                    if let jsonDic = response.result.value as? NSDictionary{
                        print("DICT ",jsonDic)
                        
                        if let status = jsonDic["status"] as? Int{
                            if status == RESPONSE_STATUS.SUCCESS{
                                self.ResponseVideoURL = (jsonDic["Url"] as? String)!
                                CommonMethods.alertView(view: self, title: "", message: "VIDEO UPLOADED SUCCESSFULLY", buttonTitle: "Ok")
                             }
                        }
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    func loadSubCategoryURLToSingletonArray() {
        
        
    }
}

extension CategoryVideoUploadVC : UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        videoURL = info["UIImagePickerControllerMediaURL"] as? NSURL
        print("URLL",videoURL!)
        
        do {
            let video = try NSData(contentsOf: (info["UIImagePickerControllerMediaURL"] as? NSURL)! as URL, options: .mappedIfSafe)
            movieData = video
            print("Total bytes \(movieData.length/(1000*1000))")
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
}


extension CategoryVideoUploadVC: AVCaptureFileOutputRecordingDelegate {
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        guard let data = NSData(contentsOf: outputFileURL as URL) else {
            return
        }
        
        print("File size before compression1: \(Double(data.length / 1048576)) mb")
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
        compressVideo(inputURL: outputFileURL as URL, outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
                
                print("File size after compression1: \(Double(compressedData.length / 1048576)) mb")
            case .failed:
                break
            case .cancelled:
                break
            }
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
}
