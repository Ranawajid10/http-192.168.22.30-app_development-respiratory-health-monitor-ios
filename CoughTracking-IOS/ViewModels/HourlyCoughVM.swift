//
//  HourlyCoughVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 28/09/2023.
//

import Foundation
import CoreData

class HourlyCoughVM:ObservableObject{
    
    
    @Published var allCoughList:[Cough] = []
    @Published var hourTrackedList:[TrackedHours] = []
    
    @Published var totalCoughCount:Int = 0
    @Published var totalTrackedHours:Double = 0.0
    @Published var coughsPerHour:Int = 0
    
    @Published var goNext:Bool = false
    
    @Published var loaderPos = 0
    @Published var isLoading = false
    @Published var isError = false
    @Published var errorMessage = ""
    
    @Published var date = ""
    @Published var isCurrentDateData = false
    @Published var statsResult = StatsResult()
    
    @Published  var selectedDate = Date()
    @Published  var currentHour = Calendar.current.component(.hour, from: Date())
    
    @Published var moderateTimeData: [String: Int] = [:]
    @Published var severeTimeData: [String: Int] = [:]
    
    @Published var sortedModerateTimeDataDictionary: [(key: String, value: Int)]  = []
    @Published var sortedSevereTimeDataDictionary: [(key: String, value: Int)] = []
    
    @Published var changeGraph:Int = 0
    
    @Published var userData = LoginResult()
    
    func nextHour() {
        
        loaderPos = 0
        currentHour = (currentHour + 1) % 24
        
        if(currentHour==0){
            
            next()
            
        }else{
            
            getGraphData()
            
        }
        
    }
    
    func previousHour() {
        
        loaderPos = 1
        currentHour = (currentHour - 1 + 24) % 24
        
        if(currentHour==0){
            
            previous()
            
        }else{
            
            getGraphData()
            
        }
    }
    
   
    
    func next(){
        
        loaderPos = 2
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? Date()
        if tomorrow <= Date() {
            selectedDate = tomorrow
        }
        
        getGraphData()
    }
    
    func previous(){
        
        loaderPos = 3
        
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? Date()
        
        getGraphData()
        
    }
    
    
    func isToday(_ date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    
    func calculateCurrentCoughHours(){
        
        totalTrackedHours = 0
        coughsPerHour = 0
        var currentDateCough = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        let dateString = dateFormatter.string(from: selectedDate)
        
        var totalSeconds = 0.0
        
        for second in hourTrackedList {
            
            if(dateString == second.date){
                
                totalSeconds+=second.secondsTrack
                
            }
            
        }
        
        
        for cough in allCoughList {
            
            if(dateString == cough.date){
                
                currentDateCough+=1
                
            }
            
        }
        
        let hours =  totalSeconds/3600.0
        
        
        if(hours<1){
            
            totalTrackedHours = 1.0
            
        }else{
            
            totalTrackedHours =  totalSeconds/3600.0
            
        }
        
        //        totalTrackedHours = totalSeconds/3600.0
        //        print("coughsPerHour","0","--",totalCoughCount,"--",totalTrackedHours)
        
        
        //        if(Int(totalTrackedHours) > 1 && totalCoughCount > 1){
        
        coughsPerHour = currentDateCough / Int(totalTrackedHours)
        print("coughsPerHour","1",coughsPerHour,"--",totalCoughCount)
        //
        //        }else{
        //
        //            coughsPerHour = 0
        //            print("coughsPerHour","2",coughsPerHour,"--",totalCoughCount)
        //
        //        }
    }
    
    
    func getGraphData(){
        
        let (currentDateCoughs,times) = getCurrentCoughs(hour:currentHour)
        
        if(currentDateCoughs.count==0 && Connectivity.isConnectedToInternet){
            
            getDataFromDB(filterSlot: Constants.hourly)
            return
        }
        
        totalCoughCount = currentDateCoughs.count
        
        moderateTimeData.removeAll()
        severeTimeData.removeAll()
        
        
        for hour in Constants.hourlyGraphArray {
            moderateTimeData[hour, default: 0] = 0
            severeTimeData[hour, default: 0] = 0
        }
        
        
        
        for cough in currentDateCoughs {
            guard let coughTime = cough.time else {
                continue
            }
            
            // Extract the minutes part from the cough time (e.g., "11:42:54" -> "42")
            let minutes = coughTime.dropFirst(3).dropLast(3)
            
            // Initialize variables to track whether the cough time falls within an interval
            var isWithinInterval = false
            var mainIndex = ""
            
            for (index, interval) in Constants.hourlyGraphArray.enumerated() {
                
                
                if index < Constants.hourlyGraphArray.count - 1 {
                    // Extract start and end minutes of the interval
                    let startMinutes = interval.dropLast(3)
                    let endMinutes = Constants.hourlyGraphArray[index + 1].dropLast(3)
                    
                    
                    
                    if (minutes >= startMinutes) && minutes < endMinutes {
                        isWithinInterval = true
                        mainIndex = Constants.hourlyGraphArray[index + 1]
                        break
                    }
                    
                    if(minutes<startMinutes){
                        isWithinInterval = true
                        mainIndex = Constants.hourlyGraphArray[index]
                        break
                    }
                    
                }
            }
            
            if isWithinInterval {
                let coughType = cough.coughPower
                
                if coughType == "moderate" {
                    moderateTimeData[mainIndex, default: 0] += 1
                } else if coughType == "severe" {
                    severeTimeData[mainIndex, default: 0] += 1
                }
            }
        }
        
        
        // Create a new dictionary with sorted keys and their corresponding values
        sortedModerateTimeDataDictionary.removeAll()
        sortedSevereTimeDataDictionary.removeAll()
        
        let moderateList = moderateTimeData.sorted { v1, v2 in
            
            let a = v1.key.dropLast(3)
            let b = v2.key.dropLast(3)
            
            return a < b
        }
        
        sortedModerateTimeDataDictionary = moderateList
        
        
        let severeList = severeTimeData.sorted { v1, v2 in
            
            let a = v1.key.dropLast(3)
            let b = v2.key.dropLast(3)
            
            return a < b
        }
        
        sortedSevereTimeDataDictionary = severeList
        
        //        withAnimation {
        
        calculateCurrentCoughHours()
        
        changeGraph+=1
        
        //        }
        
    }
    
    func getCurrentCoughs(hour:Int) -> ([Cough],[String]){
        
        let finalHour = String(format: "%02d", hour)
        
        var currentDateCoughsList:[Cough] = []
        
        var coughTimes: [String] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        let dateString = dateFormatter.string(from: selectedDate)
        
        
        for cough in allCoughList {
            
            
            if cough.date == dateString {
                
                let coughTime = cough.time?.components(separatedBy: ":").first ?? ""
                
                
                if(coughTime == finalHour){
                    
                    coughTimes.append(coughTime)
                    currentDateCoughsList.append(cough)
                }
                
            }
            
            
            
        }
        
        
        return (currentDateCoughsList,coughTimes)
    }
    
 
    func getDataFromDB(filterSlot:String){
     
        isLoading = true
        
        if(date==""){
            
            isCurrentDateData = true
            
        }else{
            
            isCurrentDateData = false
            date = statsResult.value
            
        }
        
        let finalHour = String(format: "%02d", currentHour)
        
       
        let date = DateUtills.dateToString(date: selectedDate, dateFormat: DateTimeFormats.dateTimeFormat4)
        
        let ddate = DateUtills.changeDateFormat(date: date, oldFormat: DateTimeFormats.dateTimeFormat4, newFormat: DateTimeFormats.dateFormat1)
       
        let time = DateUtills.stringToDate(date: finalHour, dateFormat: DateTimeFormats.timeFormat2)
        let ttime = DateUtills.dateToString(date: time, dateFormat: DateTimeFormats.timeFormat2)
        
        let tttime = DateUtills.changeDateFormat(date: ttime, oldFormat: DateTimeFormats.timeFormat2, newFormat: DateTimeFormats.timeFormat3)
//        DateUtills.getCurrentDateInString(format:DateTimeFormats.timeFormat1)
        
        
        let finalDate = "\(ddate)T\(tttime)"
        
        
        ApiClient.shared.getStats(filterBy:Constants.hourly,date:finalDate,filterSlot:filterSlot, isDailyCurrent: isCurrentDateData, token: userData.token ?? ""){ [self] response in
            
            isLoading = false
            isError = false
            
            switch response {
            case .success(let success):
                
                statsResult = success
                
               
                setApiData()
                
                break
            case .failure(let failure):
                
                errorMessage = failure.localizedDescription
                isError = true
                
                break
            }
            
        }
        
        
        
    }
    
    func setApiData() {
        
        totalCoughCount = statsResult.coughTracked
        
        totalTrackedHours = 0
        coughsPerHour = 0
        
        let hours =  statsResult.trackHour
        
        
        if(hours<1){
            
            totalTrackedHours = 1
            
        }else{
            
            totalTrackedHours =  Double(hours)
            
        }
        
        coughsPerHour = totalCoughCount / Int(totalTrackedHours)
        
        
        moderateTimeData.removeAll()
        severeTimeData.removeAll()
        
        
        for hour in Constants.dailyGraphArray {
            moderateTimeData[hour, default: 0] = 0
            severeTimeData[hour, default: 0] = 0
        }
        
        for stat in statsResult.data {
            
            
            // Extract the minutes part from the cough time (e.g., "11:42:54" -> "42")
            let minutes = stat.timeInterval?.dropLast(6) ?? ""
            
            
            // Initialize variables to track whether the cough time falls within an interval
            var isWithinInterval = false
            var mainIndex = ""
            
            for (index, interval) in Constants.dailyGraphArray.enumerated() {
                if index < Constants.dailyGraphArray.count - 1 {
                    // Extract start and end minutes of the interval
                    let startMinutes = interval.dropLast(3)
                    let endMinutes = Constants.dailyGraphArray[index + 1].dropLast(3)
                    
                    if minutes >= startMinutes && minutes < endMinutes {
                        isWithinInterval = true
                        mainIndex = Constants.dailyGraphArray[index + 1]
                        break
                    }
                }
            }
            
            if isWithinInterval {
                let coughType = stat.label
                
                if coughType == "moderate" {
                    moderateTimeData[mainIndex, default: 0] += 1
                } else if coughType == "severe" {
                    severeTimeData[mainIndex, default: 0] += 1
                }
            }
            
            
        }

        
        // Create a new dictionary with sorted keys and their corresponding values
        sortedModerateTimeDataDictionary.removeAll()
        sortedSevereTimeDataDictionary.removeAll()
        
        let moderateList = moderateTimeData.sorted { v1, v2 in
            
            let a = v1.key.dropLast(3)
            let b = v2.key.dropLast(3)
            
            return a < b
        }
        
        sortedModerateTimeDataDictionary = moderateList
        
        
        let severeList = severeTimeData.sorted { v1, v2 in
            
            let a = v1.key.dropLast(3)
            let b = v2.key.dropLast(3)
            
            return a < b
        }
        
        sortedSevereTimeDataDictionary = severeList
        
        
        
        changeGraph+=1
        
    }
    
}
