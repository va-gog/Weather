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
    
    private var storageManager: StorageManagerInterface = {
        StorageManager(storageService: StorageService())
    }()
    
    private var weatherInfoConverter = WeatherInfoToPresentationInfoConverter()
    private let networkService: NetworkServiceProtocol
    
    private let auth: AuthInterface
    private let notificationFactory = UserNatificationFactory()
    private let backgroundTaskManager = BackgroundTasksManager()
    
    
    init(networkService: any NetworkServiceProtocol = NetworkServiceProvider(),
         auth: AuthInterface = AuthWrapper()) {
        self.networkService = networkService
        self.auth = auth
    }
    
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
    
    func createWeatherAppViewDependencied() -> WeatherAppViewDependenciesInterface {
        WeatherAppViewDependencies(locationService: locationService,
                                   networkService: networkService,
                                   notificationsFactory: notificationFactory,
                                   backgroundTaskManagery: backgroundTaskManager)
    }
}
