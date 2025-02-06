//
//  WeatherForecast.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

struct WeatherForecast: Decodable {
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]
}
