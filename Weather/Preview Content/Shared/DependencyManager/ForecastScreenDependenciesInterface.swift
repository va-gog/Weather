//
//  ForecastScreenDependenciesInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

protocol ForecastScreenDependenciesInterface {
    var networkService: NetworkServiceProtocol { get }
    var auth: AuthInterface { get }
    var infoConverter: WeatherInfoToPresentationInfoConverterInterface { get }
}
