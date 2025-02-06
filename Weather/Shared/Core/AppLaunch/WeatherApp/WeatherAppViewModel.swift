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
    
    @Dependency private var locationService: LocationServiceInterface
    @Dependency private var networkService: NetworkServiceProtocol
    @Dependency private var notificationsFactory: UserNotificationsFactoryInterface
    @Dependency private var backgroundTaskManagery: BackgroundTasksManagerInterface
    
    private var cancellables: [AnyCancellable] = []
    
    init() {
        backgroundTaskManagery.setupBackgroundRequest(with: Self.appRefreshIdentifier) { [weak self] task in
            self?.startUserNotif(task: task)
        }
    }
    
    func startUserNotif(task: BGTaskInterface) {
        let locationService = locationService
        locationService.startTracking()
        locationService.latestLocationObject.sink { completion in
        } receiveValue: { [weak self] location in
            guard let self else { return }
            
            let request = RequestFactory.currentWeatherRequest(coordinates: Coordinates(lon: location.coordinate.longitude,
                                                                                        lat: location.coordinate.longitude))
            self.networkService.requestData(request,
                                                         as: CurrentWeather.self).sink { _ in
            } receiveValue: { weather in
                self.scheduleDailyNotification(weather: weather)
                task.setTaskCompleted(success: true)
            }
            .store(in: &self.cancellables)
        }
        .store(in: &cancellables)
    }
    
    func submitBackgroundTasks() {
        backgroundTaskManagery.submitBackgroundTasks(with: Self.appRefreshIdentifier)
    }
    
    
    private func scheduleDailyNotification(weather: CurrentWeather) {
        notificationsFactory.scheduleDailyNotification(weather: weather)
    }
}
