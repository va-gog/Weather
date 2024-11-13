//
//  DependencyManagerInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

protocol DependencyManagerInterface {
    func createAppLaunchScreenDependencies() -> AppLaunchScreenDependenciesInterface
    func createAuthenticationScreenDependencies() -> AuthenticationScreenDependenciesInterface
    func createMainScreenDependencies() -> MainScreenDependenciesInterface
    func createForecastScreenDependencies() -> ForecastScreenDependenciesInterface
    func createWeatherAppViewDependencies() -> WeatherAppViewDependenciesInterface
}
