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
    
    private var locationService: LocationServiceInterface
    private var networkService: any NetworkServiceProtocol
    private var notificationsFactory: UserNotificationsFactoryInterface
    private var backgroundTaskManagery: BackgroundTasksManagerInterface

    private var cancellables: [AnyCancellable] = []
    
    init(locationService: LocationServiceInterface = LocationService(),
         networkService: any NetworkServiceProtocol = NetworkServiceProvider(),
         notifications: UserNotificationsFactoryInterface = UserNatificationFactory(),
         backgroundTaskManagery: BackgroundTasksManagerInterface = BackgroundTasksManager()) {
        self.locationService = locationService
        self.networkService = networkService
        self.notificationsFactory = notifications
        self.backgroundTaskManagery = backgroundTaskManagery
    }
    
    func startUserNotif() {
        let locationService = LocationService()
        locationService.latestLocationObject.sink { completion in
        } receiveValue: { [weak self] location in
            guard let self else { return }

            let request = RequestFactory.currentWeatherRequest(coordinates: Coordinates(lon: location.coordinate.longitude,
                                                                                        lat: location.coordinate.longitude))
            self.networkService.requestData(request,
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
    
    func scheduleDailyNotification(weather: CurrentWeather) {
        notificationsFactory.scheduleDailyNotification(weather: weather)
    }
    
    func setupBackgroundRequest(phase: ScenePhase) {
        backgroundTaskManagery.setupBackgroundRequest(phase: phase,
                                                      identifier: Self.appRefreshIdentifier)
    }
    
    func scheduleAppRefreshTask() {
        backgroundTaskManagery.scheduleAppRefreshTask(identifier: Self.appRefreshIdentifier)
      }
}
