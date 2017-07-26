//
//  ProfileImageDB+CoreDataClass.swift
//  BuddyApp
//
//  Created by Ti Technologies on 26/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

@objc(ProfileImageDB)
public class ProfileImageDB: NSManagedObject {
    
    class func save(imageURL: String, imageData: NSData){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileImageDB")
        
        
        do {
            let images = try context.fetch(fetchRequest)
            
            if images.count > 0 {
                
                print("image entry present")
                let image = images[0] as! NSManagedObject

                image.setValue(imageURL, forKey: "imageUrl")
                image.setValue(imageData, forKey: "imageData")
                appDelegate.saveContext()
                
            }
            else
            {
                print("No image present")
                let imagedb = NSEntityDescription.insertNewObject(forEntityName: "ProfileImageDB", into:context) as! ProfileImageDB
                
                imagedb.imageUrl = imageURL
                imagedb.imageData = imageData
                
                
                appDelegate.saveContext()
                
            }
            
        }catch {
            fatalError("Failed to create profile Entry: \(error)")
        }

    }
    
    class func fetchImage() -> NSArray? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileImageDB")
        var fetchResult = NSArray()
        
        do {
            let profiles = try context.fetch(fetchRequest)
            
            
            fetchResult = profiles as NSArray
            print("fetchResult",fetchResult)
            
        } catch{
        }
        return fetchResult
    }
    
   
}
