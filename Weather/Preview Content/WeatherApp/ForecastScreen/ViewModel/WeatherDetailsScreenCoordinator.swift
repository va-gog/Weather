//
//  WeatherDetailsScreenCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 01.11.24.
//

import SwiftUI

final class WeatherDetailsScreenCoordinator: ObservableObject {
    @ObservedObject var viewModel: WeatherDetailsViewModel
    @Published var currentInfo: WeatherCurrentInfo?
    @Published var forecastInfo = WeatherForecast(hourly: [], daily: [])
    @Published var fetchState: FetchState = .none

    var parent: MainScreemCoordinator
    
    init(parent: MainScreemCoordinator, viewModel: WeatherDetailsViewModel) {
        self.parent = parent
        self.viewModel = viewModel
        
        viewModel.$currentInfo
                    .receive(on: RunLoop.main)
                    .assign(to: &$currentInfo)
        viewModel.$forecastInfo
                    .receive(on: RunLoop.main)
                    .assign(to: &$forecastInfo)
        viewModel.$fetchState
                    .receive(on: RunLoop.main)
                    .assign(to: &$fetchState)
    }
    
    func deleteButtonPressed() {
        guard let currentInfo = viewModel.currentInfo else { return }
        parent.deleteButtonPressed(info: currentInfo.currentWeather)
    }
    
    func signoutButtonPressed() {
        do {
            try viewModel.signedOut()
            parent.signoutButtonPressed()
        } catch {
            print("Signing out failed")
        }
    }
}
