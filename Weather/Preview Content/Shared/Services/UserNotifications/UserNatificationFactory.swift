//
//  UserNotificationFactory.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

import Foundation
import UserNotifications

struct UserNotificationFactory: UserNotificationsFactoryInterface {
    
    func scheduleDailyNotification(weather: CurrentWeather) {
        let content = UNMutableNotificationContent()
        content.sound = .default
        
        var dateComponents = DateComponents()
        let calendar = Calendar.current
        dateComponents.hour = 10
        dateComponents.minute = 0
        
        let currentDate = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        
        dateComponents.year = calendar.component(.year, from: tomorrow)
        dateComponents.month = calendar.component(.month, from: tomorrow)
        dateComponents.day = calendar.component(.day, from: tomorrow)
        
        Task {
            content.title = "Daily Weather Reminder"
            content.body = "Good morning! Today's lower temperature: \(weather.main.tempMin), higher: \(weather.main.tempMax)"
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
            try? await UNUserNotificationCenter.current().add(request)
        }
    }
}
