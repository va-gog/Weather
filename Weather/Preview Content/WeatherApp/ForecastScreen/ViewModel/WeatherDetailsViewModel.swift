//
//  WeatherDetailsViewModel.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Foundation
import Combine
import CoreLocation
import SwiftUI

final class WeatherDetailsViewModel: ObservableObject {
    @Published var currentInfo: WeatherCurrentInfo?
    @Published var forecastInfo = WeatherForecast(hourly: [], daily: [])
    @Published var fetchState: FetchState = .none
    
    @Binding var style: WeatherDetailsViewStyle
    
    private var selectedCity: City
    private var networkManager: any NetworkManagerProtocol
    private var infoConverter: WeatherInfoToPresentationInfoConverter
    private var addedWaetherInfo = PassthroughSubject<WeatherCurrentInfo, Never>()
    private var cancellables: [AnyCancellable] = []
        
    init(selectedCity: City,
         style: Binding<WeatherDetailsViewStyle>,
         networkManager: any NetworkManagerProtocol = NetworkManager(),
         infoConverter: WeatherInfoToPresentationInfoConverter = WeatherInfoToPresentationInfoConverter(),
         currentInfo: WeatherCurrentInfo? = nil,
         addedWaetherInfo: PassthroughSubject<WeatherCurrentInfo, Never> = PassthroughSubject<WeatherCurrentInfo, Never>()){
        self.selectedCity = selectedCity
        self.networkManager = networkManager
        self.infoConverter = infoConverter
        self.currentInfo = currentInfo
        self.addedWaetherInfo = addedWaetherInfo
        self._style = style
    }
    
    func addWeatherInfoAsFavorote() {
        guard let currentInfo else { return }
        addedWaetherInfo.send(currentInfo)
    }
        
    func dismiss() {
        style = .dismissed
    }
    
    func fetchWeatherCurrentInfo(unit: WeatherUnit = .celsius) {
        if currentInfo == nil {
            let currentWeatherURL = WeatherURLBuilder.URLForCurrent(latitude: selectedCity.lat,
                                                                    longitude: selectedCity.lon,
                                                                    unit: unit)
            networkManager.fetchAndDecode(from: currentWeatherURL, as: CurrentWeather.self)
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
    
    func fetchWeatherForecastInfo() {
        let excludes = [OneCallApiExclude.current.rawValue, OneCallApiExclude.minutely.rawValue, OneCallApiExclude.alerts.rawValue]
        let forecastURL = WeatherURLBuilder.URLForForecast(latitude: selectedCity.lat,
                                                           longitude: selectedCity.lon,
                                                           exclude: excludes)
        networkManager.fetchAndDecode(from: forecastURL, as: WeatherForecast.self)
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
    
    func topViewPresentationInfo() -> TopViewInfo? {
        if let currentInfo {
            return TopViewInfo(name: infoConverter.currentLocationTitle(isMyLocation: currentInfo.isMyLocation,
                                                                        name: currentInfo.currentWeather.name),
                               city: currentInfo.currentWeather.name,
                               temperature: infoConverter.convertTemperatureToText(temp: currentInfo.currentWeather.main.temp,
                                                                                   unit: currentInfo.unit),
                               isMyLocation: currentInfo.isMyLocation,
                               icon: weatherIcon(for: currentInfo.currentWeather.weather.first?.main ?? ""))
        }
        return nil
    }
    
    func hourlyViewPresentationInfo(index: Int) -> HourlyForecastViewInfo? {
        if let currentInfo {
            let hourly = forecastInfo.hourly[index]
            return HourlyForecastViewInfo(name: hourly.name,
                                                      temperature: infoConverter.convertTemperatureToText(temp: hourly.temp,
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
                                         tempMin: LocalizedText.high + ":" + infoConverter.convertTemperatureToText(temp: daily.temp.min,
                                                                                                                    unit: currentInfo.unit),
                                         tempMax:LocalizedText.low + ":" + infoConverter.convertTemperatureToText(temp: daily.temp.max,
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
