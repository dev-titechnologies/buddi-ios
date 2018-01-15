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
    var subCategories : [SubCategoryModel] = [SubCategoryModel]()
    var categoryStatus : String = String()
    
    init(){}
    
    func getCategoryModelFromJSONDict(dictionary: Dictionary<String, Any>) -> ([CategoryModel],[SubCategoryModel]) {
        
        var categoryArray = [CategoryModel]()
        var subCategoryArray = [SubCategoryModel]()

        let categories = (dictionary["data"] as! NSArray) as Array
        for category in categories{
            
            let categoryModel: CategoryModel = CategoryModel()
            var subCategoryArrayCopy = [SubCategoryModel]()
            
            categoryModel.categoryId = String(describing: category["category_id"]!!)
            categoryModel.categoryName = category["category_name"] as! String
            categoryModel.categoryDescription = category["category_desc"] as! String
            categoryModel.categoryImage = category["category_image"] as! String
            
            //Getting SubCategories
            let subCategories = (category["sub_categories"] as! NSArray) as Array

            for subcategory in subCategories{
                let subCategoryModel: SubCategoryModel = SubCategoryModel()

                subCategoryModel.subCategoryId = String(describing: subcategory["subCat_id"]!!)
                subCategoryModel.subCategoryName = subcategory["subCat_name"] as! String
                
                subCategoryArrayCopy.append(subCategoryModel)
                subCategoryArray.append(subCategoryModel)
            }
            
            categoryModel.subCategories = subCategoryArrayCopy
            categoryArray.append(categoryModel)
        }
        return (categoryArray,subCategoryArray)
    }

    func insertCategoriesToDB(categories:[CategoryModel]) {
        
        for category in categories{
            print("*** CategID:",category.categoryId)
            print("*** CategName:",category.categoryName)

            CategoryDB.createCategoryEntry(categoryModel: category)
        }
    }
    
}
