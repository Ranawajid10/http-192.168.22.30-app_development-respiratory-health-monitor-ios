//
//  LoginResult.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 18/09/2023.
//

import Foundation


struct LoginResult: Codable {

  var statusCode        : Int?    = nil
  var detail            : String? = nil
  var email             : String = ""
  var token             : String? = nil
  var name              : String = ""
  var gender            : String? = nil
  var age               : Int?    = nil
  var medicalConditions : String? = nil
  var ethnicity         : String? = nil
  var purposeOfUsing    : String? = nil

  enum CodingKeys: String, CodingKey {

    case statusCode        = "status_code"
    case detail            = "detail"
    case email             = "email"
    case token             = "token"
    case name              = "name"
    case gender            = "gender"
    case age               = "age"
    case medicalConditions = "medical_conditions"
    case ethnicity         = "ethnicity"
    case purposeOfUsing    = "purpose_of_using"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    statusCode        = try values.decodeIfPresent(Int.self    , forKey: .statusCode        )
    detail            = try values.decodeIfPresent(String.self , forKey: .detail            )
    email             = try values.decodeIfPresent(String.self , forKey: .email             ) ?? ""
    token             = try values.decodeIfPresent(String.self , forKey: .token             )
    name              = try values.decodeIfPresent(String.self , forKey: .name              ) ?? ""
    gender            = try values.decodeIfPresent(String.self , forKey: .gender            )
    age               = try values.decodeIfPresent(Int.self    , forKey: .age               )
    medicalConditions = try values.decodeIfPresent(String.self , forKey: .medicalConditions )
    ethnicity         = try values.decodeIfPresent(String.self , forKey: .ethnicity         )
    purposeOfUsing    = try values.decodeIfPresent(String.self , forKey: .purposeOfUsing    )
 
  }

  init() {

  }

}
