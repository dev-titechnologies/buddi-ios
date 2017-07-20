//
//  CategoryModel.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 20/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
import SwiftyJSON

class CategoryModel{
    
    var categoryName : String = String()
    var categoryId : String = String()
    var categoryDescription : String = String()
    var categoryImage: String = String()
    
    init(){}
    

    //dictionary: Dictionary<String, Any>
    //jsonData: JSON
    func getCategoryModelFromJSONDict(dictionary: Dictionary<String, Any>) -> CategoryModel {
        
        let categoryModel: CategoryModel = CategoryModel()
        
        print("TEST123",dictionary)
        
        
        return categoryModel
    }

}
