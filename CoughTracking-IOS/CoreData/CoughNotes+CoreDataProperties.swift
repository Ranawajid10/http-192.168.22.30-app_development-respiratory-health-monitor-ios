//
//  CoughNotes+CoreDataProperties.swift
//  
//
//  Created by Ali Rizwan on 05/10/2023.
//
//

import Foundation
import CoreData


extension CoughNotes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoughNotes> {
        return NSFetchRequest<CoughNotes>(entityName: "CoughNotes")
    }

    @NSManaged public var coughPower: String?
    @NSManaged public var coughSegments: [[Float]]?
    @NSManaged public var date: String?
    @NSManaged public var id: String?
    @NSManaged public var time: String?
    @NSManaged public var url: String?

}
