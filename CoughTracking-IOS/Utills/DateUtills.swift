//
//  DateUtills.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 25/08/2023.
//

import Foundation

class DateUtills{
    
    
    
   static func getCurrentTimeInMilliseconds() -> String {
       let currentTimeMillis = Int64(Date().timeIntervalSince1970 * 1000)
       return String(currentTimeMillis)
   }

    
    
}
