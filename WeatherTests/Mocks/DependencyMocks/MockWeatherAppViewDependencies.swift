//
//  MockWeatherAppViewDependencies.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

@testable import Weather

struct MockWeatherAppViewDependencies: WeatherAppViewDependenciesInterface {
    var locationService: LocationServiceInterface
    var networkService: NetworkServiceProtocol
    var notificationsFactory: UserNotificationsFactoryInterface
    var backgroundTaskManagery: BackgroundTasksManagerInterface
}
