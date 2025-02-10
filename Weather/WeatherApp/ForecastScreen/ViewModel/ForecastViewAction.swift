//
//  ForecastViewAction.swift
//  Weather
//
//  Created by Gohar Vardanyan on 10.02.25.
//

enum ForecastViewAction: Action {
    enum Delegate: Action {
        case closeWhenDeleted(WeatherCurrentInfo?)
        case closeWhenAdded(WeatherCurrentInfo?)
        case cancel
        case signOut
    }
    
    case deleteButtonAction
    case addFavoriteWeather
    case signedOut
    case close
    case fetchForecastInfo
    case fetchWeatherCurrentInfo
}
