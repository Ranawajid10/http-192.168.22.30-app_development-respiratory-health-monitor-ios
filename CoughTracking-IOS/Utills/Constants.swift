//
//  Constants.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 22/08/2023.
//

import Foundation
import Alamofire


class Constants{
    
    
    static let googleClientID : String =  "163015622468-43kq6hrmffd8ipnhjne1n7to31hf5ubn.apps.googleusercontent.com"
//    static let googleClientID : String =  "163015622468-79fajd2tmftat3qhc1a16nejimm0q28g.apps.googleusercontent.com"
    
    
    
    static let syncOptionsList : [String] = ["Only cough count and cough description", "Cough count, cough description and audios"]
    static let tabList : [String] = [ "Hourly","Daily","Weekly"]
    static let clearHistoryList : [String] = [ "1 Week","2 Week","1 Month","All"]
    static let genderList : [String] = [ "Male","Female","Others"]
    static let ethnicityList: [String] = ["Chinese","Indian","Pakistani","Nigerian","German","Japanese","Mexican","Korean","Russian","Italian","French","British","Egyptian","Brazilian","Thai","Australian","Canadian","American","Turkish","Spanish","Swedish"
    ]
    static let email : String =  "email"
    static let otp : String =  "otp"
    static let google : String =  "google"
    static let facebook : String =  "facebook"
    static let twitter : String =  "twitter"
    static let simple : String =  "simple"
    static let isLoggedIn : String =  "isLoggedIn"
    static let isBaseLineSet : String =  "isBaseLineSet"
    static let baseLineLoudness : String =  "baseLineLoudness"
    static let userData : String =  "userData"
    static let image : String =  "image"
    static let isMicStopbyUser : String =  "isMicStopbyUser"
    static let isStatisticsOn : String =  "isStatisticsOn"
    static let isCoughStatOn : String =  "isCoughStatOn"
    static let isFirstSync : String =  "isFirstSync"
    static let isAutoSync : String =  "isAutoSync"
    static let isShareWithDoctor : String =  "isShareWithDoctor"
    static let shareWithDoctor : String =  "shareWithDoctor"
    static let isDonateForResearch : String =  "isDonateForResearch"
    static let donateForResearch : String =  "donateForResearch"
    static let isAutoDonate : String =  "isAutoDonate"
    static let isAllowSync : String =  "isAllowSync"
    static var totalSecondsRecordedToday : Double = 0.0
    
    
}


struct Connectivity {
  static let sharedInstance = NetworkReachabilityManager()!
  static var isConnectedToInternet:Bool {
      return self.sharedInstance.isReachable
    }
}
