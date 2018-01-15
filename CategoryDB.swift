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

    class func createCategoryEntry(categoryModel: CategoryModel) {
        
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
    
    class func getCategoryByCategoryID(categoryId: String) -> String {
        var categoryName = String()
        
        print("*** Category ID:",categoryId)
    
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CategoryDB")
        fetchRequest.predicate = NSPredicate(format: "categoryId == %@", categoryId)
        
        do {
            let category = try context.fetch(fetchRequest)
            let categ = category[0] as! NSManagedObject
            print(categ)
            categoryName = categ.value(forKey: "categoryName") as! String
            print(categoryName)
            return categoryName

        }catch {
            fatalError("Failed to create Category Entry: \(error)")
        }
    }
    
    class func deleteCategoryDB(){
        
        print("** deleteCategoryDB **")
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CategoryDB")
        do {
            if let result = try? context.fetch(fetchRequest) {
                for object in result {
                    context.delete(object as! NSManagedObject)
                }
                
                appDelegate.saveContext()
            }
            
        } catch {
            
        }
    }

}
