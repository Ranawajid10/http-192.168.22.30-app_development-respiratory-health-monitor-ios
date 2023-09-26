//
//  HoursUpload+CoreDataProperties.swift
//  
//
//  Created by Ali Rizwan on 27/09/2023.
//
//

import Foundation
import CoreData


extension HoursUpload {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HoursUpload> {
        return NSFetchRequest<HoursUpload>(entityName: "HoursUpload")
    }

    @NSManaged public var dateTime: String?
    @NSManaged public var id: String?
    @NSManaged public var trackedSeconds: Double

}
