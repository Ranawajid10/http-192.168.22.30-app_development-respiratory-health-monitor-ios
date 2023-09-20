//
//  ApiError.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 05/09/2023.
//

import Foundation


struct ApiError: Codable {

  var loc  : String? = nil
  var msg  : String? = nil
  var type : String? = nil

  enum CodingKeys: String, CodingKey {

    case loc  = "loc"
    case msg  = "msg"
    case type = "type"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    loc  = try values.decodeIfPresent(String.self , forKey: .loc  )
    msg  = try values.decodeIfPresent(String.self , forKey: .msg  )
    type = try values.decodeIfPresent(String.self , forKey: .type )
 
  }

  init() {

  }

}
