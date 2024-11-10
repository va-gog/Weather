//
//  MockAppLaunchScreenDependencies.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

@testable import Weather

struct MockAppLaunchScreenDependencies: AppLaunchScreenDependenciesInterface {
    var locationService: LocationServiceInterface = MockLocationService()
    var auth: AuthInterface = MockAuth()
}
