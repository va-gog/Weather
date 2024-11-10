//
//  MainScreenDependenciesInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

protocol MainScreenDependenciesInterface {
    var locationService: LocationServiceInterface { get }
    var storageManager: StorageManagerInterface { get }
    var networkService: NetworkServiceProtocol { get }
    var auth: AuthInterface { get }
}
