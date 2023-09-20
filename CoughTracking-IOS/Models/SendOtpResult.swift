//
//  SendOtpResult.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 07/09/2023.
//

import Foundation

struct SendOtpResult: Codable {

  var statusCode : Int?    = nil
  var detail     : String = ""
  var otp        : Int   = 0
  var email      : String? = nil

  enum CodingKeys: String, CodingKey {

    case statusCode = "status_code"
    case detail     = "detail"
    case otp        = "otp"
    case email      = "email"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    statusCode = try values.decodeIfPresent(Int.self    , forKey: .statusCode )
    detail     = try values.decodeIfPresent(String.self , forKey: .detail     ) ?? ""
    otp        = try values.decodeIfPresent(Int.self    , forKey: .otp        ) ?? 0
    email      = try values.decodeIfPresent(String.self , forKey: .email      )
 
  }

  init() {

  }

}
