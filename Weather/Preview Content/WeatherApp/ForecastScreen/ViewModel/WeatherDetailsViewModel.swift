//
//  WeatherDetailsViewModel.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Combine
import CoreLocation
import SwiftUI

final class WeatherDetailsViewModel: ObservableObject {
    @Published var currentInfo: WeatherCurrentInfo?
    @Published var forecastInfo = WeatherForecast(hourly: [], daily: [])
    @Published var fetchState: FetchState = .none
    
    private var selectedCity: City
    private var style: WeatherDetailsViewStyle
    private var coordinator: CoordinatorInterface
    private var dependencies: ForecastScreenDependenciesInterface
    private var cancellables: [AnyCancellable] = []
    
    init(selectedCity: City,
         style: WeatherDetailsViewStyle,
         coordinator: CoordinatorInterface,
         currentInfo: WeatherCurrentInfo?) {
        self.selectedCity = selectedCity
        self.style = style
        self.coordinator = coordinator
        self.dependencies = coordinator.dependenciesManager.forecastScreenDependencies()
        self.currentInfo = currentInfo
    }
    
    func addFavoriteWeather() {
        guard let currentInfo else { return }
        Task { @MainActor in
            coordinator.popForecastViewWhenAdded(info: currentInfo)
        }
    }
    
    func deleteButtonAction() {
        guard let currentInfo else { return }
        Task { @MainActor in
            coordinator.popForecastViewWhenDeleted(info: currentInfo)
        }
    }
    
    func signedOut() throws {
        Task { @MainActor in
            do {
                coordinator.pop(.signOut)
                try dependencies.auth.signOut()
            } catch {
                print("Signing out failed")
            }
        }
    }
    
    func close() {
        Task { @MainActor in
            coordinator.pop(PopAction.forecastClose)
        }
    }
    
    func presentationStyle() -> WeatherDetailsViewStyle {
        return style
    }
    
    func fetchWeatherCurrentInfo(unit: WeatherUnit = .celsius) {
        if currentInfo == nil {
            let request = RequestFactory.currentWeatherRequest(coordinates: Coordinates(lon: selectedCity.lon,
                                                                                        lat: selectedCity.lat))
            dependencies.networkService.requestData(request, as: CurrentWeather.self)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    if case .failure(let error) = completion {
                        let fetchError = AppError.convertToFetchError(error: error)
                        self?.fetchState = .failed(fetchError)
                    }
                } receiveValue: { [weak self] current in
                    self?.currentInfo = WeatherCurrentInfo(currentWeather: current,
                                                           unit: unit,
                                                           isMyLocation: self?.currentInfo?.isMyLocation ?? false)
                }
                .store(in: &cancellables)
            
        }
        
    }
    
    func fetchForecastInfo() {
        let request = RequestFactory.forecastWeatherRequest(coordinates: Coordinates(lon: selectedCity.lon,
                                                                                     lat: selectedCity.lat))
        dependencies.networkService.requestData(request, as: WeatherForecast.self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    let fetchError = AppError.convertToFetchError(error: error)
                    self?.fetchState = .failed(fetchError)
                }
            } receiveValue: { [weak self] forecast in
                self?.forecastInfo = forecast
            }
            .store(in: &cancellables)
        
    }
    
    func topViewPresentationInfo(currentInfo: WeatherCurrentInfo?) -> TopViewInfo? {
        if let currentInfo {
            return TopViewInfo(name: dependencies.infoConverter.currentLocationTitle(isMyLocation: currentInfo.isMyLocation,
                                                                                     name: currentInfo.currentWeather.name),
                               city: currentInfo.currentWeather.name,
                               temperature: dependencies.infoConverter.convertTemperatureToText(temp: currentInfo.currentWeather.main.temp,
                                                                                                unit: currentInfo.unit),
                               isMyLocation: currentInfo.isMyLocation,
                               icon: weatherIcon(for: currentInfo.currentWeather.weather.first?.main ?? ""))
        }
        return nil
    }
    
    func hourlyViewPresentationInfo(index: Int, currentInfo: WeatherCurrentInfo?) -> HourlyForecastViewInfo? {
        if let currentInfo {
            let hourly = forecastInfo.hourly[index]
            return HourlyForecastViewInfo(name: hourly.name,
                                          temperature: dependencies.infoConverter.convertTemperatureToText(temp: hourly.temp,
                                                                                                           unit: currentInfo.unit),
                                          icon: weatherIcon(for: hourly.weather.first?.main ?? ""))
        }
        return nil
    }
    
    func dailyViewPresentationInfo(index: Int) -> DailyForecastViewInfo? {
        if let currentInfo {
            let daily = forecastInfo.daily[index]
            return DailyForecastViewInfo(name: daily.name,
                                         icon: weatherIcon(for: daily.weather.first?.main ?? ""),
                                         dailyForecast: daily.weather.first?.main ?? "",
                                         tempMin: LocalizedText.high + ":" + dependencies.infoConverter.convertTemperatureToText(temp: daily.temp.min,
                                                                                                                                 unit: currentInfo.unit),
                                         tempMax:LocalizedText.low + ":" + dependencies.infoConverter.convertTemperatureToText(temp: daily.temp.max,
                                                                                                                               unit: currentInfo.unit))
        }
        return nil
    }
    
    func weatherIcon(for condition: String) -> String {
        switch condition {
        case "Clear":
            return AppIcons.clear
        case "Clouds":
            return  AppIcons.clouds
        case "Rain":
            return  AppIcons.rain
        case "Snow":
            return  AppIcons.snow
        default:
            return  AppIcons.otherWeather
        }
    }
}
