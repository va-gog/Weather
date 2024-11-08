//
//  CoordinatorScreenDependenciesInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

protocol CoordinatorScreenDependenciesInterface {
    var locationService: LocationServiceInterface { get }
    var auth: AuthInterface  { get }
}
