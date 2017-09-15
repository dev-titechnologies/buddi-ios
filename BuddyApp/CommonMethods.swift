//
//  CommonMethods.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import Alamofire
import SVProgressHUD

class CommonMethods: NSObject {

      class func serverCall(APIURL : String, parameters : Dictionary<String, Any>, headers: HTTPHeaders?, onCompletion:@escaping ((_ jsonData: Dictionary<String, Any>) -> Void)){
        
        let FinalURL = SERVER_URL + APIURL
        print("Final Server URL:",FinalURL)
        Alamofire.request(FinalURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
            case .success:
//                print(response)
                if let value = response.value {
                    onCompletion(value as! Dictionary<String, Any>)
                }
                break
            case .failure(let error):
                print(error)
                onCompletion([:])
            }
        }
    }
        
    class func checkStringNull(val: String?) -> String {
        if let value = val {
            return value
        }
        return " "
    }

    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
 
    class func alertView(view : UIViewController, title : String?, message: String?, buttonTitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil))
        
        view.present(alert, animated: true, completion: nil)
    }
//    class func getCurrentDateString() -> Date{
//        let date = Date()
//        let calendar = Calendar.current
//
//        let hour = calendar.component(.hour, from: date)
//        let minutes = calendar.component(.minute, from: date)
//        let seconds = calendar.component(.second, from: date)
//        print("hours = \(hour):\(minutes):\(seconds)")
//        
//        return "\(hour):\(minutes):\(seconds)"
//    }

    
    class func getDateFromString(dateString: String) -> Date {
        // print("DAYYT",dateStr)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale     = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        
        let date = dateFormatter.date(from: dateString)
        return date!
    }
    
    class func getStringFromDate(date: Date) -> String{
        let date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from:date as Date)
        print(dateString) 
        return dateString
    }
    class func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    class func phoneNumberSplit(number: String) -> (String, String)
    {
        
        let fullName = number
        let fullNameArr = fullName.characters.split{$0 == "-"}.map(String.init)
        // or simply:
        // let fullNameArr = fullName.characters.split{" "}.map(String.init)
        
        fullNameArr[0] // First
        fullNameArr[1] // Last
        print(fullNameArr[0])
        print(fullNameArr[1])
        
        return (fullNameArr[0], fullNameArr[1])
    }
    
    class func clearSession() {
        
         userDefaults.removeObject(forKey: "token")
         userDefaults.removeObject(forKey: "user_id")
         userDefaults.removeObject(forKey: "userType")
        userDefaults.removeObject(forKey: "save_preferance")
    }
    
    class func networkcheck() ->( Bool)
    {
        var statusBool = Bool()
        
        let status = Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            print("Not connected")
            
            statusBool = false
        case .online(.wwan):
            print("Connected via WWAN")
            
            statusBool = true
        case .online(.wiFi):
            print("Connected via WiFi")
            
            statusBool = true
        }
        
        return statusBool
        
    }

    class func showProgress(){
        print("========== Show Progress bar ============")
        UIApplication.shared.beginIgnoringInteractionEvents()
        SVProgressHUD.show()
    }
    
    class func hideProgress() {
        print("========== Hide Progress bar ============")
        UIApplication.shared.endIgnoringInteractionEvents()
        SVProgressHUD.dismiss()
    }
    
    class func hidesBackButton(viewController: UIViewController, isHide: Bool) {
        viewController.navigationItem.setHidesBackButton(isHide, animated: true)
    }
    
    class func getDictionaryFromTrainingLocationModel(training_location_model: TrainingLocationModel) -> NSMutableDictionary {
        
        let locationDict = NSMutableDictionary()
        
        locationDict.setValue(training_location_model.locationName, forKey: "trainingLocationName")
        locationDict.setValue(training_location_model.locationLatitude, forKey: "trainingLocationLatitude")
        locationDict.setValue(training_location_model.locationLongitude, forKey: "trainingLocationLongitude")
        
        return locationDict
    }

    class func getTrainingLocationModelObjectFromDictionary(location_dictionary: NSMutableDictionary) -> TrainingLocationModel {
        
        let location_model_obj = TrainingLocationModel()
        
        location_model_obj.locationName = location_dictionary["trainingLocationName"] as! String
        location_model_obj.locationLatitude = location_dictionary["trainingLocationLatitude"] as! String
        location_model_obj.locationLongitude = location_dictionary["trainingLocationLongitude"] as! String
        
        return location_model_obj
    }

}

class ButtonWithShadow: UIButton {
    
    override func draw(_ rect: CGRect) {
        updateLayerProperties()
    }
    
    func updateLayerProperties() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 10.0
        self.layer.masksToBounds = false
    }
}

extension UIView {
    
    func addShadowView(width:CGFloat=2.0, height:CGFloat=2.0, Opacidade:Float=0.7, maskToBounds:Bool=false, radius:CGFloat=2.0){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: width, height: height)
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = Opacidade
        self.layer.masksToBounds = maskToBounds
        self.layer.cornerRadius = 5.0
    }
    
    func addShadowViewToImageView(width:CGFloat=2.0, height:CGFloat=2.0, Opacidade:Float=0.7, maskToBounds:Bool=false, radius:CGFloat=2.0){
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOffset = CGSize(width: width, height: height)
//        self.layer.shadowRadius = radius
//        self.layer.shadowOpacity = Opacidade
//        self.layer.masksToBounds = maskToBounds
//        self.layer.cornerRadius = self.frame.height / 2.0
//        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 5.0).cgPath
        
//        let outerView = UIView(frame: self.frame)
//        outerView.clipsToBounds = false
//        outerView.layer.shadowColor = UIColor.black.cgColor
//        outerView.layer.shadowOpacity = 1
//        outerView.layer.shadowOffset = CGSize.zero
//        outerView.layer.shadowRadius = 10
//        outerView.layer.shadowPath = UIBezierPath(roundedRect: outerView.bounds, cornerRadius: 10).cgPath
    }
}

extension UIViewController {
    
    func dismissOnSessionExpire() {
        
        userDefaults.removeObject(forKey: "user_id")
        userDefaults.removeObject(forKey: "token")
        userDefaults.removeObject(forKey: "userName")
        userDefaults.removeObject(forKey: "userEmailId")
        userDefaults.removeObject(forKey: "userMobileNumber")
        userDefaults.removeObject(forKey: "userType")
        userDefaults.removeObject(forKey: "approvedOrPendingCategoriesIdArray")
        userDefaults.removeObject(forKey: "clientTokenForPayment")
        userDefaults.removeObject(forKey: "paymentNonce")
        userDefaults.removeObject(forKey: "save_preferance")

        ProfileImageDB.deleteImages()
        ProfileDB.deleteProfile()
        
        let controller  = storyboard?.instantiateViewController(withIdentifier: "RegisterorloginViewController") as! RegisterorloginViewController
        //self.presentViewController(controller, animated: true, completion: nil)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
//        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SESSION_EXPIRED, buttonTitle: "Ok")
    }
    
    func setBackButton(){
        
        let yourBackImage = UIImage(named: "back_button")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
    }
}



