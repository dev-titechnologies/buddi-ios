//
//  SubCategoryDB+CoreDataClass.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 21/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

@objc(SubCategoryDB)
public class SubCategoryDB: NSManagedObject {

    
    class func createSubCategoryEntry(subCategoryModel: SubCategoryModel) {
        
        print("*** SubCategory ID:",subCategoryModel.subCategoryId)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SubCategoryDB")
        fetchRequest.predicate = NSPredicate(format: "subCategoryId == %@", subCategoryModel.subCategoryId)
        
        do {
            let subCategories = try context.fetch(fetchRequest)
            
            if subCategories.count > 0 {
                print("SubCategory entry present")
                let subcategory = subCategories[0] as! NSManagedObject
                
                subcategory.setValue(subCategoryModel.subCategoryId, forKey: "subCategoryId")
                subcategory.setValue(subCategoryModel.subCategoryName, forKey: "subCategoryName")
                print("Updating Datas to SubCategory Table:", subcategory)
                
                appDelegate.saveContext()
            }else{
                print("SubCategory entry not present")
                let subCategory = NSEntityDescription.insertNewObject(forEntityName: "SubCategoryDB", into:context) as! SubCategoryDB
                
                subCategory.subCategoryId = subCategoryModel.subCategoryId
                subCategory.subCategoryName = subCategoryModel.subCategoryName
                print("Entering Datas to SubCategory Table:", subCategory)

                appDelegate.saveContext()
            }
        }catch {
            fatalError("Failed to create SubCategory Entry: \(error)")
        }
    }
    
//    class func fetchAllSubCategories() {
//        
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SubCategoryDB")
//
//        do {
//            let subCategories = try context.fetch(fetchRequest)
//            print("*** SUBCATEG:",subCategories)
//        }catch {
//            fatalError("Failed to create SubCategory Entry: \(error)")
//        }
//    }
}


