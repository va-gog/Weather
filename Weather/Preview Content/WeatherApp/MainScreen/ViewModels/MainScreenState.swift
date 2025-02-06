//
//  MainScreenState.swift
//  Weather
//
//  Created by Gohar Vardanyan on 05.02.25.
//

import SwiftUI

final class MainScreenState: ObservableObject, ReducerState {
    @Published var searchState: SearchState?
    @Published var searchResult: [City] = []
    @Published var locationStatus: LocationAuthorizationStatus = .notDetermined
    @Published var fetchState: FetchState = .none
    @Published var weatherInfo: [WeatherCurrentInfo] = []
}
