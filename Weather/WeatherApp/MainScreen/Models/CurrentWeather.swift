//
//  CurrentWeather.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Foundation

struct CurrentWeather: Decodable, Equatable {
    let id: Double
    let name: String
    let weather: [Weather]
    let main: Main
    let coord: Coordinates
}
