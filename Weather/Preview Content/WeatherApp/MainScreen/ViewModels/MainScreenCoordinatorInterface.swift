//
//  MainScreenCoordinatorInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 15.11.24.
//

protocol MainScreenCoordinatorInterface: AnyObject, CoordinatorInterface {
    func pushForecastView(selectedCity: City, style: WeatherDetailsViewStyle, currentInfo: WeatherCurrentInfo?)
    func popForecastViewWhenDeleted(info: WeatherCurrentInfo?)
    func popForecastViewWhenAdded(info: WeatherCurrentInfo?)
}
