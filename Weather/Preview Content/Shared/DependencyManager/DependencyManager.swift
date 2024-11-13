//
//  DependencyManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

class DependencyManager: DependencyManagerInterface {
    private lazy var locationService: LocationServiceInterface = {
        LocationService()
    }()
    
    private lazy var keychain: KeychainManagerInterface = {
        KeychainManager()
    }()
    
    private lazy var storageManager: StorageManagerInterface = {
        StorageManager(storageService: StorageService())
    }()

    private lazy var weatherInfoConverter: WeatherInfoToPresentationInfoConverter = {
        WeatherInfoToPresentationInfoConverter()
    }()

    private lazy var notificationFactory: UserNotificationFactory = {
        UserNotificationFactory()
    }()

    private lazy var backgroundTaskManager: BackgroundTasksManager = {
        BackgroundTasksManager()
    }()
    
    private lazy var networkService: any NetworkServiceProtocol = {
        NetworkServiceProvider()
    }()
    
    private lazy var auth: any AuthInterface = {
        AuthWrapper()
    }()
    
    func createAuthenticationScreenDependencies() -> AuthenticationScreenDependenciesInterface {
        AuthenticationScreenDependencies(keychain: keychain,
                                         auth: auth)
    }
    
    func createMainScreenDependencies() -> MainScreenDependenciesInterface {
        MainScreenDependencies(
            locationService: locationService,
            storageManager: storageManager,
            networkService: networkService,
            auth: auth
        )
    }
    
    func createForecastScreenDependencies() -> ForecastScreenDependenciesInterface {
        ForecastScreenDependencies(
            networkService: networkService,
            auth: auth,
            infoConverter: weatherInfoConverter
        )
    }
    
    func createAppLaunchScreenDependencies() -> AppLaunchScreenDependenciesInterface {
        AppLaunchScreenDependencies(locationService: locationService,
                                    auth: auth)
    }
    
    func createWeatherAppViewDependencies() -> WeatherAppViewDependenciesInterface {
        WeatherAppViewDependencies(locationService: locationService,
                                   networkService: networkService,
                                   notificationsFactory: notificationFactory,
                                   backgroundTaskManagery: backgroundTaskManager)
    }
}
