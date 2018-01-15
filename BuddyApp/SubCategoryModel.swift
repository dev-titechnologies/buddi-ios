//
//  SubCategoryModel.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 21/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation

class SubCategoryModel{
    
    var subCategoryId : String = String()
    var subCategoryName : String = String()

    init(){}
    
    func insertSubCategoriesToDB(subCategories:[SubCategoryModel]) {
        
        for subCategory in subCategories{
            print("*** SubCategID:",subCategory.subCategoryId)
//            print("*** SubCategName:",subCategory.subCategoryName)

            SubCategoryDB.createSubCategoryEntry(subCategoryModel: subCategory)
        }
    }
}
