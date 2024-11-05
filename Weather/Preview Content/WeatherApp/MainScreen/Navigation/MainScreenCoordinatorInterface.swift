//
//  MainScreenCoordinatorInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 05.11.24.
//

import Combine

protocol MainScreenNavigationManagerInterface {
    var navigationAction: PassthroughSubject<MainScreenNavigationAction, Never> { get }
    var deletedWeatherSubject: PassthroughSubject<CurrentWeather, Never> { get }
    var addedWeatherSubject: PassthroughSubject<WeatherCurrentInfo, Never> { get }
    var locationStatueSubject: PassthroughSubject<LocationAuthorizationStatus, Never> { get }
    var parent: AuthenticationScreenNavigationManagerInterface { get }
    
    func updateLocation(status: LocationAuthorizationStatus)
    func deleteButtonPressed(info: CurrentWeather)
    func addFavoriteWeather(with info: WeatherCurrentInfo)
    func signoutButtonPressed()
    func closeForecastScreen()
}
