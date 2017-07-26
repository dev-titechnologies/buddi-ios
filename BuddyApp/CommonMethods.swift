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

class CommonMethods: NSObject {
    
    
    
    

      class func serverCall(APIURL : String, parameters : Dictionary<String, Any>, headers: HTTPHeaders?, onCompletion:@escaping ((_ jsonData: Dictionary<String, Any>) -> Void)){
        
        let FinalURL = SERVER_URL_Local + APIURL
        print("Final Server URL:",FinalURL)
        Alamofire.request(FinalURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
            case .success:
                print(response)
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

 
    class func alertView(view : UIViewController, title : String?, message: String?, buttonTitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil))
        
        view.present(alert, animated: true, completion: nil)
    }
    
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
    }

}
extension UIViewController {
    
    func dismissOnSessionExpire() {
        //   if let presentingController = self.presentingViewController as? UINavigationController {
      
        
        
        // presentingController.popToRootViewControllerAnimated(true)
        let controller  = storyboard?.instantiateViewController(withIdentifier: "RegisterChoiceViewController") as! RegisterChoiceViewController
        //self.presentViewController(controller, animated: true, completion: nil)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
        // UIAlertView(title: "", message: ErrorMessage.sessionOut, delegate: nil, cancelButtonTitle: "OK").show()
        //dismissViewControllerAnimated(true, completion: nil)
        // }
        
}
}


