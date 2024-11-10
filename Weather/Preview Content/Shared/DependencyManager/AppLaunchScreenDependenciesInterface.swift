//
//  AppLaunchScreenDependenciesInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

protocol AppLaunchScreenDependenciesInterface {
    var locationService: LocationServiceInterface { get }
    var auth: AuthInterface  { get }
}
