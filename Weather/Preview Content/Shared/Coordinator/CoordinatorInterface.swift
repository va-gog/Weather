//
//  CoordinatorInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 10.11.24.
//

protocol CoordinatorInterface {
    var dependenciesManager: DependencyManagerInterface { get }
    
    func pushForecastView(selectedCity: City, style: WeatherDetailsViewStyle, currentInfo: WeatherCurrentInfo?)
    func push(page: AppPages)
    func pop(_ page: PopAction)
    func popForecastViewWhenDeleted(info: WeatherCurrentInfo?)
    func popForecastViewWhenAdded(info: WeatherCurrentInfo?)
}
