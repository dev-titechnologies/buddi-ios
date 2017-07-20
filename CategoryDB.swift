//
//  CategoryDB+CoreDataClass.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 20/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

@objc(CategoryDB)
public class CategoryDB: NSManagedObject {

    class func createReviewEntry(categoryModel: CategoryModel) {
        
        print("*** Category ID:",categoryModel.categoryId)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CategoryDB")
        fetchRequest.predicate = NSPredicate(format: "categoryId == %@", categoryModel.categoryId)
        
        
        do {
            let categories = try context.fetch(fetchRequest)
            
            if categories.count > 0 {
                print("Category entry present")
                let category = categories[0] as! NSManagedObject
                
                category.setValue(categoryModel.categoryId, forKey: "categoryId")
                category.setValue(categoryModel.categoryImage, forKey: "categoryImage")
                category.setValue(categoryModel.categoryName, forKey: "categoryName")
                category.setValue(categoryModel.categoryDescription, forKey: "categoryDesc")
                
                appDelegate.saveContext()
            }else{
                print("Category entry not present")
                let category = NSEntityDescription.insertNewObject(forEntityName: "CategoryDB", into:context) as! CategoryDB
                
                category.categoryId = categoryModel.categoryId
                category.categoryImage = categoryModel.categoryImage
                category.categoryName = categoryModel.categoryName
                category.categoryDesc = categoryModel.categoryDescription
                
                appDelegate.saveContext()
            }
            
        }catch {
            fatalError("Failed to create Category Entry: \(error)")
        }
    }
    
}
