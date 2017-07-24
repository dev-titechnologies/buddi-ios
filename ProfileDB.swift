//
//  ProfileDB+CoreDataClass.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 19/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData

@objc(ProfileDB)
public class ProfileDB: NSManagedObject {

    
    class func createProfileEntry(profileModel: ProfileModel) {
        
        print("*** Review ID:",profileModel.userid)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileDB")
        fetchRequest.predicate = NSPredicate(format: "userId == %@", profileModel.userid)
        
        do {
            let profiles = try context.fetch(fetchRequest)
            
            if profiles.count > 0 {
                print("profile entry present")
                let profile = profiles[0] as! NSManagedObject
                
                profile.setValue(profileModel.firstName, forKey: "firstname")
                profile.setValue(profileModel.lastName, forKey: "lastname")
                profile.setValue(profileModel.email, forKey: "email")
                profile.setValue(profileModel.gender, forKey: "gender")
                profile.setValue(profileModel.mobile, forKey: "mobile")
                profile.setValue(profileModel.userid, forKey: "userId")
                profile.setValue(profileModel.profileImage, forKey: "profileImageURL")
                //profile.setValue(profileModel.profileImageData, forKey: "trainerId")
                
                
                appDelegate.saveContext()
            }else{
                print("profile entry not present")
                let profile = NSEntityDescription.insertNewObject(forEntityName: "ProfileDB", into:context) as! ProfileDB
                
                profile.firstname = profileModel.firstName
                profile.lastname = profileModel.lastName
                profile.gender = profileModel.gender
                profile.email = profileModel.email
                profile.userId = profileModel.userid
                profile.profileImageURL = profileModel.profileImage
                profile.mobile = profileModel.mobile
               
                
                appDelegate.saveContext()
            }
            
        }catch {
            fatalError("Failed to create profile Entry: \(error)")
        }
    }
    class func fetchUser() -> NSArray? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileDB")
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
