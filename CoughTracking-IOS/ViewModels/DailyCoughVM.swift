//
//  DailyCoughVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 27/09/2023.
//

import Foundation

class DailyCoughVM:ObservableObject{
    
    @Published var allCoughList:[Cough] = []
    @Published var hourTrackedList:[TrackedHours] = []
    
    @Published var loaderPos = 0
    @Published var isLoading = false
    @Published var isError = false
    @Published var errorMessage = ""
    
    @Published var date = ""
    @Published var isCurrentDateData = false
    @Published var statsResult = StatsResult()
    
    
    @Published var totalCoughCount:Int = 0
    @Published var totalTrackedHours:Double = 0.0
    @Published var coughsPerHour:Int = 0
    
    
    @Published var selectedDate = Date()
    
    @Published var moderateTimeData: [String: Int] = [:]
    @Published var severeTimeData: [String: Int] = [:]
    
    @Published var sortedModerateTimeDataDictionary: [(key: String, value: Int)]  = []
    @Published var sortedSevereTimeDataDictionary: [(key: String, value: Int)] = []
    
    @Published var changeGraph:Int = 0
    
    @Published var userData = LoginResult()
    
    
   
    func next(){
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? Date()
       
        if tomorrow <= Date() {
            selectedDate = tomorrow
            loaderPos = 0
            getGraphData()
        }
        
        
        
        
    }
    
    func previous(){
        
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? Date()
        loaderPos = 1
        getGraphData()
        
    }
    
    
    func isToday(_ date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    

    func calculateCurrentCoughHours(){
        
        totalTrackedHours = 0
        coughsPerHour = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        let dateString = dateFormatter.string(from: selectedDate)
        
        var totalSeconds = 0.0
        
        for second in hourTrackedList {
            
            if(dateString == second.date){
                
                totalSeconds+=second.secondsTrack
                
            }
            
        }
        
        
        let hours =  totalSeconds/3600.0
        
        
        if(hours<1){
            
            totalTrackedHours = 1
            
        }else{
            
            totalTrackedHours =  totalSeconds/3600.0
            
        }
        
        coughsPerHour = totalCoughCount / Int(totalTrackedHours)
        
       
    }
    
    func getGraphData(){
        
        let (currentDateCoughs,times) = getCurrentDayCoughs()
        
       
        if(currentDateCoughs.count==0 && Connectivity.isConnectedToInternet){
            
            getDataFromDB(filterSlot: Constants.daily)
            return
        }
        
        
        totalCoughCount = currentDateCoughs.count
        
        calculateCurrentCoughHours()
        
        moderateTimeData.removeAll()
        severeTimeData.removeAll()
        
        
        for hour in Constants.dailyGraphArray {
            moderateTimeData[hour, default: 0] = 0
            severeTimeData[hour, default: 0] = 0
        }
        
        
        
        for cough in currentDateCoughs {
            guard let coughTime = cough.time else {
                continue
            }
            
            
            // Extract the minutes part from the cough time (e.g., "11:42:54" -> "42")
            let minutes = coughTime.dropLast(6)
            
            
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
        
        
        changeGraph+=1
        
        print("Daily Graph Data",currentDateCoughs.count,"---",times.count,"---Moderate---",sortedModerateTimeDataDictionary,"---Severe---",sortedSevereTimeDataDictionary)
        
        
    }
    
    func getCurrentDayCoughs() -> ([Cough],[String]){
        
        var currentDateCoughsList:[Cough] = []
        
        var coughTimes: [String] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        let dateString = dateFormatter.string(from: selectedDate)
        
        
        for cough in allCoughList {
            
            if cough.date == dateString {
                
                
                
                let coughTime = cough.time?.components(separatedBy: ":").first ?? ""
                
                
                coughTimes.append(coughTime)
                currentDateCoughsList.append(cough)
                
                
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
        
       
        let date = DateUtills.dateToString(date: selectedDate, dateFormat: DateTimeFormats.dateTimeFormat4)
        
        let ddate = DateUtills.changeDateFormat(date: date, oldFormat: DateTimeFormats.dateTimeFormat4, newFormat: DateTimeFormats.dateFormat1)
       
        let time = DateUtills.getCurrentDateInString(format:DateTimeFormats.timeFormat1)
        
        
        let finalDate = "\(ddate)T\(time)"
        
        
        ApiClient.shared.getStats(filterBy:Constants.daily,date:finalDate,filterSlot:filterSlot, isDailyCurrent: isCurrentDateData, token: userData.token ?? ""){ [self] response in
            
            isLoading = false
            isError = false
            
            switch response {
            case .success(let success):
                
                statsResult = success
                
                print("DailyCoughsView",statsResult)
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
