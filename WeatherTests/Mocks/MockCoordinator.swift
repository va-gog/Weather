//
//  MockCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

@testable import Weather

final class MockCoordinator: CoordinatorInterface {
    
    var dependenciesManager: DependencyManagerInterface
    var selectedCity: City?
    var style: WeatherDetailsViewStyle?
    var currentInfo: WeatherCurrentInfo?
    var popAction: PopAction?
    var pushedPage: AppPages?
    
    init(dependenciesManager: DependencyManagerInterface) {
        self.dependenciesManager = dependenciesManager
    }
    
    func pushForecastView(selectedCity: City,
                          style: WeatherDetailsViewStyle,
                          currentInfo: WeatherCurrentInfo?) {
        self.selectedCity = selectedCity
        self.style = style
        self.currentInfo = currentInfo
    }
    
    func pushMainScreen() {
        pushedPage = .main
    }
    
    func popForecastViewWhenDeleted(info: WeatherCurrentInfo?) {
        currentInfo = info
    }
    
    func popForecastViewWhenAdded(info: WeatherCurrentInfo?) {
        currentInfo = info
    }
    
    func push(page: AppPages) {
        pushedPage = page
    }
    
    func pop(_ page: PopAction) {
        popAction = page
    }
}

