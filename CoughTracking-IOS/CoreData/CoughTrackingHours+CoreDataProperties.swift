//
//  CoughTrackingHours+CoreDataProperties.swift
//  
//
//  Created by Ali Rizwan on 20/09/2023.
//
//

import Foundation
import CoreData


extension CoughTrackingHours {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoughTrackingHours> {
        return NSFetchRequest<CoughTrackingHours>(entityName: "CoughTrackingHours")
    }

    @NSManaged public var date: String?
    @NSManaged public var hoursTrack: Double

}
