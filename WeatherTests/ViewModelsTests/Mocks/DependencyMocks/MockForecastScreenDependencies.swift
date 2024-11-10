//
//  MockForecastScreenDependencies.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

@testable import Weather

struct MockForecastScreenDependencies: ForecastScreenDependenciesInterface {
    var networkService: NetworkServiceProtocol = MockNetworkManager()
    var auth: AuthInterface = MockAuth()
    var infoConverter: WeatherInfoToPresentationInfoConverterInterface = MockWeatherInfoToPresentationInfoConverter()
}
