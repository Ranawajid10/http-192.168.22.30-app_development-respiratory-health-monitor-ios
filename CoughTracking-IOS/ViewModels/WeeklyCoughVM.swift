//
//  WeeklyCoughVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 28/09/2023.
//

import Foundation


class WeeklyCoughVM:ObservableObject{
    
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
    
    @Published  var selectedDate = Date()
    @Published var currentWeekRange: (start: Date, end: Date)? = nil
    
    @Published  var startDate = Date()
    @Published  var endDate = Date()
    @Published  var weekRangeText = ""
    
    
    
    
    @Published var moderateTimeData: [String: Int] = [:]
    @Published var severeTimeData: [String: Int] = [:]
    
    @Published var sortedModerateTimeDataDictionary: [(key: String, value: Int)]  = []
    @Published var sortedSevereTimeDataDictionary: [(key: String, value: Int)] = []
    
    @Published var userData = LoginResult()
    
    @Published var changeGraph:Int = 0
    
    func next(){
        
        let date = selectedDate
        
        loaderPos = 0
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 7, to: date) ?? Date()
        if tomorrow <= Date() {
            selectedDate = DateUtills.getNextWeekMonday( selectedDate)
            getGraphData()
        }
        
       
        
    }
    
    func previous(){
        
        loaderPos = 1
        
        selectedDate = DateUtills.getPreviousWeekMonday(selectedDate)
        
        getGraphData()
        
    }
    
    
    
    
    func getGraphData() {
        // Get the start and end dates of the current week
        currentWeekRange = DateUtills.getCurrentWeekRange(date: selectedDate)
        startDate = currentWeekRange?.start ?? Date()
        endDate = currentWeekRange?.end ?? Date()

        weekRangeText = DateUtills.dateRangeText(startDate: startDate, endDate: endDate)

        let (currentDateCoughs, _) = getCurrentWeekCoughs()
        
        if(currentDateCoughs.count==0 && Connectivity.isConnectedToInternet ){
            
            getDataFromDB(filterSlot: Constants.weekly)
            return
        }

        totalCoughCount = currentDateCoughs.count
        
        calculateCurrentCoughHours()

        moderateTimeData.removeAll()
        severeTimeData.removeAll()

        // Initialize the dictionary with the days of the week as keys
        for day in Constants.weeklyGraphArray {
            moderateTimeData[day, default: 0] = 0
            severeTimeData[day, default: 0] = 0
        }

        for cough in currentDateCoughs {
            guard let coughDate = cough.date,
                  let coughPower = cough.coughPower else {
                continue
            }

            let coughDate1 = DateUtills.stringToDate(date: coughDate, dateFormat: DateTimeFormats.dateFormat1)
            let weekOfDay = DateUtills.getDayOfWeek(dateString: coughDate, dateFormat: DateTimeFormats.dateFormat1)

            // Check if the cough date is within the specified date range
            if coughDate1 >= startDate && coughDate1 <= endDate {
                if let dayValue = Constants.weeklyGraphArray.firstIndex(of: weekOfDay) {
                    let dayKey = Constants.weeklyGraphArray[dayValue]
                    if coughPower == "moderate" {
                        moderateTimeData[dayKey, default: 0] += 1
                    } else if coughPower == "severe" {
                        severeTimeData[dayKey, default: 0] += 1
                    }
                }
            }
        }

        // Create a new dictionary with sorted keys and their corresponding values
        sortedModerateTimeDataDictionary.removeAll()
        sortedSevereTimeDataDictionary.removeAll()

        let moderateList = moderateTimeData.sorted { v1, v2 in
            return Constants.weeklyGraphArray.firstIndex(of: v1.key) ?? 0 < Constants.weeklyGraphArray.firstIndex(of: v2.key) ?? 0
        }

        sortedModerateTimeDataDictionary = moderateList

        let severeList = severeTimeData.sorted { v1, v2 in
            return Constants.weeklyGraphArray.firstIndex(of: v1.key) ?? 0 < Constants.weeklyGraphArray.firstIndex(of: v2.key) ?? 0
        }

        sortedSevereTimeDataDictionary = severeList

        changeGraph += 1
    }


    func calculateCurrentCoughHours(){
        
        totalTrackedHours = 0
        coughsPerHour = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
//        let startDateString = dateFormatter.string(from: startDate)
//        let endDateString = dateFormatter.string(from: endDate)
        
        var totalSeconds = 0.0
        
        for second in hourTrackedList {
            
            let trackDate = dateFormatter.date(from: second.date ?? "") ??  Date()
            
            if trackDate >= startDate && trackDate <= endDate {
                
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
        
        print("totalSeconds",totalSeconds,"--hours",hours,"--coughsPerHour",coughsPerHour,"--totalCoughCount",totalCoughCount,"--totalTrackedHours",totalTrackedHours)
        
    }
    
    
    func getCurrentWeekCoughs() -> ([Cough],[String]){
        
        var currentDateCoughsList:[Cough] = []
        
        var coughTimes: [String] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

//        var star
        print("startDate",startDate,"-----","endDate",endDate)
//
//        let dateString = dateFormatter.string(from: selectedDate)
        
        
        for cough in allCoughList {
            
            let trackDate = dateFormatter.date(from: cough.date ?? "") ??  Date()
            
            if trackDate >= startDate && trackDate <= endDate {
                
                
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
        
        
        ApiClient.shared.getStats(filterBy:Constants.weekly,date:finalDate,filterSlot:filterSlot, isDailyCurrent: isCurrentDateData, token: userData.token ?? ""){ [self] response in
            
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
        
        
        for hour in Constants.weeklyGraphArray {
            moderateTimeData[hour, default: 0] = 0
            severeTimeData[hour, default: 0] = 0
        }
        
        
        for stat in statsResult.data {
            guard let coughPower = stat.label else {
                continue
            }
            
            // Extract the minutes part from the cough time (e.g., "11:42:54" -> "42")
//            let minutes = stat.timeInterval?.dropLast(6) ?? ""
            let coughDate1 = DateUtills.stringToDate(date: stat.timeInterval ?? "", dateFormat: DateTimeFormats.dateTimeFormat2)
            let weekOfDay = DateUtills.getDayOfWeek(dateString: stat.timeInterval ?? "", dateFormat: DateTimeFormats.dateTimeFormat2)
            
            
            // Initialize variables to track whether the cough time falls within an interval
            if coughDate1 >= startDate && coughDate1 <= endDate {
                if let dayValue = Constants.weeklyGraphArray.firstIndex(of: weekOfDay) {
                    let dayKey = Constants.weeklyGraphArray[dayValue]
                    if coughPower == "moderate" {
                        moderateTimeData[dayKey, default: 0] += 1
                    } else if coughPower == "severe" {
                        severeTimeData[dayKey, default: 0] += 1
                    }
                }
            }
            
            
            
        }

        
        // Create a new dictionary with sorted keys and their corresponding values
        sortedModerateTimeDataDictionary.removeAll()
        sortedSevereTimeDataDictionary.removeAll()
        
        let moderateList = moderateTimeData.sorted { v1, v2 in
            return Constants.weeklyGraphArray.firstIndex(of: v1.key) ?? 0 < Constants.weeklyGraphArray.firstIndex(of: v2.key) ?? 0
        }

        sortedModerateTimeDataDictionary = moderateList

        let severeList = severeTimeData.sorted { v1, v2 in
            return Constants.weeklyGraphArray.firstIndex(of: v1.key) ?? 0 < Constants.weeklyGraphArray.firstIndex(of: v2.key) ?? 0
        }

        sortedSevereTimeDataDictionary = severeList
        
        
        
        changeGraph+=1
        
    }
    
}
