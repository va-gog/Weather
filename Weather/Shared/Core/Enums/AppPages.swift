//
//  AppPages.swift
//  Weather
//
//  Created by Gohar Vardanyan on 05.11.24.
//


protocol AppScreen: Hashable, Equatable { }

enum WeatherAppScreen: AppScreen {
    case launch
    case main
    case authentication
    case locationAccess
    case forecast
}
