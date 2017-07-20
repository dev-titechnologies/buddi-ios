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
    
    func getCategoryModelFromJSONDict(dictionary: Dictionary<String, Any>) -> [CategoryModel] {
        
        var categoryArray = [CategoryModel]()
        let categories = (dictionary["data"] as! NSArray) as Array
        for category in categories{
            
            let categoryModel: CategoryModel = CategoryModel()
            categoryModel.categoryId = String(describing: category["category_id"]!!)
            categoryModel.categoryName = category["category_name"] as! String
            categoryModel.categoryDescription = category["category_desc"] as! String
            categoryModel.categoryImage = category["category_image"] as! String
            categoryArray.append(categoryModel)
        }
        return categoryArray
    }

    func insertCategoriesToDB(categories:[CategoryModel]) {
        
        for category in categories{
            print("*** CategID:",category.categoryId)
            CategoryDB.createCategoryEntry(categoryModel: category)
        }
    }
    
}
