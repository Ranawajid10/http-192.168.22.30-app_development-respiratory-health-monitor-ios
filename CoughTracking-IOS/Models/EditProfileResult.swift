//
//  EditProfileResult.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 21/09/2023.
//

import Foundation


struct EditProfileResult: Codable {

  var name : String? = nil
  var url  : String? = nil

  enum CodingKeys: String, CodingKey {

    case name = "name"
    case url  = "url"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    name = try values.decodeIfPresent(String.self , forKey: .name )
    url  = try values.decodeIfPresent(String.self , forKey: .url  )
 
  }

  init() {

  }

}
