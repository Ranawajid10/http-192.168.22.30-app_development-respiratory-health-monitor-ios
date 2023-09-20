//
//  Functions.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 07/09/2023.
//

import Foundation
import CoreData


class Functions{
    
    
    static  func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    
    static func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let date = Date(timeIntervalSince1970: TimeInterval(hour * 3600)) // Convert hours to seconds
        return formatter.string(from: date)
    }
    
}


@objc(MyCustomTransformer)
final class MyCustomTransformer: NSSecureUnarchiveFromDataTransformer {
    override class var allowedTopLevelClasses: [AnyClass] {
        return [NSArray.self, NSDictionary.self, NSNumber.self, NSString.self]
        // Add any other classes that your `[[Float]]` array might contain.
    }
}
