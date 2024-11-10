//
//  ForecastScreenDependencies.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

struct ForecastScreenDependencies: ForecastScreenDependenciesInterface {
    var networkService: NetworkServiceProtocol
    var auth: AuthInterface
    var infoConverter: WeatherInfoToPresentationInfoConverterInterface
}
