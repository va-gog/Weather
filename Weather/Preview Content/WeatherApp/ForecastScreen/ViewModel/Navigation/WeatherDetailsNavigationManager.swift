//
//  WeatherDetailsNavigationManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 01.11.24.
//

import SwiftUI
   
final class WeatherDetailsNavigationManager: ObservableObject, WeatherDetailsNavigationManagerInterface {
    var parent: MainScreenNavigationManagerInterface
    
    init(parent: MainScreenNavigationManagerInterface) {
        self.parent = parent
    }
    
    func delete(weather: CurrentWeather) {
        parent.deleteButtonPressed(info: weather)
        parent.closeForecastScreen()
    }
    
    func signout() {
        parent.signoutButtonPressed()
        parent.closeForecastScreen()
    }
    
    func addFavorite(weather: WeatherCurrentInfo) {
        parent.addFavoriteWeather(with: weather)
    }
    
    func close() {
        parent.closeForecastScreen()
    }
}
