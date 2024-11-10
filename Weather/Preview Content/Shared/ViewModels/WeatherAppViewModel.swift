//
//  WeatherAppViewModel.swift
//  Weather
//
//  Created by Gohar Vardanyan on 27.10.24.
//

import BackgroundTasks
import Combine
import UserNotifications
import SwiftUI
import CoreLocation

final class WeatherAppViewModel {
    static let appRefreshIdentifier = "com.weather.notifications.scheduler"
    
    @ObservedObject var coordinatorViewModel: AppLaunchViewModel

    private var dependencies: WeatherAppViewDependenciesInterface
    private var cancellables: [AnyCancellable] = []
    
    init(dependencyManager: DependencyManagerInterface) {
        self.coordinatorViewModel = AppLaunchViewModel(coordinator: Coordinator(dependenciesManager: dependencyManager))
        self.dependencies = dependencyManager.createWeatherAppViewDependencied()
    }
    
    func startUserNotif() {
        let locationService = dependencies.locationService
        locationService.latestLocationObject.sink { completion in
        } receiveValue: { [weak self] location in
            guard let self else { return }
            
            let request = RequestFactory.currentWeatherRequest(coordinates: Coordinates(lon: location.coordinate.longitude,
                                                                                        lat: location.coordinate.longitude))
            self.dependencies.networkService.requestData(request,
                                                         as: CurrentWeather.self).sink { _ in
                print("Could't fetch current location to start notifications")
            } receiveValue: { weather in
                self.scheduleDailyNotification(weather: weather)
            }
            .store(in: &self.cancellables)
        }
        .store(in: &cancellables)
        locationService.startTracking()
    }
    
    func setupBackgroundRequest(phase: ScenePhase) {
        dependencies.backgroundTaskManagery.setupBackgroundRequest(phase: phase,
                                                                   identifier: Self.appRefreshIdentifier)
    }
    
    func scheduleAppRefreshTask() {
        dependencies.backgroundTaskManagery.scheduleAppRefreshTask(identifier: Self.appRefreshIdentifier)
    }
    
    private func scheduleDailyNotification(weather: CurrentWeather) {
        dependencies.notificationsFactory.scheduleDailyNotification(weather: weather)
    }
}
