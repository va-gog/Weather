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
    @ObservedObject var viewModel: MainScreenViewModel
    @Published var locationStatus: LocationAuthorizationStatus = .notDetermined
    
    var parent: AuthenticationScreenCoordinator

    private var cancellables: [AnyCancellable] = []

    init(viewModel: MainScreenViewModel, parent: AuthenticationScreenCoordinator) {
        self.viewModel = viewModel
        self.parent = parent
        viewModel.$locationStatus
                    .receive(on: RunLoop.main)
                    .assign(to: &$locationStatus)
    }
    
    func deleteButtonPressed(info: CurrentWeather) {
        viewModel.deleteButtonPressed(info: info)
    }
    
    func signoutButtonPressed() {
        parent.changeState(.unauthenticated)
    }
    
    func updateLocation(status: LocationAuthorizationStatus) {
        locationStatus = status
    }
}
