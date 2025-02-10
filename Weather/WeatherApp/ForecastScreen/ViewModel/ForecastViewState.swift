//
//  ForecastViewState.swift
//  Weather
//
//  Created by Gohar Vardanyan on 10.02.25.
//

import SwiftUI

final class ForecastViewState: ObservableObject, ReducerState {
    @Published var currentInfo: WeatherCurrentInfo?
    @Published var forecastInfo = WeatherForecast(hourly: [], daily: [])
    @Published var fetchState: FetchState = .none
}
