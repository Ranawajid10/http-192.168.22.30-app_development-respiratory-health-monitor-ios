//
//  NotesVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 03/10/2023.
//

import Foundation


class NotesVM:ObservableObject{
    
    
    @Published var audioChunks:[CoughNotes] = []
    @Published var notesFecthed:[Notes] = []
    
    @Published var currentDateCoughsList:[CoughNotes] = []
    @Published var currentDateNotesList:[Notes] = []
    
    @Published var currentHourCoughsList:[CoughNotes] = []
    @Published var currentHourNotesList:[Notes] = []
    
    @Published var selectedCoughsList:[CoughNotes] = []
    
    @Published var playingPosition = 0
    
    @Published var coughTimes: [String] = []
    
    @Published  var selectedDate = Date()
    @Published  var showAddNoteSheet = false
    @Published  var showCoughAndNoteSheet = false
    @Published  var isNoteAdded = false
    @Published  var showNoteDeleteAlert = false
    @Published  var isError = false
    @Published  var errorMessage = ""
    @Published  var selectedHour = ""
    @Published  var hour = ""
    
    @Published var coughCounts = 0
    
    @Published var updateRow = 0
    
    
    @Published var loadingPosition = 0
    @Published var isLoading = false
    
    
    @Published var userData = LoginResult()
    
    func next(){
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? Date()
        if tomorrow <= Date() {
            selectedDate = tomorrow
        }
        
        getCurrentDayCoughsAndNotes()
    }
    
    func previous(){
        
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? Date()
        
        getCurrentDayCoughsAndNotes()
        
    }
    
    
    //    func getData(){
    //
    //        (currentDateCoughsList,coughTimes) = getCurrentCoughs(hour: hour)
    //
    //        coughCounts = coughTimes.count
    //        currentDateNotesList = getCurrentNotes(hour: hour)
    //
    //        if(currentDateNotesList.isEmpty){
    //
    //            getCoughsData()
    //
    //        }
    //
    //
    //    }
    
    func getCoughsAndNotesInThisHour(currentHour:String,i:Int)-> ([CoughNotes],[Notes]){
        
        var currentHourCoughsList:[CoughNotes] = []
       var currentHourNotesList:[Notes] = []
        
        
        for cough in currentDateCoughsList {
            
            
            let coughTime = cough.time?.components(separatedBy: ":").first ?? ""
            let hour = currentHour.components(separatedBy: ":").first ?? ""
            
            if(coughTime == hour){
                
                coughTimes.append(coughTime)
                currentHourCoughsList.append(cough)
            }
            
            
        }
        
        
        for notes in currentDateNotesList {
            
            
            let coughTime = notes.time?.components(separatedBy: ":").first ?? ""
            let hour = currentHour.components(separatedBy: ":").first ?? ""
            
            if(coughTime == hour){
                
                currentHourNotesList.append(notes)
                
            }
            
        }
        
//        for cough in currentHourCoughsList {
//            
//            if(cough.time == "15:53:30"){
//                
//                print("currentHourCoughsList",cough.coughSegments)
//                
//            }
//            print("currentHourCoughsList",cough.id,"-----",cough.coughSegments?.count,"----",cough.time,"------",cough.date)
//            
//        }
       
        return (currentHourCoughsList,currentHourNotesList)
        
    }
    
//    func getCoughsAndNotesInThisHour(currentHour:String) -> ([CoughNotes],[Notes]){
//        
//        var  currentHourCoughsList:[CoughNotes] = []
//        var  currentHourNotesList:[Notes] = []
//        
//        
//        for cough in currentDateCoughsList {
//            
//            
//            let coughTime = cough.time?.components(separatedBy: ":").first ?? ""
//            let hour = currentHour.components(separatedBy: ":").first ?? ""
//            
//            if(coughTime == hour){
//                
//                coughTimes.append(coughTime)
//                currentHourCoughsList.append(cough)
//            }
//            
//            
//        }
//        
//        
//        for notes in notesFecthed {
//            
//            
//            let coughTime = notes.time?.components(separatedBy: ":").first ?? ""
//            let min = currentHour.components(separatedBy: ":").first ?? ""
//            
//            if(coughTime == min){
//                
//                currentHourNotesList.append(notes)
//                
//            }
//            
//        }
//        
//        
//        return (currentHourCoughsList,currentHourNotesList)
//        
//    }
    
    func getCurrentDayCoughsAndNotes(){
        
        currentDateCoughsList.removeAll()
        currentDateNotesList.removeAll()
        
        (currentDateCoughsList,coughTimes) = getCurrentDateCoughs()
        
        currentDateNotesList = getCurrentDateNotes(hour: hour)
    
              
        if(currentDateNotesList.isEmpty && currentDateCoughsList.isEmpty){
            print("playSample","api")
            getCoughsData()
            return
        }
        
 
      print("playSample","local",currentDateCoughsList.count)
        
        updateRow+=1
        
    }
    
    
    
    
    func getCurrentDateCoughs() -> ([CoughNotes],[String]){
        
        var currentDateCoughsList:[CoughNotes] = []
        
        var coughTimes: [String] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        let dateString = dateFormatter.string(from: selectedDate)
        
        
        
        for cough in audioChunks {
            
            if cough.date == dateString {
                
                let coughTime = cough.time?.components(separatedBy: ":").first ?? ""
                _ = hour.components(separatedBy: ":").first ?? ""
                
                coughTimes.append(coughTime)
                currentDateCoughsList.append(cough)
                
            }
            
            
            
        }
        
        
        return (currentDateCoughsList,coughTimes)
    }
    
    func getCurrentHourCoughs(hour:String) -> ([CoughNotes],[String]){
        
        var currentDateCoughsList:[CoughNotes] = []
        
        var coughTimes: [String] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        let dateString = dateFormatter.string(from: selectedDate)
        
        
        for cough in audioChunks {
            
            if cough.date == dateString {
                
                
                
                let coughTime = cough.time?.components(separatedBy: ":").first ?? ""
                let hour = hour.components(separatedBy: ":").first ?? ""
                
                if(coughTime == hour){
                    
                    coughTimes.append(coughTime)
                    currentDateCoughsList.append(cough)
                }
                
            }
            
            
            
        }
        
        
        return (currentDateCoughsList,coughTimes)
    }
    
    func getCurrentDateNotes(hour:String) -> [Notes] {
        
        var currentDateNotesList:[Notes] = []
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        let dateString = dateFormatter.string(from: selectedDate)
        
        
        for notes in notesFecthed {
            
            if notes.date == dateString {
                
                currentDateNotesList.append(notes)
                
            }
            
            
            
        }
        
        let moderateList = currentDateNotesList.sorted { v1, v2 in
            
            let a = v1.time?.dropLast(6) ?? "00"
            let b = v2.time?.dropLast(6) ?? "00"
            
            return a < b
        }
        
        
        return moderateList.reversed()
    }
    
    func getCurrentHourNotes(hour:String) -> [Notes] {
        
        var currentDateNotesList:[Notes] = []
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        let dateString = dateFormatter.string(from: selectedDate)
        
        
        for notes in notesFecthed {
            
            if notes.date == dateString {
                
                let coughTime = notes.time?.components(separatedBy: ":").first ?? ""
                let min = hour.components(separatedBy: ":").first ?? ""
                
                if(coughTime == min){
                    
                    currentDateNotesList.append(notes)
                    
                }
                
            }
            
            
            
        }
        
        let moderateList = currentDateNotesList.sorted { v1, v2 in
            
            let a = v1.time?.dropLast(6) ?? "00"
            let b = v2.time?.dropLast(6) ?? "00"
            
            return a < b
        }
        
        
        return moderateList.reversed()
    }
    
    func getCoughsData(){
        
        let cDate = DateUtills.getCurrentDate(format: DateTimeFormats.dateTimeFormat4)
        let sDate = DateUtills.changeDateFormat(date: selectedDate, newFormat: DateTimeFormats.dateTimeFormat4)!
        
        let cString = DateUtills.dateToString(date: cDate, dateFormat: DateTimeFormats.dateTimeFormat4)
        let sString = DateUtills.dateToString(date: sDate, dateFormat: DateTimeFormats.dateTimeFormat4)
        
        let ncString = cString.dropLast(15)
        let scString = sString.dropLast(15)
        
        let cDay = Int(ncString.dropFirst(8)) ?? 1
        let sDay = Int(scString.dropFirst(8)) ?? 1
        
        
       
        isLoading = true
        
        
//        if sDay < cDay {
//            //  past
//            loadingPosition = 0
//       
//        }else {
//            // future
//            loadingPosition = 1
//            
//        }
//        
        if (sDay == cDay)  {
            // current
            loadingPosition = 2
        }
        
      
        let date = DateUtills.changeDateFormat(date: selectedDate, oldFormat: DateTimeFormats.dateTimeFormat4, newFormat: DateTimeFormats.dateFormat1)
        
        print("playSample",date)
        
        ApiClient.shared.getCoughRecordings(token: userData.token ?? "", date: date) { [self] response in
            
            
            
            switch response {
            case .success(let success):
                print("playSample",success.count)
                setApiData(data: success)
                break
            case .failure(let failure):
                isLoading = false
                errorMessage = failure.localizedDescription
                isError = true
                break
            }
        }
        
        
    }
    
    func setApiData(data:[CoughRecordingsResult]){
        
        currentDateCoughsList.removeAll()
        
        
        isLoading = false
        
        
        
        let dateString = DateUtills.changeDateFormat(date: selectedDate,oldFormat: DateTimeFormats.dateTimeFormat4, newFormat: DateTimeFormats.dateFormat1)

        var counter = 0
        
        for cough in data {
            
            if let date = cough.date{
                
                if date == dateString {
                    
                    print("cough.datetime",cough.datetime)
                    let time = DateUtills.changeDateFormat(date: cough.datetime ?? "", oldFormat: DateTimeFormats.dateTimeFormat2, newFormat: DateTimeFormats.timeFormat3)
                    print("cough.datetime",time)
                    let coughNotes = CoughNotes(context: PersistenceController.shared.container.viewContext)
                    coughNotes.id = DateUtills.getCurrentTimeInMilliseconds()+String(counter)
                    coughNotes.time = time
                    coughNotes.date = date
                    coughNotes.coughPower = cough.recIntensity
                    coughNotes.url = cough.url
                    
                    currentDateCoughsList.append(coughNotes)
                    
                    counter+=1
                    
                }
                
                
                
            }
            
        
        }
        
       
        
   
        
        updateRow+=1
        
    }
    
}
