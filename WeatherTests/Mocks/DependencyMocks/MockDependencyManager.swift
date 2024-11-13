//
//  MockDependencyManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

@testable import Weather

struct MockDependencyManager: DependencyManagerInterface {
    var auth: AuthInterface?
    var keychain: KeychainManagerInterface?
    var storageManager: StorageManagerInterface?
    var networkService: NetworkServiceProtocol?
    var locationService: LocationServiceInterface?
    var weatherInfoConverter:  MockWeatherInfoToPresentationInfoConverter?
    var notificationFactory: UserNotificationsFactoryInterface?
    
    func createAppLaunchScreenDependencies() -> AppLaunchScreenDependenciesInterface {
        MockAppLaunchScreenDependencies(locationService: locationService ?? LocationService(),
                                        auth: auth ?? MockAuth())
    }
    
    func createAuthenticationScreenDependencies() -> AuthenticationScreenDependenciesInterface {
        MockAuthenticationScreenDependencies(keychain: keychain ?? MockKeychainManager(),
                                             auth: auth ?? MockAuth())
    }
    
    func createMainScreenDependencies() -> MainScreenDependenciesInterface {
        MockMainScreenDependencies(locationService: locationService ?? MockLocationService(),
                                   storageManager: storageManager ?? MockDataStorageManager(storageService: StorageService()),
                                   networkService: networkService ?? MockNetworkManager(),
                                   auth: auth ?? MockAuth())
    }
    
    func createForecastScreenDependencies() -> ForecastScreenDependenciesInterface {
        MockForecastScreenDependencies(networkService: networkService ?? MockNetworkManager(),
                                       auth: auth ?? MockAuth(),
                                       infoConverter: weatherInfoConverter ?? MockWeatherInfoToPresentationInfoConverter())
    }
    
    func createWeatherAppViewDependencies() -> WeatherAppViewDependenciesInterface {
        MockWeatherAppViewDependencies(locationService: locationService ?? LocationService(),
                                       networkService: networkService ?? NetworkServiceProvider(),
                                       notificationsFactory: notificationFactory ?? MockUserNotificationsFactory(),
                                       backgroundTaskManagery: MockBackgroundTasksManager())
    }
    
}
