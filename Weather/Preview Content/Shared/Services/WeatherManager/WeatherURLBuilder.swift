//
//  WeatherURLBuilder.swift
//  Weather
//
//  Created by Gohar Vardanyan on 24.10.24.
//

import Foundation

struct WeatherURLBuilder {
    static func URLForForecast(latitude: Double, longitude: Double, exclude: [String], unit: WeatherUnit = .celsius) -> String {
        let url = APIConfigurationManager.baseURLString + OpenWeatherAPI.onaCall.rawValue
        let exclude = exclude.joined(separator: ",")
        let queryString = "?lat=\(latitude)&lon=\(longitude)&units=\(unit.rawValue)&exclude=\(exclude)&appid=\(APIConfigurationManager.apiKey)"
        return url + queryString
    }
    
    static func URLForCurrent(latitude: Double, longitude: Double, unit: WeatherUnit = .celsius) -> String {
        let url = APIConfigurationManager.baseURLString + OpenWeatherAPI.weather.rawValue
        let queryString = "?lat=\(latitude)&lon=\(longitude)&units=\(unit.rawValue)&appid=\(APIConfigurationManager.apiKey)"
        return url + queryString
    }
    
    static func URLForGeo(geo: String) -> String {
        let url = APIConfigurationManager.baseURLString + OpenWeatherAPI.geo.rawValue
        let queryString = "?q=\(geo)&appid=\(APIConfigurationManager.apiKey)"
        return url + queryString
    }
}
