//
//  WeatherAppViewDependencies.swift
//  Weather
//
//  Created by Gohar Vardanyan on 13.11.24.
//

struct WeatherAppViewDependencies: WeatherAppViewDependenciesInterface {
    var locationService: LocationServiceInterface
    var networkService: any NetworkServiceProtocol
    var notificationsFactory: UserNotificationsFactoryInterface
    var backgroundTaskManagery: BackgroundTasksManagerInterface
}
