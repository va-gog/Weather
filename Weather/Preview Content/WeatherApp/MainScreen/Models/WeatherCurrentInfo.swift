//
//  WeatherCurrentInfo.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//
import Foundation

struct WeatherCurrentInfo: Identifiable {
    var id = UUID()
    var currentWeather: CurrentWeather
    var unit: WeatherUnit = .celsius
    var isMyLocation: Bool = false
}
