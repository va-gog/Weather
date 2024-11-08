//
//  CurrentWeatherRequest.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

struct CurrentWeatherRequest: NetworkRequest {
    
    private var coordinates: Coordinates
    private var unit: WeatherUnit
    
    init(coordinates: Coordinates, exclude: [String] = [], unit: WeatherUnit = .celsius) {
        self.coordinates = coordinates
        self.unit = unit
    }
    
    var path: String {
        let path = URLFactory.url(for: .current)
        let key = URLFactory.appendAPIKey(for: .current)
        let queryString = "?lat=\(coordinates.lat)&lon=\(coordinates.lon)&units=\(unit.rawValue)&appid=\(key)"
        return path + queryString
    }
}
