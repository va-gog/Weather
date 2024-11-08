//
//  DependencyManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

protocol DependencyManagerInterface {
    func mainScreenDependencies() -> MainScreenDependenciesInterface
    func forecastScreenDependencies() -> ForecastScreenDependenciesInterface
    func coordinatorScreenDependencies() -> CoordinatorScreenDependenciesInterface
}

class DependencyManager: DependencyManagerInterface {
    private lazy var locationService: LocationServiceInterface = {
        LocationService()
    }()
    
    private var storageManager: DataStorageManagerInterface = {
        StorageManager()
    }()
    
    private let networkService: NetworkServiceProtocol
    
    private let auth: AuthInterface
    
    init(networkService: any NetworkServiceProtocol = NetworkServiceProvider(),
         auth: AuthInterface = AuthWrapper()) {
        self.networkService = networkService
        self.auth = auth
    }

    
    func mainScreenDependencies() -> MainScreenDependenciesInterface {
        MainScreenDependencies(
            locationService: locationService,
            storageManager: storageManager,
            networkService: networkService,
            auth: auth
        )
    }
    
    func forecastScreenDependencies() -> ForecastScreenDependenciesInterface {
        ForecastScreenDependencies(
            networkService: networkService,
            auth: auth,
            infoConverter: WeatherInfoToPresentationInfoConverter()
        )
    }
    
    func coordinatorScreenDependencies() -> CoordinatorScreenDependenciesInterface {
        CoordinatorScreenDependencies(locationService: locationService,
                                      auth: auth)
    }
}
