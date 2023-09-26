//
//  TrackedMinutes.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 27/09/2023.
//

import Foundation


struct TrackedMinutes: Codable{
    
    var date:String = ""
    var minutes:Double = 0.0
    
    var minutesString: String {
            return String(format: "%.2f", minutes)
    }
}
