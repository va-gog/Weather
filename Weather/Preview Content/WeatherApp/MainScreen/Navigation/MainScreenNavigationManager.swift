//
//  MainScreenNavigationManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 01.11.24.
//


import Combine
import SwiftUI

final class MainScreenNavigationManager: ObservableObject, MainScreenNavigationManagerInterface {
    var navigationAction = PassthroughSubject<MainScreenNavigationAction, Never>()
    var deletedWeatherSubject = PassthroughSubject<CurrentWeather, Never>()
    var addedWeatherSubject = PassthroughSubject<WeatherCurrentInfo, Never>()
    var locationStatueSubject = PassthroughSubject<LocationAuthorizationStatus, Never>()
    var parent: AuthenticationScreenNavigationManagerInterface
    
    private var cancellables: [AnyCancellable] = []
    
    init(parent: AuthenticationScreenNavigationManagerInterface) {
        self.parent = parent
    }
    
    func deleteButtonPressed(info: CurrentWeather) {
        deletedWeatherSubject.send(info)
//        action = .weatherDelete(info)
    }
    
    func addFavoriteWeather(with info: WeatherCurrentInfo) {
        addedWeatherSubject.send(info)
//        action = .favoriteWeatherAdd(info)
    }
    
    func signoutButtonPressed() {
        parent.changeState(.unauthenticated)
    }
    
    func updateLocation(status: LocationAuthorizationStatus) {
        locationStatueSubject.send(status)
//        action = .locationChange(status)
    }
    
    func closeForecastScreen() {
        navigationAction.send(.forecastScreenClose)
    }
}
