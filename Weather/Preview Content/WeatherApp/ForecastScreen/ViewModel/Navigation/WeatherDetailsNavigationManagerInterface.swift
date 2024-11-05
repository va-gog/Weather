//
//  WeatherDetailsNavigationManagerInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 05.11.24.
//

protocol WeatherDetailsNavigationManagerInterface {
    var parent: MainScreenNavigationManagerInterface { get }

    func delete(weather: CurrentWeather)
    func signout()
    func addFavorite(weather: WeatherCurrentInfo)
    func close()
}
 
