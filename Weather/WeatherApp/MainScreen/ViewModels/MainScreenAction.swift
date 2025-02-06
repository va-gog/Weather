//
//  MainScreenAction.swift
//  Weather
//
//  Created by Gohar Vardanyan on 05.02.25.
//

import SwiftUI

enum MainScreenAction: Action {
    enum Delegate: Action {
        case pushForecastView(City, WeatherDetailsViewStyle, WeatherCurrentInfo?)
        case popForecastViewWhenDeleted(WeatherCurrentInfo?)
        case popForecastViewWhenAdded(WeatherCurrentInfo?)
    }
    
    case weatherSelected(WeatherCurrentInfo)
    case citySelected(City)
    case deleteButtonPressed(CurrentWeather)
    case addButtonPressed(WeatherCurrentInfo)
    case searchWith(String)
    case fetchWeatherInfo
    case requestNotificationPermission
}
