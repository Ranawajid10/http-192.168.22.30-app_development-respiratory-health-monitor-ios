//
//  DateFormats.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 25/09/2023.
//

import Foundation


class DateTimeFormats{
    
    static let dateFormat1 = "yyyy-MM-dd" // 2023-09-28
    static let dateFormat2 = "yyyy-MM-dd Z" // 2023-09-28
   
    static let timeFormat1 = "hh:mm:ss"
    static let timeFormat2 = "HH"
    static let timeFormat3 = "HH:mm:ss"
    static let timeFormat4 = "hh a"
  
    static let dateTimeFormat1 = "yyyy-MM-dd-hh:mm:ss"
    static let dateTimeFormat2 = "yyyy-MM-dd'T'HH:mm:ss" // 2023-10-03T14:35:38
    static let dateTimeFormat3 = "yyyy-MM-dd-HH:mm:ss" // 2023-09-28-16:41:53
    static let dateTimeFormat4 = "yyyy-MM-dd HH:mm:ss Z" // 2023-09-27 13:15:32 +0000  retuns this Date()
    
}
