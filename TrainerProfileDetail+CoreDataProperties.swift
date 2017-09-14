//
//  TrainerProfileDetail+CoreDataProperties.swift
//  BuddyApp
//
//  Created by Ti Technologies on 17/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation
import CoreData


extension TrainerProfileDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrainerProfileDetail> {
        return NSFetchRequest<TrainerProfileDetail>(entityName: "TrainerProfileDetail")
    }

    @NSManaged public var profileimage: String?
    @NSManaged public var bookingId: String?
    @NSManaged public var trainerId: String?
    @NSManaged public var traineeId: String?
    @NSManaged public var firstname: String?
    @NSManaged public var lastname: String?
    @NSManaged public var mobile: String?
    @NSManaged public var gender: String?
    @NSManaged public var userId: String?
    @NSManaged public var distance: String?
    @NSManaged public var height: String?
    @NSManaged public var weight: String?
    @NSManaged public var rating: String?
    @NSManaged public var age: String?
    @NSManaged public var lattitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var pickuplocation: String?
    @NSManaged public var pickuplattitude: String?
    @NSManaged public var pickuplongitude: String?


}
