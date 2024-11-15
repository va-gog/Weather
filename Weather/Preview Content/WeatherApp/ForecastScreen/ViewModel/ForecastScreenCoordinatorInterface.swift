//
//  ForecastScreenCoordinatorInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 15.11.24.
//

protocol ForecastScreenCoordinatorInterface: AnyObject, CoordinatorInterface {
    func cancel()
    func signOut()
    func closeWhenDeleted(info: WeatherCurrentInfo?)
    func closeWhenAdded(info: WeatherCurrentInfo?)
}
