//
//  CategoryVideoUploadVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 24/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import Alamofire

class CategoryVideoUploadVC: UIViewController {

    let imagePickerController = UIImagePickerController()
    var videoURL: NSURL?

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func pickVideoFromGalleryAction(_ sender: Any) {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePickerController.mediaTypes = ["public.image", "public.movie"]
        
        present(imagePickerController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension CategoryVideoUploadVC : UIImagePickerControllerDelegate {

    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        videoURL = info["UIImagePickerControllerReferenceURL"] as? NSURL
        print(videoURL!)
        imagePickerController.dismiss(animated: true, completion: nil)
//        uploadVideo()
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

