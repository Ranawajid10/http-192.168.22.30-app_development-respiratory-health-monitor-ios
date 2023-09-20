//
//  CoughBaseline+CoreDataProperties.swift
//  
//
//  Created by Ali Rizwan on 20/09/2023.
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
    @NSManaged public var coughSegments: NSSet?

}

// MARK: Generated accessors for coughSegments
extension CoughBaseline {

    @objc(addCoughSegmentsObject:)
    @NSManaged public func addToCoughSegments(_ value: CoughEntity)

    @objc(removeCoughSegmentsObject:)
    @NSManaged public func removeFromCoughSegments(_ value: CoughEntity)

    @objc(addCoughSegments:)
    @NSManaged public func addToCoughSegments(_ values: NSSet)

    @objc(removeCoughSegments:)
    @NSManaged public func removeFromCoughSegments(_ values: NSSet)

}
