//
//  CoordinatorScreenDependencies.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

struct CoordinatorScreenDependencies: CoordinatorScreenDependenciesInterface {
    var locationService: LocationServiceInterface
    var auth: AuthInterface
}
