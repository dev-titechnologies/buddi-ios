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
}


class Singleton {
    
    var userDefaults = UserDefaults()
    var appdelegate = AppDelegate()
    var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    var selectedSubCategories : [SubCategoryModel] = [SubCategoryModel]()

    static let sharedInstance : Singleton = {
        let instance = Singleton()
        return instance
    }()
    
    init() {
        userDefaults = UserDefaults.standard
        appdelegate = UIApplication.shared.delegate as! AppDelegate
        context = appdelegate.persistentContainer.viewContext
        selectedSubCategories = [SubCategoryModel]()
    }   
}

public extension Data{
    
    static func ts_dataFromJSONFile(_ fileName: String) -> Data? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
                return data
            } catch let error as NSError {
                print(error.localizedDescription)
                return nil
            }
        } else {
            print("Invalid filename/path.")
            return nil
        }
    }
}

public extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>(_ aClass: T.Type) -> T! {
        let name = String(describing: aClass)
        guard let cell = dequeueReusableCell(withIdentifier: name) as? T else {
            fatalError("\(name) is not registed")
        }
        return cell
    }
}
