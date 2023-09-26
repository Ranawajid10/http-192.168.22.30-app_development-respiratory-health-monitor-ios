//
//  DateUtills.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 25/08/2023.
//

import Foundation

class DateUtills{
    
    
    static func oneWeekAgo() -> Date {
        return Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    }
    
    
    static func getCurrentTimeInMilliseconds() -> String {
        let currentTimeMillis = Int64(Date().timeIntervalSince1970 * 1000)
        return String(currentTimeMillis)
    }
    
    static func isToday(_ date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    
    static func isHourComplete(date: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: date)
        
        if let minutes = components.minute, minutes == 59 {
               return true
           } else {
               return false
           }
    }
    
    static func changeDateFormat(date: Date, oldFormat: String, newFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = oldFormat // Specify the format of the original date string
        
        let dateString = dateFormatter.string(from: date) // Convert Date to String
        
        if let originalDate = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = newFormat // Specify the new format
            return dateFormatter.string(from: originalDate)
        } else {
            return "Invalid Date"
        }
    }
    
    static func changeDateFormat(date: Date, newFormat: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = newFormat // Specify the new format

        let dateString = dateFormatter.string(from: date) // Convert Date to String

        if let newDate = dateFormatter.date(from: dateString) {
            return newDate
        } else {
            return nil
        }
    }


    
    static func changeDateFormat(date: String,oldFormat:String,newFormat:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = oldFormat // Specify the format of the original date string
        
        if let originalDate = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = newFormat // Specify the new format
            return dateFormatter.string(from: originalDate)
        } else {
            return "Invalid Date"
        }
    }
    
    static func dateToMilliseconds(dateString: String, format: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format // Specify the format of the date string
        if let date = dateFormatter.date(from: dateString) {
            let milliseconds = Int(date.timeIntervalSince1970 * 1000)
            return milliseconds
        }
        return nil
    }
    
    static func getCurrentDateInString(format:String)->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        return formattedDate
        
    }
    
    static func getCurrentDate(format:String)->Date{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format // Specify the new format
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate) // Convert Date to String

        return dateFormatter.date(from: dateString)!
       
    }
    
    static func dateToString(date: Date, dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    static func stringToDate(date:String,dateFormat:String)->Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.date(from: date) ?? Date()
    }
    
    static func getDayOfWeek(dateString: String,dateFormat:String) -> String {
        // Create a DateFormatter for parsing the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        // Attempt to convert the date string to a Date
        if let date = dateFormatter.date(from: dateString) {
            // Create a Calendar instance
            let calendar = Calendar.current
            
            // Use the calendar to get the day of the week as an integer
            let dayOfWeek = calendar.component(.weekday, from: date)
            
            // Convert the integer day of the week to a string
            // Adjust the index if needed (e.g., Sunday is usually 1, but you might want it to be 0)
            let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            let dayString = days[dayOfWeek - 1]
            
            return dayString
        }
        
        return "" // Return nil if the date string is not valid
    }
    
    static func getCurrentWeekRange(date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let currentDateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        
        if let day = currentDateComponents.day, let weekday = currentDateComponents.weekday {
            let startOfWeekComponents = DateComponents(year: currentDateComponents.year, month: currentDateComponents.month, day: day - weekday + 1)
            let endOfWeekComponents = DateComponents(year: currentDateComponents.year, month: currentDateComponents.month, day: day + (7 - weekday))
            
            if let startOfWeek = calendar.date(from: startOfWeekComponents), let endOfWeek = calendar.date(from: endOfWeekComponents) {
                
                return (start: startOfWeek, end: endOfWeek)
            }
        }
        
        // Return a default value or handle the error in some way
        fatalError("Error calculating the week range")
    }
    
    static func dateRangeText(startDate: Date, endDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        let startString = dateFormatter.string(from: startDate)
        let endString = dateFormatter.string(from: endDate)
        return "\(startString) - \(endString)"
    }

    
    
    static  func getPreviousWeekMonday(_ date: Date) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        var dateComponents = DateComponents()
        dateComponents.day = -7 + (2 - weekday) // Calculate the number of days to subtract to get to the previous Monday
        
        guard let previousMonday = calendar.date(byAdding: dateComponents, to: date) else {
            fatalError("Error calculating previous week's Monday")
        }
        
        return previousMonday
    }
    
    static func getPreviousWeekSunday(from monday: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 6, to: monday)!
    }
    
    static func getNextWeekMonday(_ date: Date) -> Date {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.weekday], from: date)
        
        if dateComponents.weekday == 1 {
            dateComponents.weekday = 2
        } else {
            dateComponents.weekday = 2
            dateComponents.day = 7 - dateComponents.weekday!
        }
        
        return calendar.date(byAdding: dateComponents, to: date)!
    }
    
    static func getNextWeekSunday(from monday: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 6, to: monday)!
    }
    
    static func getCurrentWeekRange(_ date: Date) -> (Date, Date) {
        let calendar = Calendar.current
        var startOfWeek = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        startOfWeek.weekday = 2 // Monday
        let start = calendar.date(from: startOfWeek)!
        
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: start)!
        
        return (start, endOfWeek)
    }
    
}
