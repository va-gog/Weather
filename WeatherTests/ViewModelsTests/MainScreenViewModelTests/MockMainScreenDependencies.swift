//
//  MockMainScreenDependencies.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

@testable import Weather

struct MockMainScreenDependencies: MainScreenDependenciesInterface {
    var locationService: LocationServiceInterface
    var storageManager: StorageManagerInterface
    var networkService: NetworkServiceProtocol
    var auth: AuthInterface
}
