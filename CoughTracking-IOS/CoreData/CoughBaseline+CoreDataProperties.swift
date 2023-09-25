//
//  CoughBaseline+CoreDataProperties.swift
//  
//
//  Created by Ali Rizwan on 25/09/2023.
//
//

import Foundation
import CoreData


extension CoughBaseline {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoughBaseline> {
        return NSFetchRequest<CoughBaseline>(entityName: "CoughBaseline")
    }

    @NSManaged public var createdOn: String?
    @NSManaged public var uid: String?
    @NSManaged public var coughSegments: [[Float]]?

}
