//
//  CoughRecordingsResult.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 03/10/2023.
//

import Foundation


struct CoughRecordingsResult: Codable {

  var datetime     : String? = nil
  var recId        : Int?    = nil
  var recIntensity : String? = nil
  var recType      : String? = nil
  var recPath      : String? = nil
  var date         : String? = nil
  var time         : String? = nil
  var timeMin      : Int?    = nil
  var timeMins     : String? = nil
  var url          : String? = nil

  enum CodingKeys: String, CodingKey {

    case datetime     = "datetime"
    case recId        = "rec_id"
    case recIntensity = "rec_intensity"
    case recType      = "rec_type"
    case recPath      = "rec_path"
    case date         = "date"
    case time         = "time"
    case timeMin      = "time_min"
    case timeMins     = "timeMins"
    case url          = "url"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    datetime     = try values.decodeIfPresent(String.self , forKey: .datetime     )
    recId        = try values.decodeIfPresent(Int.self    , forKey: .recId        )
    recIntensity = try values.decodeIfPresent(String.self , forKey: .recIntensity )
    recType      = try values.decodeIfPresent(String.self , forKey: .recType      )
    recPath      = try values.decodeIfPresent(String.self , forKey: .recPath      )
    date         = try values.decodeIfPresent(String.self , forKey: .date         )
    time         = try values.decodeIfPresent(String.self , forKey: .time         )
    timeMin      = try values.decodeIfPresent(Int.self    , forKey: .timeMin      )
    timeMins     = try values.decodeIfPresent(String.self , forKey: .timeMins     )
    url          = try values.decodeIfPresent(String.self , forKey: .url          )
 
  }

  init() {

  }

}
