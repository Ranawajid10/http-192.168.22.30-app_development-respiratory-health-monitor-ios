//
//  DeleteAccount.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 03/10/2023.
//

import Foundation


struct DeleteAccount: Codable {
    
    var detail : String? = nil
    var statusCode        : Int?    = nil
    
    enum CodingKeys: String, CodingKey {
        
        case statusCode = "status_code"
        case detail        = "detail"
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        detail = try values.decodeIfPresent(String.self , forKey: .detail )
        statusCode        = try values.decodeIfPresent(Int.self    , forKey: .statusCode        )
        
    }
    
    init() {
        
    }
    
}
