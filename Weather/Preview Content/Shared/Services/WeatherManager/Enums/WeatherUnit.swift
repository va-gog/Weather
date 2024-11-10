//
//  WeatherUnit.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

enum WeatherUnit: String {
    case celsius = "metric"
    case farenheit = "imperial"
    
    var metric: String {
        return  switch self {
        case .celsius:
            "°"
        case .farenheit:
            "F"
        }
    }
}
