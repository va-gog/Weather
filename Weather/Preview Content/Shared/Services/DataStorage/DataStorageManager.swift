//
//  DataStorageManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import CoreLocation

final class DataStorageManager: DataStorageManagerInterface {
    func addWeatherIntoStorage(_ data: WeatherCurrentInfo) {}
    
    func removeWeatherFromStorage(_ data: WeatherCurrentInfo) {}
    
    func fetchAddedWeatherCoordinates() async throws ->  [CLLocationCoordinate2D] {
        return []
    }
}
