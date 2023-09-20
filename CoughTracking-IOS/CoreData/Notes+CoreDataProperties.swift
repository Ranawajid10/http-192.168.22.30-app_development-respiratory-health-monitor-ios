//
//  Notes+CoreDataProperties.swift
//  
//
//  Created by Ali Rizwan on 20/09/2023.
//
//

import Foundation
import CoreData


extension Notes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notes> {
        return NSFetchRequest<Notes>(entityName: "Notes")
    }

    @NSManaged public var date: String?
    @NSManaged public var id: String?
    @NSManaged public var note: String?
    @NSManaged public var time: String?

}
