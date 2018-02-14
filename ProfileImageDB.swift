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
        
        print("****** Image Save to DB *******")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileImageDB")
//         print("IMGAE",imageURL)
//         print("IMGDATA",imageData)
        
        do {
            
//            var privateMoc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//            privateMoc = appDelegate.persistentContainer.viewContext
            
            let images = try privateMoc.fetch(fetchRequest)
            
            if images.count > 0 {
                
                print("image entry present")
                let image = images[0] as! NSManagedObject
                image.setValue(imageURL, forKey: "imageUrl")
                image.setValue(imageData, forKey: "imageData")
                
                do {
                    try privateMoc.save()
                } catch {
                    print("ERROR 1234:\(error)")
                }
            } else{
                print("No image present")
                let imagedb = NSEntityDescription.insertNewObject(forEntityName: "ProfileImageDB", into:privateMoc) as! ProfileImageDB
                
                imagedb.imageUrl = imageURL
                imagedb.imageData = imageData
                
                do {
                    print("******* Image Saved to DB *******")
                    try privateMoc.save()
                } catch {
                    print("ERROR 1234:\(error)")
                }
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
            fatalError("Failed to create profile Entry: \(error)")
        }
        return fetchResult
    }
    
    class func deleteImages(){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileImageDB")
        do {
            if let result = try? context.fetch(fetchRequest) {
                for object in result {
                    context.delete(object as! NSManagedObject)
                }
                
                appDelegate.saveContext()
            }
            
        } catch {
            fatalError("Failed to create profile Entry: \(error)")
        }
    }
  
   
}
