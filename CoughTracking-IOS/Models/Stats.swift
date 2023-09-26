//
//  Stats.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 27/09/2023.
//

import Foundation


struct Stats: Codable {
    
    var label        : String? = nil
    var timeInterval : String? = nil
    var count        : Int?    = nil
    
    enum CodingKeys: String, CodingKey {
        
        case label        = "label"
        case timeInterval = "time_interval"
        case count        = "count"
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        label        = try values.decodeIfPresent(String.self , forKey: .label        )
        timeInterval = try values.decodeIfPresent(String.self , forKey: .timeInterval )
        count        = try values.decodeIfPresent(Int.self    , forKey: .count        )
        
    }
    
    init() {
        
    }
    
}
