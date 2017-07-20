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
    
    

    class func serverCall(APIURL : String, parameters : Dictionary<String, String>, headers: Dictionary<String, String>, onCompletion:@escaping ((_ jsonData: JSON) -> Void)){
        
        let FinalURL = SERVER_URL_Local + APIURL
        Alamofire.request(FinalURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
            case .success:
                print(response)
                if let value = response.value {
                    let json = JSON(value)
                    onCompletion(json)
                }
                break
            case .failure(let error):
                
                print(error)
                onCompletion(error as! JSON)
            }
        }
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
