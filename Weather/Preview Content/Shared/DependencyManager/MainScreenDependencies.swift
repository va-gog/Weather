//
//  MainScreenDependencies.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

struct MainScreenDependencies: MainScreenDependenciesInterface {
    var locationService: LocationServiceInterface
    var storageManager: DataStorageManagerInterface
    var networkService: NetworkServiceProtocol
    var auth: AuthInterface
}
