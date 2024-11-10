//
//  DependencyManagerInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

protocol WeatherAppViewDependenciesInterface {
    var locationService: LocationServiceInterface { get }
    var networkService: NetworkServiceProtocol { get }
    var notificationsFactory: UserNotificationsFactoryInterface { get }
    var backgroundTaskManagery: BackgroundTasksManagerInterface { get }
}

struct WeatherAppViewDependencies: WeatherAppViewDependenciesInterface {
    var locationService: LocationServiceInterface
    var networkService: any NetworkServiceProtocol
    var notificationsFactory: UserNotificationsFactoryInterface
    var backgroundTaskManagery: BackgroundTasksManagerInterface
}

protocol DependencyManagerInterface {
    func createAppLaunchScreenDependencies() -> AppLaunchScreenDependenciesInterface
    func createAuthenticationScreenDependencies() -> AuthenticationScreenDependenciesInterface
    func createMainScreenDependencies() -> MainScreenDependenciesInterface
    func createForecastScreenDependencies() -> ForecastScreenDependenciesInterface
    func createWeatherAppViewDependencied() -> WeatherAppViewDependenciesInterface
}
