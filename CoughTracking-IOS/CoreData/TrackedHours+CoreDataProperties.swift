//
//  TrackedHours+CoreDataProperties.swift
//  
//
//  Created by Ali Rizwan on 27/09/2023.
//
//

import Foundation
import CoreData


extension TrackedHours {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackedHours> {
        return NSFetchRequest<TrackedHours>(entityName: "TrackedHours")
    }

    @NSManaged public var date: String?
    @NSManaged public var id: String?
    @NSManaged public var secondsTrack: Double

}
