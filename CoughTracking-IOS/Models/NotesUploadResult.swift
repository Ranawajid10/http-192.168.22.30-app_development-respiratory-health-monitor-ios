//
//  NotesUploadResult.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 09/10/2023.
//

import Foundation


struct NotesUploadResult: Codable {

  var status : Int?    = nil
  var detail : String? = nil

  enum CodingKeys: String, CodingKey {

    case status = "status"
    case detail = "detail"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    status = try values.decodeIfPresent(Int.self    , forKey: .status )
    detail = try values.decodeIfPresent(String.self , forKey: .detail )
 
  }

  init() {

  }

}
