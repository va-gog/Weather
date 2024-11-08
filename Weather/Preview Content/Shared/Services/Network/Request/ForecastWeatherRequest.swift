//
//  ForecastWeatherRequest.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

struct ForecastWeatherRequest: NetworkRequest {
    private var coordinates: Coordinates
    private var exclude: [String]
    private var unit: WeatherUnit
    
    init(coordinates: Coordinates, exclude: [String] = [], unit: WeatherUnit = .celsius) {
        self.coordinates = coordinates
        self.exclude = exclude
        self.unit = unit
    }
    
    var path: String {
        let path = URLFactory.url(for: .forecast)
        let exclude = exclude.joined(separator: ",")
        let key = URLFactory.appendAPIKey(for: .forecast)
        let queryString = "?lat=\(coordinates.lat)&lon=\(coordinates.lon)&units=\(unit.rawValue)&exclude=\(exclude)&appid=\(key)"
        return path + queryString
    }
}
