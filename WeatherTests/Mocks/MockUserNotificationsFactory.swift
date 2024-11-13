//
//  MockUserNotificationsFactory.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

@testable import Weather

final class MockUserNotificationsFactory: UserNotificationsFactoryInterface {
    var weather: CurrentWeather?
    
    func scheduleDailyNotification(weather: CurrentWeather) {
        self.weather = weather
    }
}
