//
//  VolunteerCough+CoreDataProperties.swift
//  
//
//  Created by Ali Rizwan on 27/09/2023.
//
//

import Foundation
import CoreData


extension VolunteerCough {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VolunteerCough> {
        return NSFetchRequest<VolunteerCough>(entityName: "VolunteerCough")
    }

    @NSManaged public var coughPower: String?
    @NSManaged public var coughSegments: [[Float]]?
    @NSManaged public var date: String?
    @NSManaged public var id: String?
    @NSManaged public var time: String?

}
