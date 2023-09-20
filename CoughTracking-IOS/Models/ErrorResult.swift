//
//  ErrorResult.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 05/09/2023.
//

import Foundation


struct ErrorResult:Error, Codable {

  var detail : [ApiError] = []

  enum CodingKeys: String, CodingKey {

    case detail = "detail"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    detail = try values.decodeIfPresent([ApiError].self , forKey: .detail ) ?? []
 
  }

  init() {

  }

}
