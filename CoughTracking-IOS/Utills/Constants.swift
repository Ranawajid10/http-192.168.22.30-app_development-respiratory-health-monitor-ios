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
    
    
    static var totalSecondsRecordedToday : Double = 0.0
    
    static let weeklyGraphArray = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat","Sun"]
    
    static let hourlyGraphArray = ["05:00", "10:00", "15:00", "20:00", "25:00", "30:00",
                 "35:00", "40:00", "45:00", "50:00", "55:00", "60:00"]
    
    static var dailyGraphArray = ["00:00", "02:00", "04:00", "06:00", "08:00", "10:00",
                 "12:00", "14:00", "16:00", "18:00", "20:00", "23:00"]
    
    static var notesHours = [
        "00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00",
        "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00",
        "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00",
        "21:00", "22:00", "23:00"
    ]
    
    static let syncOptionsList : [String] = ["Only cough count and cough description", "Cough count, cough description and audios"]
    static let tabList : [String] = [ "Hourly","Daily","Weekly"]
    static let clearHistoryList : [String] = [ "1 Week","2 Week","1 Month"]
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
    static let daily : String =  "daily"
    static let weekly : String =  "weekly"
    static let hourly : String =  "hourly"
    static let next : String =  "next"
    static let previous : String =  "prev"
    static let loginWith : String =  "loginWith"
    static let isFromNotification : String =  "isFromNotification"
    static let scheduledToDate : String =  "scheduledToDate"
    static let isUploadedInThisHour : String =  "isUploadedInThisHour"
    
    
}


struct Connectivity {
  static let sharedInstance = NetworkReachabilityManager()!
  static var isConnectedToInternet:Bool {
      return self.sharedInstance.isReachable
    }
}
