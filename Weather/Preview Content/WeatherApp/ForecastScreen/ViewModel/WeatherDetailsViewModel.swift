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
    private(set) var style: WeatherDetailsViewStyle
    private weak var coordinator: ForecastScreenCoordinatorInterface?
    private var dependencies: ForecastScreenDependenciesInterface
    private var cancellables: [AnyCancellable] = []
    
    init(selectedCity: City,
         style: WeatherDetailsViewStyle,
         coordinator: ForecastScreenCoordinatorInterface,
         currentInfo: WeatherCurrentInfo?) {
        self.selectedCity = selectedCity
        self.style = style
        self.coordinator = coordinator
        self.dependencies = coordinator.dependenciesManager.createForecastScreenDependencies()
        self.currentInfo = currentInfo
    }
    
    func addFavoriteWeather() {
        Task { @MainActor in
            coordinator?.closeWhenAdded(info: currentInfo)
        }
    }
    
    func deleteButtonAction() {
        Task { @MainActor in
            coordinator?.closeWhenDeleted(info: currentInfo)
        }
    }
    
    func signedOut() throws {
        do {
            coordinator?.signOut()
            try dependencies.auth.signOut()
        } catch {
            throw AppError.signOutFail
        }
    }
    
    func close() {
        Task { @MainActor in
            coordinator?.cancel()
        }
    }
    
    func bottomToolbarTabs() -> [TabItem] {
        let deleteDisabled = (currentInfo?.isMyLocation ?? false) || style == .overlay
        let disabledButtons = deleteDisabled ? [ForecastScreenToolbarTabType.remove] : []
        return TabItemFactory().createBottomToolbarItems(enabledTypes: disabledButtons)
    }
    
    func fetchWeatherCurrentInfo(unit: WeatherUnit = .celsius) {
        if currentInfo == nil {
            let request = RequestFactory.currentWeatherRequest(coordinates: Coordinates(lon: selectedCity.lon,
                                                                                        lat: selectedCity.lat))
            dependencies.networkService.requestData(request, as: CurrentWeather.self)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    if case .failure(let error) = completion {
                        let fetchError = AppError.appError(error: error)
                        self?.fetchState = .failed(fetchError)
                    }
                } receiveValue: { [weak self] current in
                    self?.fetchState = .succeed
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
                    let fetchError = AppError.appError(error: error)
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
                               icon: dependencies.infoConverter.weatherIcon(for: currentInfo.currentWeather.weather.first?.main))
        }
        return nil
    }
    
    func hourlyViewPresentationInfo(index: Int, unit: WeatherUnit) -> HourlyForecastViewInfo? {
        if forecastInfo.hourly.indices.contains(index) {
            let hourly = forecastInfo.hourly[index]
            return HourlyForecastViewInfo(name: hourly.name,
                                          temperature: dependencies.infoConverter.convertTemperatureToText(temp: hourly.temp,
                                                                                                           unit: unit),
                                          icon: dependencies.infoConverter.weatherIcon(for: hourly.weather.first?.main))
        }
        return nil
    }
    
    func dailyViewPresentationInfo(index: Int, unit: WeatherUnit) -> DailyForecastViewInfo? {
        if forecastInfo.daily.indices.contains(index) {
            let daily = forecastInfo.daily[index]
            return DailyForecastViewInfo(name: daily.name,
                                         icon: dependencies.infoConverter.weatherIcon(for: daily.weather.first?.main),
                                         dailyForecast: daily.weather.first?.main ?? "",
                                         tempMin: LocalizedText.high + ":" + dependencies.infoConverter.convertTemperatureToText(temp: daily.temp.min,
                                                                                                                                 unit: unit),
                                         tempMax:LocalizedText.low + ":" + dependencies.infoConverter.convertTemperatureToText(temp: daily.temp.max,
                                                                                                                               unit: unit))
        }
        return nil
    }
}
