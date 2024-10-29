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
            return dataWithFormatter("HH", date: date)
        }
    }
    
    func convertDay(date: Date) -> String {
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: Date())

        if calendar.isDate(date, inSameDayAs: currentDate) {
            return "Today"
        } else {
            return dataWithFormatter("EEEE", date: date)
        }
    }
    
    private func dataWithFormatter(_ dateFormat: String, date: Date) -> String {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = dateFormat
        dayFormatter.timeZone = TimeZone.current
        
        return dayFormatter.string(from: date)
    }
   
}
