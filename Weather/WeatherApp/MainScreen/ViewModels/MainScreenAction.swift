//
//  MainScreenAction.swift
//  Weather
//
//  Created by Gohar Vardanyan on 05.02.25.
//

import SwiftUI

enum MainScreenAction: Action {
    enum Delegate: Action, Equatable {
        case pushForecastView(City, WeatherDetailsViewStyle, WeatherCurrentInfo?)
        case popForecastViewWhenDeleted(WeatherCurrentInfo?)
        case popForecastViewWhenAdded(WeatherCurrentInfo?)
        
        static func == (lhs: Delegate, rhs: Delegate) -> Bool {
            switch (lhs, rhs) {
            case let (.pushForecastView(city1, style1, weather1), .pushForecastView(city2, style2, weather2)):
                return city1 == city2 && style1 == style2 && weather1 == weather2
            case let (.popForecastViewWhenDeleted(weather1), .popForecastViewWhenDeleted(weather2)):
                return weather1 == weather2
            case let (.popForecastViewWhenAdded(weather1), .popForecastViewWhenAdded(weather2)):
                return weather1 == weather2
            default:
                return false
            }
        }
    }
    
    case weatherSelected(WeatherCurrentInfo)
    case citySelected(City)
    case deleteButtonPressed(CurrentWeather)
    case addButtonPressed(WeatherCurrentInfo)
    case searchWith(String)
    case fetchWeatherInfo
    case requestNotificationPermission
}
