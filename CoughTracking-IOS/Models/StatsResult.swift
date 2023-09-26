//
//  StatsResult.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 27/09/2023.
//

import Foundation


struct StatsResult: Codable {
    
    var data       : [Stats] = []
    var value      : String = ""
    var filterSlot : String = ""
    var filterBy   : String = ""
    var coughTracked : Int   = 0
    var trackHour  : Double   = 0
    
    enum CodingKeys: String, CodingKey {
        
        case data         = "data"
            case value        = "value"
            case filterSlot   = "filter_slot"
            case filterBy     = "filter_by"
            case coughTracked = "cough_tracked"
            case trackHour    = "track_hour"
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        data       = try (values.decodeIfPresent([Stats]?.self , forKey: .data       ) ?? []) ?? []
        value      = try values.decodeIfPresent(String.self , forKey: .value      ) ?? ""
        filterSlot = try values.decodeIfPresent(String.self , forKey: .filterSlot ) ?? ""
        filterBy   = try values.decodeIfPresent(String.self , forKey: .filterBy   ) ?? ""
        coughTracked = try values.decodeIfPresent(Int.self    , forKey: .coughTracked ) ?? 0
        trackHour  = try values.decodeIfPresent(Double.self    , forKey: .trackHour  ) ?? 0.0
        
    }
    
    init() {
        
    }
    
}
