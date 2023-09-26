//
//  AllowSyncStatsVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 28/09/2023.
//

import Foundation


class AllowSyncStatsVM : ObservableObject{
    
    
    @Published var isUploaded = false
    @Published var isLoading = false
    @Published var isError = false
    @Published var errorMessage:String = ""
    
    @Published var valunteerCoughList:[VolunteerCough] = []
    @Published var coughTrackHourList:[HoursUpload] = []
    @Published var trackedSecondsByHour: [TrackedMinutes] = []
    
    @Published var userData = LoginResult()
    
    func calculateTrackedMinutes(){
        
        trackedSecondsByHour.removeAll()
        
        for record in coughTrackHourList {
            let components = record.dateTime?.components(separatedBy: "-") ?? []
            if components.count >= 4 {
                
                let dateTime = (record.dateTime?.dropLast(5) ?? "")+"00:00"
                
                
                
                if let index = trackedSecondsByHour.firstIndex(where: { $0.date == dateTime }) {
                    trackedSecondsByHour[index].minutes += record.trackedSeconds/60.0
                } else {
                    
                    let date = DateUtills.changeDateFormat(date: String(dateTime), oldFormat: DateTimeFormats.dateTimeFormat1, newFormat: DateTimeFormats.dateFormat1)
                    let time = DateUtills.changeDateFormat(date: String(dateTime), oldFormat: DateTimeFormats.dateTimeFormat1, newFormat: DateTimeFormats.timeFormat1)
                    
                    let finalDate = date+"T"+time
                    
                    trackedSecondsByHour.append(TrackedMinutes(date: finalDate, minutes: record.trackedSeconds/60.0))
                }
                
            }
        }
        
        
        uploadAllCoughs()
        
    }
    
    func uploadAllCoughs(){
        
        isLoading = true
        
        do {
            // Create a JSONEncoder to encode the data
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            // Encode the data to JSON data
            let jsonData = try encoder.encode(trackedSecondsByHour)
            
            // Convert the JSON data to a JSON string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                ApiClient.shared.newUploadCoughSamplesStats(allCoughList: valunteerCoughList,stats: jsonString, token: userData.token ?? "") { [self] response in
                    
                    isLoading = false
                    
                    switch response {
                    case .success(_):
                        isUploaded = true
                        break
                    case .failure(let failure):
                        isUploaded = false
                        errorMessage = failure.localizedDescription
                        isError = true
                        break
                    }
                    
                }
                
            } else {
                isError = true
                errorMessage = "Failed to convert data to string"
                print("Failed to convert data to string")
            }
        } catch {
            isError = true
            errorMessage = "Error: \(error)"
            print("Error: \(error)")
        }
        
        
        
    }
    
}




