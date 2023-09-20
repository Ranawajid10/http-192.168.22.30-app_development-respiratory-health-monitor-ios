//
//  CoughEntity+CoreDataProperties.swift
//  
//
//  Created by Ali Rizwan on 20/09/2023.
//
//

import Foundation
import CoreData


extension CoughEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoughEntity> {
        return NSFetchRequest<CoughEntity>(entityName: "CoughEntity")
    }

    @NSManaged public var value: Float

}
