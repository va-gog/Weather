//
//  DateToStringConverter.swift
//  Weather
//
//  Created by Gohar Vardanyan on 24.10.24.
//
import Foundation

struct DateToStringConverter {
    
    func convertHour(date: Date, timeIntervalThreshold: TimeInterval = 1800) -> String {
        let currentDate = Date()
        
        if abs(currentDate.timeIntervalSince(date)) <= timeIntervalThreshold {
            return "now"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH"
            dateFormatter.timeZone = TimeZone.current
            return dateFormatter.string(from: date)
        }
    }
    
    func convertDay(date: Date) -> String {
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: Date())

        if calendar.isDate(date, inSameDayAs: currentDate) {
            return "Today"
        } else {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            dayFormatter.timeZone = TimeZone.current
            
            return dayFormatter.string(from: date)
        }
    }
   
}
