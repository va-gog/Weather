//
//  RequestFactory.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

struct RequestFactory {
    static func currentWeatherRequest(coordinates: Coordinates, unit: WeatherUnit = .celsius) -> NetworkRequest {
        CurrentWeatherRequest(coordinates: coordinates, unit: unit)
    }
    
    static func forecastWeatherRequest(coordinates: Coordinates, unit: WeatherUnit = .celsius) -> NetworkRequest {
        let excludes = [OneCallApiExclude.current.rawValue,
                        OneCallApiExclude.minutely.rawValue,
                        OneCallApiExclude.alerts.rawValue]
        return ForecastWeatherRequest(coordinates: coordinates,
                                      exclude: excludes,
                                      unit: .celsius)
    }
    
    static func locationSearchRequest(_ location: String) -> NetworkRequest {
        GeolocationsRequest(geo: location)
    }
}
