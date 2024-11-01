//
//  MainScreemCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 01.11.24.
//


import Combine
import SwiftUI

@MainActor
final class MainScreemCoordinator: ObservableObject {
    private var cancellables: [AnyCancellable] = []
    
    @Published var locationStatus: LocationAuthorizationStatus = .notDetermined
    @ObservedObject var viewModel: MainScreenViewModel
    
    init(viewModel: MainScreenViewModel) {
        self.viewModel = viewModel
        viewModel.$locationStatus
                    .receive(on: RunLoop.main)
                    .assign(to: &$locationStatus)
    }
    
    func deleteButtonPressed(info: CurrentWeather) {
        viewModel.deleteButtonPressed(info: info)
    }
    
    func updateLocation(status: LocationAuthorizationStatus) {
        locationStatus = status
    }
}
