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

      class func serverCall(APIURL : String, parameters : Dictionary<String, String>, headers: HTTPHeaders?, onCompletion:@escaping ((_ jsonData: Dictionary<String, Any>) -> Void)){
        
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
    
 
    class func alertView(view : UIViewController, title : String?, message: String?, buttonTitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil))
        
        view.present(alert, animated: true, completion: nil)
    }
}


class Singleton {
    
    var userDefaults = UserDefaults()
    var appdelegate = AppDelegate()
    var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

    static let sharedInstance : Singleton = {
        let instance = Singleton()
        return instance
    }()
    
    init() {
        userDefaults = UserDefaults.standard
        appdelegate = UIApplication.shared.delegate as! AppDelegate
        context = appdelegate.persistentContainer.viewContext
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
