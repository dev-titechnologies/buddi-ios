//
//  DataExtension.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 26/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
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
