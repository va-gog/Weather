//
//  WeatherAppViewDependenciesInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 13.11.24.
//

protocol WeatherAppViewDependenciesInterface {
    var locationService: LocationServiceInterface { get }
    var networkService: NetworkServiceProtocol { get }
    var notificationsFactory: UserNotificationsFactoryInterface { get }
    var backgroundTaskManagery: BackgroundTasksManagerInterface { get }
}
