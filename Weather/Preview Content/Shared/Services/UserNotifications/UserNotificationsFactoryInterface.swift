//
//  UserNotificationsFactoryInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

protocol UserNotificationsFactoryInterface {
    func scheduleDailyNotification(weather: CurrentWeather)
}
